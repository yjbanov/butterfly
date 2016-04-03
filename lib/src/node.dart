// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of flutter_ftw.tree;

/// Whether [node] can be updated from [configuration].
///
/// This is used to decide whether a node should be moved, replaced, removed or
/// updated using the new data (configuration).
// TODO: can this be made inlineable?
bool _canUpdate(RenderNode node, Node configuration) {
  if (!identical(node.configuration.runtimeType, configuration.runtimeType)) {
    return false;
  }

  return node.configuration.key == configuration.key;
}

/// A node in the retained tree instantiated from [Node]s.
abstract class RenderNode<N extends Node> {
  RenderNode(this._tree, Node configuration) {
    update(configuration);
  }

  /// The native node that this tree node corresponds to.
  html.Node get nativeNode;

  /// The parent node of this node.
  RenderParent get parent => _parent;
  RenderParent _parent;

  void dispatchEvent(Event event) {
    if (_parent != null) {
      _parent.dispatchEvent(event);
    }
  }

  /// The node tree that this node participates in.
  Tree get tree => _tree;
  final Tree _tree;

  void visitChildren(void visitor(RenderNode child));

  /// Remove this node from the tree.
  ///
  /// This operation can be used to temporarily remove nodes in order to move
  /// them around.
  void detach() {
    nativeNode.remove();
    _parent == null;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.unregister(this);
    }
  }

  /// Attached this node to a [newParent].
  void attach(RenderParent newParent) {
    assert(newParent != null);
    _parent = newParent;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.register(this);
    }
  }

  /// The [Node] that instantiated this retained node.
  N get configuration => _configuration;
  N _configuration;

  /// Updates this node and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  void update(N newConfiguration) {
    assert(newConfiguration != null);
    _configuration = newConfiguration;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.register(this);
    }
  }
}

/// A node that has children.
// TODO(yjbanov): add fast-track access to class
abstract class RenderParent<N extends Node> extends RenderNode<N> {
  RenderParent(Tree tree, N configuration)
      : super(tree, configuration);

  /// Whether any of this node's descentant nodes need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

  /// As a result of an update a [child] may decide to replace its [nativeNode]
  /// with a [replacement]. It will then call this method on its [parent] to
  /// demand that the parent updates its native children.
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement);

  void scheduleUpdate() {
    _hasDescendantsNeedingUpdate = true;
    RenderParent parent = _parent;
    while(parent != null) {
      parent._hasDescendantsNeedingUpdate = true;
      parent = parent.parent;
    }
  }

  /// Updates this node and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  @override
  void update(N newConfiguration) {
    _hasDescendantsNeedingUpdate = false;
    super.update(newConfiguration);
  }
}

/// A node that has multiple children.
abstract class RenderMultiChildParent<N extends MultiChildNode> extends RenderParent<N> {
  RenderMultiChildParent(Tree tree, N configuration) : super(tree, configuration);

  List<RenderNode> _currentChildren;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    if (_currentChildren == null) return;

    for (RenderNode child in _currentChildren) {
      visitor(child);
    }
  }

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    oldNode.parent.insertBefore(replacement, oldNode);
    oldNode.remove();
  }

  @override
  void update(N newConfiguration) {
    if (!identical(configuration, newConfiguration)) {
      List<Node> newChildList = newConfiguration.children;

      if (newChildList != null && newChildList.isNotEmpty && _currentChildren == null) {
        _currentChildren = <RenderNode>[];
      }

      if (_currentChildren == null || _currentChildren.isEmpty) {
        if (newChildList != null && newChildList.isNotEmpty) {
          _appendChildren(newChildList);
        }
      } else if (newChildList == null && newChildList.isEmpty) {
        if (_currentChildren != null && _currentChildren.isNotEmpty) {
          _removeAllCurrentChildren();
        }
      } else {
        // Both are not empty
        int from = 0;
        while(from < _currentChildren.length &&
              from < newChildList.length &&
              _canUpdate(_currentChildren[from], newChildList[from])) {
          _currentChildren[from].update(newChildList[from]);
          from++;
        }

        if (from == _currentChildren.length) {
          if (from < newChildList.length) {
            // More children were added at the end, append them
            _appendChildren(newChildList.sublist(from));
          }
        } else if (from == newChildList.length) {
          // Some children at the end were removed, remove them
          for (int i = _currentChildren.length - 1; i >= from; i--) {
            _currentChildren[i].detach();
          }
          _currentChildren = _currentChildren.sublist(0, from);
        } else {
          // Walk lists from the end and try to update as much as possible
          int currTo = _currentChildren.length;
          int newTo = newChildList.length;
          while(currTo > from &&
                newTo > from &&
                _canUpdate(_currentChildren[currTo - 1], newChildList[newTo - 1])) {
            _currentChildren[currTo - 1].update(newChildList[newTo - 1]);
            currTo--;
            newTo--;
          }

          if (newTo == from && currTo > from) {
            // Some children in the middle were removed, remove them
            for (int i = currTo - 1; i >= from; i--) {
              _currentChildren[i].detach();
            }
            _currentChildren.removeRange(from, currTo);
          } else if (currTo == from && newTo > from) {
            // New children were inserted in the middle, insert them
            Iterable<Node> newChildren = newChildList.getRange(from, newTo);

            List<RenderNode> insertedChildren = <RenderNode>[];
            for (Node vn in newChildren) {
              RenderNode child = vn.instantiate(tree);
              child.attach(this);
              insertedChildren.add(child);
            }

            _currentChildren.insertAll(from, insertedChildren);

            html.Element nativeElement = nativeNode as html.Element;
            html.Node refNode = _currentChildren[newTo].nativeNode;
            for (RenderNode node in insertedChildren) {
              nativeElement.insertBefore(node.nativeNode, refNode);
            }
          } else {
            // We're strictly in the middle of both lists, at which point nodes
            // moved around, were added, or removed. If the nodes are keyed, map
            // them by key and figure out all the moves.

            // TODO: this implementation is very naive; it plucks _all_ children
            // and rearranges them according to new configuration. A smarter
            // implementation would compute the minimum sufficient number of
            // moves to transform the tree into the desired configuration.

            List<RenderNode> disputedRange = <RenderNode>[];
            for (int i = from; i < currTo; i++) {
              RenderNode child = _currentChildren[i];
              child.detach();
              disputedRange.add(child);
            }

            List<RenderNode> newRange = <RenderNode>[];
            html.Element nativeElement = nativeNode;
            html.Node refNode = currTo < _currentChildren.length
              ? _currentChildren[currTo].nativeNode
              : null;
            for (int i = from; i < newTo; i++) {
              Node newChild = newChildList[i];
              // First try to fing an existing node that could be updated
              bool updated = false;
              for (RenderNode child in disputedRange) {
                if (_canUpdate(child, newChild)) {
                  child.update(newChild);
                  child.attach(this);
                  if (refNode == null) {
                    nativeElement.append(child.nativeNode);
                  } else {
                    nativeElement.insertBefore(child.nativeNode, refNode);
                  }
                  updated = true;
                  newRange.add(child);
                  break;
                }
              }

              if (!updated) {
                RenderNode child = newChild.instantiate(tree);
                child.attach(this);
                if (refNode == null) {
                  nativeElement.append(child.nativeNode);
                } else {
                  nativeElement.insertBefore(child.nativeNode, refNode);
                }
                newRange.add(child);
              }
            }

            _currentChildren = <RenderNode>[]
              ..addAll(_currentChildren.sublist(0, from))
              ..addAll(newRange)
              ..addAll(_currentChildren.sublist(currTo));
            assert(_currentChildren.length == nativeElement.childNodes.length);
            assert(_currentChildren.length == newChildList.length);
          }
        }
      }
    } else if (hasDescendantsNeedingUpdate) {
      for (RenderNode child in _currentChildren) {
        child.update(child.configuration);
      }
    }
    super.update(newConfiguration);
  }

  void _appendChildren(List<Node> newChildList) {
    assert(newChildList != null && newChildList.isNotEmpty);
    html.Element nativeElement = nativeNode as html.Element;
    for (Node vn in newChildList) {
      RenderNode node = vn.instantiate(tree);
      node.attach(this);
      _currentChildren.add(node);
      nativeElement.append(node.nativeNode);
    }
  }

  void _removeAllCurrentChildren() {
    for (RenderNode child in _currentChildren) {
      child.detach();
    }
    _currentChildren = <RenderNode>[];
  }
}

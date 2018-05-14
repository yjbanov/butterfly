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

import 'package:meta/meta.dart';

import 'key.dart';
import 'surface.dart';
import 'widgets.dart';

/// Configures the state of the UI.
///
/// This class is at the core of the framework.
@immutable
abstract class Node {
  const Node({this.key});

  final Key key;

  RenderNode instantiate(RenderParent parent);
}

/// A node in the retained tree instantiated from [Node]s.
abstract class RenderNode<N extends Node> {
  RenderNode(this._parent);

  /// The underlying HTML node that this tree node corresponds to.
  Surface get surface;

  /// The parent node of this node.
  RenderParent get parent => _parent;
  RenderParent _parent;

  void visitChildren(void visitor(RenderNode child));

  /// Remove this node from the tree.
  ///
  /// This operation can be used to temporarily remove nodes in order to move
  /// them around.
  void detach() {
    parent.surface.removeChild(surface);
    _parent == null;
    if (_widget.key is GlobalKey) {
      final GlobalKey key = _widget.key;
      key.unregister(this);
    }
  }

  /// Attached this node to a [newParent].
  void attach(RenderParent newParent) {
    assert(newParent != null);
    _parent = newParent;
  }

  /// The [Node] that instantiated this retained node.
  N get widget => _widget;
  N _widget;

  /// Updates this node and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  @mustCallSuper
  void update(N newWidget) {
    assert(newWidget != null);
    _widget = newWidget;
    if (_widget.key is GlobalKey) {
      final GlobalKey key = _widget.key;
      key.register(this);
    }
  }
}

/// A type of node that has a flat list of children.
@immutable
abstract class MultiChildNode extends Node {
  const MultiChildNode({Key key, this.children}) : super(key: key);

  final List<Node> children;
}

/// Whether [node] can be updated from [widget].
///
/// This is used to decide whether a node should be moved, replaced, removed or
/// updated using the new widget.
bool canUpdateRenderNode(RenderNode node, Node widget) {
  if (!identical(node.widget.runtimeType, widget.runtimeType)) {
    return false;
  }

  return node.widget.key == widget.key;
}

/// A node that has children.
abstract class RenderParent<N extends Node> extends RenderNode<N> {
  RenderParent(RenderParent parent) : super(parent);

  /// Whether any of this node's descentant nodes need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

  // TODO(yjbanov): rename to setState
  void scheduleUpdate() {
    _hasDescendantsNeedingUpdate = true;
    RenderParent parent = _parent;
    while (parent != null) {
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
  @mustCallSuper
  void update(N newWidget) {
    _hasDescendantsNeedingUpdate = false;
    super.update(newWidget);
  }
}

/// A node that decorates its child's element.
///
/// Contrast this class with [SingleChildParent], which creates its own element
/// that wraps that of its child.
@experimental
@immutable
abstract class Decoration extends Node {
  const Decoration({Key key, @required this.child}) : super(key: key);

  /// The only child of this node.
  ///
  /// Cannot be `null`.
  final Node child;

  RenderDecoration instantiate(RenderParent parent);
}

abstract class RenderDecoration<N extends Decoration> extends RenderParent<N> {
  RenderDecoration(RenderParent parent) : super(parent);

  RenderNode _currentChild;

  @override
  Surface get surface => _currentChild.surface;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    if (_currentChild != null) {
      visitor(_currentChild);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    if (newWidget == _currentChild._widget) {
      if (hasDescendantsNeedingUpdate) {
        _currentChild.update(newWidget.child);
      }
      return;
    }

    final childConfig = newWidget.child;
    if (_currentChild == null || !canUpdateRenderNode(_currentChild, childConfig)) {
      RenderNode child = childConfig.instantiate(this);
      child.update(childConfig);
      child.attach(this);
      _currentChild = child;
    } else {
      _currentChild.update(childConfig);
    }

    super.update(newWidget);
  }
}

/// A node that has exactly one child.
@experimental
@immutable
abstract class SingleChildParent extends Node {
  // TODO(yjbanov): assert non-null child when const assert are supported by dart2js
  const SingleChildParent({Key key, @required this.child}) : super(key: key);

  /// The only child of this node.
  ///
  /// Cannot be `null`.
  final Node child;

  RenderSingleChildParent instantiate(RenderParent parent);
}

abstract class RenderSingleChildParent<N extends SingleChildParent>
    extends RenderParent<N> {
  RenderSingleChildParent(RenderParent parent) : super(parent);

  RenderNode _currentChild;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    if (_currentChild != null) {
      visitor(_currentChild);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    if (newWidget == _currentChild._widget) {
      if (hasDescendantsNeedingUpdate) {
        _currentChild.update(newWidget.child);
      }
      return;
    }

    final childConfig = newWidget.child;
    if (_currentChild == null || !canUpdateRenderNode(_currentChild, childConfig)) {
      if (_currentChild != null) {
        _currentChild.detach();
      }

      RenderNode child = childConfig.instantiate(this);
      child.update(childConfig);
      child.attach(this);
      _currentChild = child;
    } else {
      _currentChild.update(childConfig);
    }

    super.update(newWidget);
  }
}

/// A node that has multiple children.
abstract class RenderMultiChildParent<N extends MultiChildNode>
    extends RenderParent<N> {
  RenderMultiChildParent(RenderParent parent) : super(parent);

  List<RenderNode> _currentChildren;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    if (_currentChildren == null) {
      return;
    }

    for (RenderNode child in _currentChildren) {
      visitor(child);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    if (!identical(widget, newWidget)) {
      List<Node> newChildList = newWidget.children;

      if (newChildList != null &&
          newChildList.isNotEmpty &&
          _currentChildren == null) {
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
        while (from < _currentChildren.length &&
            from < newChildList.length &&
            canUpdateRenderNode(_currentChildren[from], newChildList[from])) {
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
          while (currTo > from &&
              newTo > from &&
              canUpdateRenderNode(
                  _currentChildren[currTo - 1], newChildList[newTo - 1])) {
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
            List<Node> newChildren = newChildList.sublist(from, newTo);

            List<RenderNode> insertedChildren = <RenderNode>[];
            for (Node vn in newChildren) {
              RenderNode child = vn.instantiate(this);
              child.update(vn);
              child.attach(this);
              insertedChildren.add(child);
            }

            _currentChildren.insertAll(from, insertedChildren);

            Surface refNode = _currentChildren[newTo].surface;
            for (RenderNode node in insertedChildren) {
              surface.insertBefore(node.surface, refNode);
            }
          } else {
            // We're strictly in the middle of both lists, at which point nodes
            // moved around, were added, or removed. If the nodes are keyed, map
            // them by key and figure out all the moves.

            // TODO: this implementation is very naive; it plucks _all_ children
            // and rearranges them according to new widget. A smarter
            // implementation would compute the minimum sufficient number of
            // moves to transform the tree into the desired widget configuration.

            List<RenderNode> disputedRange = <RenderNode>[];
            for (int i = from; i < currTo; i++) {
              RenderNode child = _currentChildren[i];
              child.detach();
              disputedRange.add(child);
            }

            List<RenderNode> newRange = <RenderNode>[];
            Surface refNode = currTo < _currentChildren.length
                ? _currentChildren[currTo].surface
                : null;
            for (int i = from; i < newTo; i++) {
              Node newChild = newChildList[i];
              // First try to fing an existing node that could be updated
              bool updated = false;
              for (RenderNode child in disputedRange) {
                if (canUpdateRenderNode(child, newChild)) {
                  child.update(newChild);
                  child.attach(this);
                  if (refNode == null) {
                    surface.append(child.surface);
                  } else {
                    surface.insertBefore(child.surface, refNode);
                  }
                  updated = true;
                  newRange.add(child);
                  break;
                }
              }

              if (!updated) {
                RenderNode child = newChild.instantiate(this);
                child.update(newChild);
                child.attach(this);
                if (refNode == null) {
                  surface.append(child.surface);
                } else {
                  surface.insertBefore(child.surface, refNode);
                }
                newRange.add(child);
              }
            }

            _currentChildren = <RenderNode>[]
              ..addAll(_currentChildren.sublist(0, from))
              ..addAll(newRange)
              ..addAll(_currentChildren.sublist(currTo));
            assert(_currentChildren.length == surface.childCount);
            assert(_currentChildren.length == newChildList.length);
          }
        }
      }
    } else if (hasDescendantsNeedingUpdate) {
      for (RenderNode child in _currentChildren) {
        child.update(child.widget);
      }
    }
    super.update(newWidget);
  }

  void _appendChildren(List<Node> newChildList) {
    assert(newChildList != null && newChildList.isNotEmpty);
    for (Node vn in newChildList) {
      RenderNode node = vn.instantiate(this);
      node.update(vn);
      node.attach(this);
      _currentChildren.add(node);
      surface.append(node.surface);
    }
  }

  void _removeAllCurrentChildren() {
    for (RenderNode child in _currentChildren) {
      child.detach();
    }
    _currentChildren = <RenderNode>[];
  }
}

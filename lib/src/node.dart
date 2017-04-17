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

part of butterfly;

/// Configures the state of the UI.
///
/// This class is at the core of the framework.
abstract class Node {
  const Node({this.key});

  final Key key;

  RenderNode instantiate(Tree t);
}

/// Function that receives an [event].
typedef void EventListener(Event event);

/// An event emitted by an element.
class Event {
  Event(this.type, this.targetBaristaId, this.data);

  /// Event type, e.g. [EventType.click].
  final EventType type;

  /// ID of the target.
  final String targetBaristaId;

  /// Event data.
  final Map<String, dynamic> data;

  /// Returns a value from [data].
  dynamic operator[](String key) => data[key];
}

/// A node in the retained tree instantiated from [Node]s.
abstract class RenderNode<N extends Node> {
  RenderNode(this._tree, Node configuration) {
    update(configuration);
  }

  /// The parent node of this node.
  RenderParent get parent => _parent;
  RenderParent _parent;

  /// Looks for the event target within the sub-tree rooted at this render node
  /// and dispatches the [event] to it.
  void dispatchEvent(Event event);

  /// The node tree that this node participates in.
  Tree get tree => _tree;
  final Tree _tree;

  void visitChildren(void visitor(RenderNode child));

  /// Remove this node from the tree.
  ///
  /// This operation can be used to temporarily remove nodes in order to move
  /// them around.
  void detach() {
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

abstract class MultiChildNode extends Node {
  const MultiChildNode({Key key, this.children})
    : super(key: key);

  final List<Node> children;
}

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

/// A node that has children.
// TODO(yjbanov): add fast-track access to class
abstract class RenderParent<N extends Node> extends RenderNode<N> {
  RenderParent(Tree tree, N configuration)
      : super(tree, configuration);

  /// Whether any of this node's descentant nodes need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

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
  void update(N newConfiguration) {
    // TODO(yjbanov): implement
    super.update(newConfiguration);
  }

  @override
  void dispatchEvent(Event event) {
    if (_currentChildren == null) return;

    for (final child in _currentChildren) {
      child.dispatchEvent(event);
    }
  }
}

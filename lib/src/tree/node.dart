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

/// A node in the retained tree instantiated from [VirtualNode]s.
abstract class Node<N extends VirtualNode> {
  Node(this._configuration) {
    assert(this._configuration != null);
  }

  /// The native node that this tree node corresponds to.
  html.Node get nativeNode;

  ParentNode get parent => _parent;
  ParentNode _parent;

  void detach() {
    nativeNode.remove();
    _parent == null;
  }

  /// The [VirtualNode] that instantiated this retained node.
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
  }
}

/// A node that has children.
// TODO(yjbanov): add fast-track access to class
abstract class ParentNode<N extends VirtualNode> extends Node<N> {
  ParentNode(N configuration)
      : super(configuration);

  /// Whether any of this node's descentant nodes need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

  void scheduleUpdate() {
    ParentNode parent = _parent;
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
abstract class MultiChildNode<N extends MultiChildVirtualNode> extends ParentNode<N> {
  MultiChildNode(N configuration)
      : super(configuration);

  List<Node> _currentChildren;

  @override
  void update(N newConfiguration) {
    // TODO: this is a super-naive impl, just to get things started.
    if (_currentChildren != null) {
      for (Node child in _currentChildren) {
        child.detach();
      }
    }

    _currentChildren = <Node>[];
    var newChildList = newConfiguration.children;
    if (newChildList != null && newChildList.isNotEmpty) {
    html.Element nativeElement = nativeNode as html.Element;
      for (VirtualNode vn in newChildList) {
        Node node = vn.instantiate();
        _currentChildren.add(node);
        nativeElement.append(node.nativeNode);
      }
    }
    super.update(newConfiguration);
  }
}

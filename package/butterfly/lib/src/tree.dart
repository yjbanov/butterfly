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

/// The render node at the top of the render node hierarchy of a particular
/// app.
/// 
/// Renders a [widget] into HTML DOM hosted by [host].
class Tree extends RenderParent {
  Tree(this.widget, this.host) : super(null) {
    assert(widget != null);
    assert(host != null);
  }

  /// The widget rendered by this tree.
  final Node widget;
  final Surface host;

  RenderNode _topLevelNode;

  void visitChildren(void visitor(RenderNode child)) {
    visitor(_topLevelNode);
  }

  void renderFrame() {
    if (_topLevelNode == null) {
      _topLevelNode = widget.instantiate(this);
      _topLevelNode.update(widget);
      host.append(_topLevelNode.surface);
    } else {
      _topLevelNode.update(_topLevelNode.widget);
    }

    assert(() {
      _debugCheckParentChildRelationships();
      GlobalKey.debugCheckForDuplicates();
      return true;
    }());
    scheduleMicrotask(GlobalKey.notifyListeners);
  }

  bool _debugCheckParentChildRelationships() {
    _debugCheckParentChildRelationshipWith(_topLevelNode);
    return true;
  }

  // TODO: implement surface
  @override
  Surface get surface => host;
}

void _debugCheckParentChildRelationshipWith(RenderNode node) {
  node.visitChildren((RenderNode child) {
    assert(identical(child.parent, node));
    _debugCheckParentChildRelationshipWith(child);
  });
}

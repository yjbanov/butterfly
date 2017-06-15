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

/// Retained virtual mirror of the DOM Tree.
class Tree {
  // TODO(yjbanov): top-level node doesn't have to be final. We can replace it.
  Tree(this._topLevelWidget, this.platformChannel) {
    assert(_topLevelWidget != null);
  }

  final Node _topLevelWidget;
  final PlatformChannel platformChannel;

  RenderNode _topLevelNode;

  StringBuffer _styleBuffer = new StringBuffer();

  void registerStyle(Style style) {
    assert(!style._isRegistered);
    _styleBuffer.writeln('.${style.identifierClass} { ${style.css} }');
  }

  void dispatchEvent(Event event) {
    _topLevelNode.dispatchEvent(event);
  }

  void visitChildren(void visitor(RenderNode child)) {
    visitor(_topLevelNode);
  }

  Map<String, Object> renderFrame() {
    final treeUpdate = new TreeUpdate();

    if (_topLevelNode == null) {
      _topLevelNode = _topLevelWidget.instantiate(this);
      final rootInsertion = treeUpdate.createRootElement();
      _topLevelNode.update(_topLevelWidget, rootInsertion);
    } else {
      final rootUpdate = treeUpdate.updateRootElement();
      _topLevelNode.update(_topLevelNode.configuration, rootUpdate);
    }

    if (_styleBuffer.isNotEmpty) {
      treeUpdate.installStyles(_styleBuffer.toString());
      _styleBuffer = new StringBuffer();
    }

    assert(() {
      _debugCheckParentChildRelationships();
      GlobalKey.debugCheckForDuplicates();
      return true;
    });
    scheduleMicrotask(GlobalKey.notifyListeners);

    return treeUpdate.render();
  }

  bool _debugCheckParentChildRelationships() {
    _debugCheckParentChildRelationshipWith(_topLevelNode);
    return true;
  }
}

void _debugCheckParentChildRelationshipWith(RenderNode node) {
  node.visitChildren((RenderNode child) {
    assert(identical(child.parent, node));
    _debugCheckParentChildRelationshipWith(child);
  });
}

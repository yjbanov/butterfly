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

library flutter_ftw.tree;

import 'dart:async';
import 'dart:html' as html;
import 'framework.dart';
import 'util.dart';

part 'tree/element.dart';
part 'tree/event.dart';
part 'tree/node.dart';
part 'tree/props.dart';
part 'tree/text.dart';
part 'tree/widget.dart';

/// Retained virtual mirror of the DOM Tree.
class Tree extends ParentNode<Widget> {
  Tree(Widget topLevelWidget, this._hostElement)
      : super(topLevelWidget) {
    assert(topLevelWidget != null);
    assert(_hostElement != null);
  }

  Node _topLevelNode;
  final html.Element _hostElement;

  @override
  void visitChildren(void visitor(Node child)) {
    visitor(_topLevelNode);
  }

  /// The native node that this tree node corresponds to.
  html.Node get nativeNode => _hostElement;

  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    _hostElement.insertBefore(replacement, oldNode);
    oldNode.remove();
  }

  void renderFrame() {
    update(configuration);
    assert(() {
      _debugCheckParentChildRelationships();
      GlobalKey.debugCheckForDuplicates();
      return true;
    });
    scheduleMicrotask(GlobalKey.notifyListeners);
  }

  void update(Widget newConfiguration) {
    if (_topLevelNode == null) {
      _topLevelNode = newConfiguration.instantiate();
      _hostElement.append(_topLevelNode.nativeNode);
      _topLevelNode.attach(this);
    } else {
      _topLevelNode.update(_topLevelNode.configuration);
    }
  }

  bool _debugCheckParentChildRelationships() {
    _debugCheckParentChildRelationshipWith(this);
    return true;
  }
}

void _debugCheckParentChildRelationshipWith(Node node) {
  node.visitChildren((Node child) {
    assert(identical(child.parent, node));
    _debugCheckParentChildRelationshipWith(child);
  });
}

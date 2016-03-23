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

import 'dart:html' as html;
import 'framework.dart';
import 'util.dart';

part 'tree/element.dart';
part 'tree/event.dart';
part 'tree/fragment.dart';
part 'tree/node.dart';
part 'tree/text.dart';
part 'tree/widget.dart';

/// Retained virtual mirror of the DOM Tree.
class Tree extends Node<Widget> {
  Tree(Widget topLevelWidget, this._hostElement)
      : _topLevelNode = topLevelWidget.instantiate(),
        super(topLevelWidget) {
    assert(topLevelWidget != null);
    assert(_hostElement != null);
  }

  final html.Element _hostElement;
  final Node _topLevelNode;

  void renderFrame() {
    update(configuration);
  }

  void update(Widget newConfiguration) {
    _topLevelNode.update(newConfiguration);
  }
}

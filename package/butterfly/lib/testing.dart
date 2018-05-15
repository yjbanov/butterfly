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

library butterfly.testing;

import 'package:test/test.dart';

import 'butterfly.dart';

WidgetTester testWidget(Widget root) {
  return new WidgetTester(root);
}

class WidgetTester {
  factory WidgetTester(Widget widget) {
    final host = new Surface();
    final tester = new WidgetTester._(new Tree(widget, host));
    return tester;
  }

  WidgetTester._(this.tree);

  final Tree tree;

  Renderer findNode(bool predicate(Renderer node)) {
    Renderer foundNode;
    void findTrackingNode(Renderer node) {
      if (predicate(node)) {
        foundNode = node;
      } else {
        node.visitChildren(findTrackingNode);
      }
    }

    tree.visitChildren(findTrackingNode);
    return foundNode;
  }

  Renderer findRenderWidgetOfType(Type type) =>
      findNode((node) => node.runtimeType == type);

  Renderer findWidgetOfType(Type type) =>
      findNode((node) => node.widget.runtimeType == type);

  State findStateOfType(Type type) {
    StatefulWidgetRenderer renderWidget = findNode((node) {
      return node is StatefulWidgetRenderer && node.state.runtimeType == type;
    });
    return renderWidget.state;
  }

  void renderFrame() {
    return tree.renderFrame();
  }

  // TODO(yjbanov): turn expect* methods into matchers.
  void expectRenders(String expectedHtml) {
    renderFrame();
    expect(tree.host.debugPrintToHtml(), expectedHtml);
  }

  void expectRenderNoop() {
    final htmlBefore = tree.host.debugPrintToHtml();
    renderFrame();
    final htmlAfter = tree.host.debugPrintToHtml();
    expect(htmlAfter, htmlBefore);
  }
}

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

WidgetTester testWidget(Node root) {
  return new WidgetTester(root);
}

class WidgetTester {
  factory WidgetTester(Node root) {
    final module = new ButterflyModule('test-module', root);
    final tester = new WidgetTester._(module);
    tester.module.initialize();
    return tester;
  }

  WidgetTester._(this.module);

  final ButterflyModule module;

  RenderNode findNode(bool predicate(RenderNode node)) {
    RenderNode foundNode;
    void findTrackingNode(RenderNode node) {
      if (predicate(node)) {
        foundNode = node;
      } else {
        node.visitChildren(findTrackingNode);
      }
    }
    module.tree.visitChildren(findTrackingNode);
    return foundNode;
  }

  RenderNode findNodeOfType(Type type) =>
      findNode((node) => node.runtimeType == type);

  RenderNode findNodeOfConfigurationType(Type type) =>
      findNode((node) => node.configuration.runtimeType == type);

  RenderElement findElementNode({String byTag}) {
    return findNode((n) {
      if (n is! RenderElement) {
        return false;
      }

      if (byTag != null && n.configuration.tag == byTag) {
        return true;
      }

      return false;
    });
  }

  State findStateOfType(Type type) {
    RenderStatefulWidget renderWidget = findNode((node) {
      return node is RenderStatefulWidget && node.state.runtimeType == type;
    });
    return renderWidget.state;
  }

  Map<String, dynamic> renderFrame() {
    return module.renderFrame();
  }

  // TODO(yjbanov): turn expect* methods into matchers.
  void expectRenderCreate(String expectedHtml) {
    final diff = renderFrame();
    expect(diff, isNotNull);
    expect(diff, contains('create'));
    expect(diff['create'], expectedHtml);
  }

  void expectRenderNoop() {
    final diff = renderFrame();
    expect(diff, isNotNull);
    expect(diff.keys, isEmpty);
  }

  void expectRenderUpdate(ElementUpdate update) {
    final diff = renderFrame();
    expect(diff, isNotNull);
    expect(diff, contains('update'));
    Map<String, dynamic> js = <String, dynamic>{};
    update.render(js);
    expect(diff['update'], js);
  }
}

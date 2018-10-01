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

import 'dart:html' as html;

import 'package:test/test.dart';

import 'widgets.dart';

WidgetTester testWidget(Widget rootWidget) {
  return new WidgetTester._(rootWidget);
}

class WidgetTester {
  WidgetTester._(Widget rootWidget) {
    final hostElement = new html.DivElement();

    SchedulerBinding.initialize(((FrameCallback frameHandler) {
      html.window.requestAnimationFrame((_) {
        frameHandler(_frameTimestamp);
      });
    }));

    WidgetsBinding.initialize(hostElement: hostElement);
    WidgetsBinding.instance
      ..attachRootWidget(rootWidget)
      ..drawFrame();
  }

  Duration _frameTimestamp = Duration.zero;

  void pump([Duration duration = const Duration(milliseconds: 16)]) {
    _frameTimestamp += duration;
    WidgetsBinding.instance.drawFrame();
  }

  Element findNode(bool predicate(Element node)) {
    Element foundNode;
    void findTrackingNode(Element node) {
      if (predicate(node)) {
        foundNode = node;
      } else {
        node.visitChildren(findTrackingNode);
      }
    }

    WidgetsBinding.instance.renderViewElement.visitChildren(findTrackingNode);
    return foundNode;
  }

  Element findRenderWidgetOfType(Type type) =>
      findNode((node) => node.runtimeType == type);

  Element findWidgetOfType(Type type) =>
      findNode((node) => node.widget.runtimeType == type);

  State findStateOfType(Type type) {
    StatefulElement renderWidget = findNode((node) {
      return node is StatefulElement && node.state.runtimeType == type;
    });
    return renderWidget.state;
  }

  // TODO(yjbanov): turn expect* methods into matchers.
  void expectRenders(String expectedHtml) {
    pump();
    expectHtml(
      WidgetsBinding.instance.renderViewElement.renderObject,
      expectedHtml,
    );
  }

  String get currentHtml => debugGetRenderObjectHtml(
    WidgetsBinding.instance.renderViewElement.renderObject,
  );

  void expectRenderNoop() {
    final htmlBefore = currentHtml;
    pump();
    final htmlAfter = currentHtml;
    expect(htmlAfter, htmlBefore);
  }
}

void expectHtml(RenderObject renderObject, String html) {
  expect(debugGetRenderObjectHtml(renderObject), html);
}

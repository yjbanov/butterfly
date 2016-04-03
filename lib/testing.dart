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
import 'butterfly.dart';

ApplicationTester runTestApp(Widget topLevelWidget) {
  return new ApplicationTester(topLevelWidget);
}

class ApplicationTester {
  factory ApplicationTester(Widget topLevelWidget) {
    const butterflyTestHostElementId = 'butterfly-test-host-element';
    html.Element hostElement = html.document.querySelector('#$butterflyTestHostElementId');
    if (hostElement != null) {
      hostElement.remove();
    }
    hostElement = new html.DivElement()
      ..id = butterflyTestHostElementId;
    html.document.body.append(hostElement);
    Tree tree = new Tree(topLevelWidget, hostElement);
    ApplicationTester tester = new ApplicationTester._(hostElement, tree);
    tester.renderFrame();
    return tester;
  }

  ApplicationTester._(this.hostElement, this.tree);

  final html.Element hostElement;
  final Tree tree;

  String get innerHtml => hostElement.innerHtml;

  html.Element querySelector(String selector) =>
      hostElement.querySelector(selector);

  html.ElementList<html.Element> querySelectorAll(String selector) =>
      hostElement.querySelectorAll(selector);

  RenderNode findNode(bool predicate(RenderNode node)) {
    RenderNode foundNode;
    void findTrackingNode(RenderNode node) {
      if (predicate(node)) {
        foundNode = node;
      } else {
        node.visitChildren(findTrackingNode);
      }
    }
    tree.visitChildren(findTrackingNode);
    return foundNode;
  }

  RenderNode findNodeOfType(Type type) =>
      findNode((node) => node.runtimeType == type);

  RenderNode findNodeOfConfigurationType(Type type) =>
      findNode((node) => node.configuration.runtimeType == type);

  void renderFrame() {
    tree.renderFrame();
  }
}

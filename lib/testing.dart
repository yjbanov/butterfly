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

library flutter_ftw.testing;

import 'dart:html' as htm;
import 'ftw.dart';
import 'src/tree.dart';

ApplicationTester runTestApp(Widget topLevelWidget) {
  return new ApplicationTester(topLevelWidget);
}

class ApplicationTester {
  factory ApplicationTester(Widget topLevelWidget) {
    htm.DivElement hostElement = new htm.DivElement();
    Tree tree = new Tree(topLevelWidget, hostElement);
    ApplicationTester tester = new ApplicationTester._(hostElement, tree);
    tester.renderFrame();
    return tester;
  }

  ApplicationTester._(this._hostElement, this._tree);

  final htm.Element _hostElement;
  final Tree _tree;

  String get html => _hostElement.innerHtml;

  void renderFrame() {
    _tree.renderFrame();
  }
}

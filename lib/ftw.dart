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

library flutter_ftw;

import 'dart:async';
import 'dart:html' as html;

import 'src/tree.dart' as tree;
import 'src/framework.dart';

export 'src/convenience.dart';
export 'src/framework.dart';

// TODO(yjbanov): do not directly expose `dart:html` as we might want to support
// alternative renderers (web-workers, web-socket).
Application runApp(Widget topLevelWidget, html.Element hostElement) {
  return new Application._(new tree.Tree(topLevelWidget, hostElement))
    ..nextFrame();
}

class Application {
  final tree.Tree _tree;

  Application._(tree.Tree this._tree);

  Future<Null> nextFrame() async {
    await html.window.animationFrame;
    _tree.update();
    nextFrame();
  }
}

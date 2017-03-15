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

library butterfly;

import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

part 'src/convenience.dart';
part 'src/element.dart';
part 'src/event_type.dart';
part 'src/key.dart';
part 'src/node.dart';
part 'src/props.dart';
part 'src/style.dart';
part 'src/text.dart';
part 'src/tree.dart';
part 'src/util.dart';
part 'src/widget.dart';

// TODO(yjbanov): do not directly expose `dart:html` as we might want to support
// alternative renderers (web-workers, web-socket).
Application runApp(Widget topLevelWidget, html.Element hostElement) {
  return new Application._(new Tree(topLevelWidget, hostElement))
    ..nextFrame();
}

class Application {
  final Tree _tree;

  Application._(Tree this._tree);

  // TODO: for some reason a blank animation frame takes 1/2 millisecond. That's
  //       3% of CPU! Either find a way to reduce that dramatically, like 100x
  //       or consider scheduling the next frame only when new state is
  //       received.
  Future<Null> nextFrame() async {
    await html.window.animationFrame;
    _tree.renderFrame();
    nextFrame();
  }
}

/// Top level function to interop with dart extension transpilation.
Node Dx(String _) {
  throw new Exception('Must transpile dart extensions before executing');
}

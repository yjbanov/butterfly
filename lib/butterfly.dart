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

import 'platform_channel.dart';

part 'src/convenience.dart';
part 'src/element.dart';
part 'src/event_type.dart';
part 'src/key.dart';
part 'src/node.dart';
part 'src/style.dart';
part 'src/text.dart';
part 'src/tree.dart';
part 'src/util.dart';
part 'src/widget.dart';

Application runApp(Widget topLevelWidget) {
  return new Application(new Tree(topLevelWidget));
}

class Application {
  final Tree _tree;

  Application(Tree this._tree) {
    PlatformChannel.instance.registerMethod('render-frame', this._renderFrame);
  }

  Map<String, dynamic> renderFrame() {
    return _renderFrame(null);
  }

  Map<String, dynamic> _renderFrame(_) {
    return _tree.renderFrame();
  }
}

/// Top level function to interop with dart extension transpilation.
Node Dx(String _) {
  throw new Exception('Must transpile dart extensions before executing');
}

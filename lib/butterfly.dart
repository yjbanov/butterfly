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
export 'platform_channel.dart';

part 'src/convenience.dart';
part 'src/element.dart';
part 'src/event_type.dart';
part 'src/key.dart';
part 'src/node.dart';
part 'src/protocol.dart';
part 'src/style.dart';
part 'src/text.dart';
part 'src/tree.dart';
part 'src/util.dart';
part 'src/widget.dart';

class ButterflyModule {
  final String _name;
  final Tree _tree;
  final PlatformChannel platformChannel;

  factory ButterflyModule(String name, Node root) {
    final platformChannel = new PlatformChannel();
    final tree = new Tree(root, platformChannel);
    return new ButterflyModule._(name, tree, platformChannel);
  }

  ButterflyModule._(this._name, this._tree, this.platformChannel) {
    platformChannel.registerMethod('render-frame', _renderFrame);
  }

  Map<String, dynamic> _renderFrame(_) {
    return _tree.renderFrame();
  }

  @override
  String toString() => '$ButterflyModule(${_name})';
}

/// Top level function to interop with dart extension transpilation.
Node Dx(String _) {
  throw new Exception('Must transpile dart extensions before executing');
}

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

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'platform_channel.dart';
export 'platform_channel.dart';

part 'src/convenience.dart';
part 'src/element.dart';
part 'src/event_type.dart';
part 'src/key.dart';
part 'src/node.dart';
part 'src/protocol.dart';
part 'src/style.dart';
part 'src/tree.dart';
part 'src/util.dart';
part 'src/widget.dart';
part 'src/basic/container.dart';
part 'src/basic/events.dart';

class ButterflyModule {
  final String _name;
  final PlatformChannel platformChannel;
  final Node _root;
  final Logger _logger;

  Tree _tree;
  Tree get tree => _tree;

  factory ButterflyModule(String name, Node root) {
    final platformChannel = new PlatformChannel();
    return new ButterflyModule._(name, root, platformChannel);
  }

  ButterflyModule._(String name, this._root, this.platformChannel)
      : _logger = new Logger('module:$name'),
        _name = name {
    platformChannel
      ..registerMethod('initialize', initialize)
      ..registerMethod('render-frame', renderFrame)
      ..registerMethod('dispatch-event', dispatchEvent);
  }

  Map<String, Object> initialize([_]) {
    _logger.info('initializing');
    _tree = new Tree(_root, platformChannel);
    return null;
  }

  Map<String, Object> renderFrame([_]) {
    return _tree.renderFrame();
  }

  Map<String, Object> dispatchEvent(Map<String, Object> serializedEvent) {
    String type = serializedEvent['type'];
    String butterflyId = serializedEvent['bid'];
    dynamic data = serializedEvent['data'];
    _tree.dispatchEvent(new Event(new EventType(type), butterflyId, data));
    return null;
  }

  @override
  String toString() => '$ButterflyModule($_name)';
}

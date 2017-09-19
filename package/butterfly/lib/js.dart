// Copyright 2017 Google Inc. All Rights Reserved.
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

@JS()
library butterfly.js;

import 'dart:convert';
import 'package:js/js.dart';
import 'butterfly.dart';

typedef ButterflyActionCallback(
    String moduleName, String methodName, String argumentsJson);

final Map<String, ButterflyModule> _modules = {};
final Map<String, ButterflyModuleJS> _jsModules = {};

/// Serves a [ButterflyModule] hosted by the HTML element identified by
/// [hostElementSelector].
void start(String moduleName, String hostElementSelector, Node root) {
  assert(moduleName.isNotEmpty);
  assert(root != null);

  _modules[moduleName] = new ButterflyModule(moduleName, root);
  _jsModules[moduleName] = new ButterflyModuleJS(
      moduleName, hostElementSelector, allowInterop(_serveDevRequest));
}

@JS('ButterflyModuleJS')
class ButterflyModuleJS {
  external ButterflyModuleJS(
    String name,
    String hostElementSelector,
    ButterflyActionCallback actionCallback,
  );
}

dynamic _serveDevRequest(
    String moduleName, String methodName, String argumentsJson) {
  final module = _modules[moduleName];

  if (module == null) {
    throw new StateError('Module "$moduleName" not found.');
  }

  final arguments = const JsonDecoder().convert(argumentsJson);
  final result = module.platformChannel.invokeDart(methodName, arguments);
  return JSON.encode(result);
}

/// An error related to the Butterfly dev server.
class DevServerError extends Error {
  /// Creates an error with a message.
  DevServerError(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => '$DevServerError: $message';
}

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

// TODO: look into https://developer.android.com/reference/android/os/Parcel.html

// Approach
// --------
//
// This is currently implemented using synchronous XHR. Because only the browser
// can initiate the XHR, we cannot implement synchronous API from the framework
// into the browser that looks like a normal method call. Instead, the
// framework-side client is callback-based. However, the callbacks are not
// entirely asynchronous. While they are delayed, they are still called within
// the current JS message loop event and therefore still blocking on the JS
// side. This allows us to do back'n'forth between Dart and the browser several
// times before letting the browser render the frame.

/// Implements communication between code running in the main JavaScript runtime
/// and Dart code running inside WebAssembly.
class PlatformChannel {

  static final PlatformChannel _instance = new PlatformChannel._();

  /// Returns the platform channel.
  static PlatformChannel get instance => _instance;

  PlatformChannel._();

  final Map<String, MethodInvocationHandler> _methods = <String, MethodInvocationHandler>{};

  /// Registers a method that can be invoked from the main JavaScript runtime.
  void registerMethod(String name, MethodInvocationHandler handler) {
    _methods[name] = handler;
  }

  /// Invokes a [MethodInvocationHandler] registered under [name].
  dynamic invokeDart(String name, dynamic arguments) {
    MethodInvocationHandler method = _methods[name];
    assert(() {
      if (method == null) {
        throw 'Method ${method} is not registered. Register it using '
            '"PlatformChannel.registerMethod"';
      }
      return true;
    });

    return method(arguments);
  }

  /// Invokes a [method] in the main JavaScript runtime.
  ///
  /// [arguments] contains method call arguments, and is expected to be
  /// serializable (as of now to JSON).
  void invokeJS(String method, dynamic arguments, [ResultHandler handler]) {
    throw 'not implemented';
  }
}

/// Handles a method call.
///
/// [arguments] is the deserialized (as of now JSON) value. The returned value is
/// expected to be serializable (as of now to JSON).
typedef dynamic MethodInvocationHandler(dynamic arguments);

/// Callback called with the [result] of a JavaScript method call.
///
/// [result] is deserialized (as of now from JSON).
typedef ResultHandler(dynamic result);

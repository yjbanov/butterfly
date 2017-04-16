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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as pathlib;

import 'platform_channel.dart';

/// Butterfly development server that serves the application.
class ButterflyDevServer {
  static const String _devChannelPath = '/__butterfly_dev_channel__';

  /// Starts a development server listening on the given [port] number.
  static Future<ButterflyDevServer> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
    print('Butterfly dev server listening on http://localhost:$port');
    return new ButterflyDevServer._(server);
  }

  ButterflyDevServer._(this._server) {
    _platformChannel.registerMethod('latency-benchmark', _latencyBenchmark);
    _listen();
  }

  final HttpServer _server;
  final PlatformChannel _platformChannel = PlatformChannel.instance;

  Future<Null> _listen() async {
    await for (final request in _server) {
      print('[HTTP] ${request.method} ${request.uri}');
      try {
        if (request.uri.path.startsWith(_devChannelPath)) {
          await _serveDevRequest(request);
        } else {
          await _serveStatic(request);
        }
      } catch(error, stackTrace) {
        request.response.writeln(error);
        request.response.writeln(stackTrace);
      } finally {
        await request.response.close();
      }
    }
  }

  Future<Null> _serveDevRequest(HttpRequest request) async {
    final methodName = request.uri.path.substring(_devChannelPath.length + 1);
    dynamic arguments = await const JsonDecoder().bind(request.transform(const Utf8Decoder())).single;
    final result = _platformChannel.invokeDart(methodName, arguments);
    request.response.write(JSON.encode(result));
  }

  static final math.Random _rnd = new math.Random();
  static final List<int> _chars = '1234567890qwertyuiopasdfghjklzxcvbnm,./;[]`='.codeUnits;

  dynamic _latencyBenchmark(_) {
    final buf = new StringBuffer();
    for (int i = 0; i < 1024; i++) {
      buf.writeCharCode(_chars[_rnd.nextInt(_chars.length)]);
    }
    return buf.toString();
  }

  /// Serves static files. Supports directory listing.
  Future<Null> _serveStatic(HttpRequest request) async {
    if (!request.uri.path.startsWith('/')) {
      throw new StateError('Unsupported URI path: ${request.uri.path}');
    }

    final path = './${request.uri.path.substring(1)}';

    if (!pathlib.isWithin(pathlib.current, path)) {
      throw new StateError('Refuse to serve files from outside of the '
          'project directory.');
    }

    final pathType = await FileSystemEntity.type(path);

    if (pathType == FileSystemEntityType.NOT_FOUND) {
      request.response.statusCode = 404;
      request.response.writeln('File not found: ${path}');
    } else if (pathType == FileSystemEntityType.DIRECTORY) {
      if (path.endsWith('/')) {
        final dir = new Directory(path);
        request.response.headers.contentType = ContentType.HTML;
        await for (final item in dir.list()) {
          final relativePath = pathlib.relative(item.path, from: dir.path);
          request.response.writeln(
              '<a href="${relativePath}">${relativePath}</a><br>');
        }
      } else {
        request.response.statusCode = HttpStatus.MOVED_TEMPORARILY;
        request.response.headers.set('Location', '${request.uri.path}/');
      }
    } else if (pathType == FileSystemEntityType.FILE) {
      final file = new File(path);
      request.response.headers.contentType = ContentType.parse(mime.lookupMimeType(path));
      await file.openRead().pipe(request.response);
    } else if (pathType == FileSystemEntityType.LINK) {
      request.response.statusCode = 500;
      request.response.writeln('Symlinks not supported at this time');
    } else {
      throw new StateError('Unsupported path type: ${pathType}');
    }
  }
}

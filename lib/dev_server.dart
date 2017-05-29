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

import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as pathlib;
import 'package:ansicolor/ansicolor.dart' as ansi;
import 'package:logging/logging.dart';

import 'butterfly.dart';

/// Butterfly development server that serves the application.
class ButterflyDevServer {
  static const String _devChannelNamespace = '_butterfly';
  static const String _devChannelPath = '/${_devChannelNamespace}';
  static const String _devServerClientFile = 'dev_server_client.js';
  static final Logger _devLogger = new Logger('ButterflyDevServer');

  /// Starts a development server listening on the given [port] number.
  static Future<ButterflyDevServer> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
    _initLogger();
    _devLogger.info('Butterfly dev server listening on http://localhost:$port');
    return new ButterflyDevServer._(server);
  }

  ButterflyDevServer._(this._server) {
    _listen();
  }

  final HttpServer _server;
  final Map<String, ButterflyModule> _modules = {};

  void serveModule(String moduleName, Node root) {
    assert(moduleName.isNotEmpty);
    assert(root != null);

    _modules[moduleName] = new ButterflyModule(moduleName, root);
  }

  Future<Null> _listen() async {
    await for (final request in _server) {
      _devLogger.info('[HTTP] ${request.method} ${request.uri}');
      try {
        if (request.uri.path.startsWith(_devChannelPath)) {
          await _serveDevRequest(request);
        } else {
          await _serveStatic(request);
        }
      } catch (error, stackTrace) {
        _devLogger.shout('Error', error, stackTrace);
        final errorResponse = <String, String>{
          'error': '${error}\n${stackTrace}',
        };
        request.response.write(JSON.encode(errorResponse));
      } finally {
        await request.response.close();
      }
    }
  }

  Future<Null> _serveDevRequest(HttpRequest request) async {
    // The URL format is /_butterfly/mobule, which first two being "/" and
    // "_butterfly", which we don't need.
    final fragments = pathlib.split(request.uri.path).skip(2).toList();

    if (fragments.last == _devServerClientFile) {
      await _serveDevServerClientFile(request);
      return;
    }

    assert(fragments.length == 2);
    final moduleName = fragments[0];
    final methodName = fragments[1];

    final module = _modules[moduleName];

    if (module == null) {
      throw new StateError('Module "$moduleName" not found.');
    }

    final arguments = await const JsonDecoder()
        .bind(request.transform(const Utf8Decoder()))
        .single;
    final result = module.platformChannel.invokeDart(methodName, arguments);
    request.response.write(JSON.encode(result));
  }

  Future<Null> _serveDevServerClientFile(HttpRequest request) async {
    final packagesFile = new File('.packages');

    if (!await packagesFile.exists()) {
      throw new StateError('.packages file not found. Have you run pub get?');
    }

    List<String> packageInfoParts = await packagesFile
        .openRead()
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .map((line) => line.split(':'))
        .firstWhere((parts) => parts[0] == 'butterfly',
            defaultValue: () => null);

    if (packageInfoParts == null) {
      throw new StateError(
          '"butterfly" package not found in .packages file. Please check your pubspec.yaml and run pub get again.');
    }

    final file = new File('${packageInfoParts.last}/${_devServerClientFile}');
    request.response.headers.contentType =
        ContentType.parse(mime.lookupMimeType('.js'));
    await file.openRead().pipe(request.response);
  }

  /// Serves static files. Supports directory listing.
  Future<Null> _serveStatic(HttpRequest request) async {
    if (!request.uri.path.startsWith('/')) {
      throw new StateError('Unsupported URI path: ${request.uri.path}');
    }

    final path = request.uri.path == '/'
        ? '${pathlib.current}/'
        : pathlib.join(pathlib.current, '${request.uri.path.substring(1)}');

    if (!pathlib.equals(pathlib.current, path) &&
        !pathlib.isWithin(pathlib.current, path)) {
      throw new StateError('Refusing to serve files from outside of the '
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
          request.response
              .writeln('<a href="${relativePath}">${relativePath}</a><br>');
        }
      } else {
        request.response.statusCode = HttpStatus.MOVED_TEMPORARILY;
        request.response.headers.set('Location', '${request.uri.path}/');
      }
    } else if (pathType == FileSystemEntityType.FILE) {
      final file = new File(path);
      request.response.headers.contentType =
          ContentType.parse(mime.lookupMimeType(path));
      await file.openRead().pipe(request.response);
    } else if (pathType == FileSystemEntityType.LINK) {
      _devLogger
          .warning('${request.uri.path}: Symlinks not supported at this time');
      request.response.statusCode = 500;
      request.response.writeln('Symlinks not supported at this time');
    } else {
      throw new StateError('Unsupported path type: ${pathType}');
    }
  }
}

/// Configures the logger to print messages to the command line.
///
/// In the future, this could be expanded to send logs to the browser
/// dev console or a special addon.
void _initLogger() {
  final pen = new ansi.AnsiPen();
  final welcomeMessage = r'''
  ____          _    _                __  _        
 |  _ \        | |  | |              / _|| |       
 | |_) | _   _ | |_ | |_  ___  _ __ | |_ | | _   _ 
 |  _ < | | | || __|| __|/ _ \| '__||  _|| || | | |
 | |_) || |_| || |_ | |_|  __/| |   | |  | || |_| |
 |____/  \__,_| \__| \__|\___||_|   |_|  |_| \__, |
                                              __/ |
                                             |___/  
  dev server version 0.0.1.     
''';
  pen.magenta();
  print(pen.write(welcomeMessage) + '\n\n');

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    pen.blue();
    final timestamp = pen.write('${rec.time}:');
    if (rec.level < Level.WARNING) {
      pen.black();
    } else if (rec.level > Level.WARNING) {
      pen.yellow();
    } else {
      pen.red();
    }
    print('$timestamp ' + pen.write('${rec.message}'));
  });
}

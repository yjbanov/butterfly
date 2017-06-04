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
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';
import 'package:vm_service_lib/vm_service_lib_io.dart';

Future<Null> main(List<String> args) async {
  final vmServicePort = int.parse(args.single);

  final vmServiceUri = new Uri(
    scheme: 'http',
    host: 'localhost',
    port: vmServicePort,
  );
  print('Observatory URI: $vmServiceUri');

  final vmService =
      await vmServiceConnect(vmServiceUri.host, vmServiceUri.port);
  final vm = await vmService.getVM();
  final isolate = vm.isolates.first;

  final projectPath = path.absolute('./');
  print('Watching path: $projectPath');

  var watcher = new DirectoryWatcher(projectPath);
  watcher.events.listen((event) async {
    stdout.write('Hot-reloading app...');
    final sw = new Stopwatch()..start();
    await vmService.callMethod('reloadSources', isolateId: isolate.id);
    sw.stop();
    print('done in ${sw.elapsedMilliseconds} ms.');
  });
}

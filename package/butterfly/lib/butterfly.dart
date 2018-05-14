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

import 'package:meta/meta.dart';

import 'src/framework.dart';
import 'src/key.dart';
import 'src/surface.dart';

export 'src/framework.dart';
export 'src/key.dart';
export 'src/surface.dart';

part 'src/tree.dart';
part 'src/util.dart';
part 'src/basic/container.dart';
part 'src/basic/layout.dart';
part 'src/basic/common.dart';

void runApp(Widget widget, Surface host) {
  new Tree(widget, host).renderFrame();
}

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

import 'package:butterfly/butterfly.dart';
import '../common.dart';

const matButtonPadding = matGrid;
const matButtonMinWidth = '${88 - 2 * matButtonPadding}px';
const matButtonMinHeight = '${36 - 2 * matButtonPadding}px';

final Style matButton = style({
  mixin: displayInlineFlex,
  'align-items': 'center',
  'justify-content': 'center',
  'min-width': matButtonMinWidth,
  'min-height': matButtonMinHeight,
  'padding': matButtonPadding,
  'cursor': 'pointer',
  'outline': 'none',
  'text-transform': 'uppercase',
  mixin: userSelectNone,
});

final Style matButtonDisabled = style({
  'opacity': '$matDisabledOpacity',
});

final Style matButtonRaised = style(shadowElevation2);

final Style matButtonNoPadding = style({
  'padding': '0',
});

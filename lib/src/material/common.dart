// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.  '0 (the "License") '
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

export 'flex.dart';
export 'colors.dart';

// Components may be wrapped into a density class that reduces margins,
// paddings, and sizes of some elements. The density can be:
// .density-comfortable - default material sizes
// .density-compact - everything is minimized to make the most elements present
//                    on the screen at once

const matGrid = 8; // px
const matDisabledOpacity = 0.38;

const shadowTransition = const {
  'transition': 'box-shadow 0.28s cubic-bezier(0.4, 0, 0.2, 1)',
};

const shadowNone = const {
  'box-shadow': 'none',
};

const shadowElevation2 = const {
  'box-shadow': '0 2px 2px 0 rgba(0, 0, 0, 0.14) '
                '0 1px 5px 0 rgba(0, 0, 0, 0.12) '
                '0 3px 1px -2px rgba(0, 0, 0, 0.2) '
};

const shadowElevation3 = const {
  'box-shadow': '0 3px 4px 0 rgba(0, 0, 0, 0.14) '
                '0 1px 8px 0 rgba(0, 0, 0, 0.12) '
                '0 3px 3px -2px rgba(0, 0, 0, 0.4) '
};

const shadowElevation4 = const {
  'box-shadow': '0 4px 5px 0 rgba(0, 0, 0, 0.14) '
                '0 1px 10px 0 rgba(0, 0, 0, 0.12) '
                '0 2px 4px -1px rgba(0, 0, 0, 0.4) '
};

const shadowElevation6 = const {
  'box-shadow': '0 6px 10px 0 rgba(0, 0, 0, 0.14) '
                '0 1px 18px 0 rgba(0, 0, 0, 0.12) '
                '0 3px 5px -1px rgba(0, 0, 0, 0.4) '
};

const shadowElevation8 = const {
  'box-shadow': '0 8px 10px 1px rgba(0, 0, 0, 0.14) '
                '0 3px 14px 2px rgba(0, 0, 0, 0.12) '
                '0 5px 5px -3px rgba(0, 0, 0, 0.4) '
};

const shadowElevation16 = const {
  'box-shadow': '0 16px 24px 2px rgba(0, 0, 0, 0.14) '
                '0  6px 30px 5px rgba(0, 0, 0, 0.12) '
                '0  8px 10px -5px rgba(0, 0, 0, 0.4) '
};

const userSelectNone = const {
  '-moz-user-select': 'none',
  '-ms-user-select': 'none',
  '-webkit-user-select': 'none',
  'user-select': 'none',
};

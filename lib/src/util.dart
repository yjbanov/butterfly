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

import 'dart:collection';

/// Dart VM implements `identical` as true reference identity. JavaScript does
/// not have this. The closest we have in JS is `===`. However, for strings JS
/// would actually compare the contents rather than references. `dart2js`
/// compiles `identical` to `===` and therefore there is a discrepancy between
/// Dart VM and `dart2js`. The implementation of `looseIdentical` attempts to
/// bridge the gap between the two while retaining good performance
/// characteristics. In JS we use simple `identical`, which compiles to `===`,
/// and in Dart VM we emulate the semantics of `===` by special-casing strings.
/// Note that the VM check is a compile-time constant. This allows `dart2js` to
/// evaluate the conditional during compilation and inline the entire function.
///
/// See: dartbug.com/22496, dartbug.com/25270
const _IS_DART_VM = !identical(1.0, 1);  // a hack
bool looseIdentical(a, b) => _IS_DART_VM
  ? _looseIdentical(a, b)
  : identical(a, b);

/// This function is intentionally separated from `looseIdentical` to keep the
/// number of AST nodes low enough for `dart2js` to inline the code.
bool _looseIdentical(a, b) =>
    a is String && b is String ? a == b : identical(a, b);

/// Use this function to guard debugging code. When Dart is compiled in
/// production mode, the code guarded using this function will be tree
/// shaken away, reducing code size.
///
/// WARNING: DO NOT CHANGE THIS METHOD! This method is designed to have no
/// more AST nodes than the maximum allowed by dart2js to inline it. In
/// addition, the use of `assert` allows the compiler to statically compute
/// the value returned by this function and tree shake conditions guarded by
/// it.
///
/// Example:
///
/// if (assertionsEnabled()) {
///   ...code here is tree shaken away in prod mode...
/// }
bool get assertionsEnabled {
  var k = false;
  assert((k = true));
  return k;
}

/// Creates an immutable wrapper for [map] in checked mode.
///
/// This function is designed to be inlinable by `dart2js` have zero runtime
/// cost.
Map fixedMap(Map map) {
  assert(map != null);
  return assertionsEnabled
    ? new UnmodifiableMapView(map)
    : map;
}

/// Creates an immutable wrapper for [list] in checked mode.
///
/// This function is designed to be inlinable by `dart2js` have zero runtime
/// cost.
List fixedList(List list) {
  assert(list != null);
  return assertionsEnabled
    ? new UnmodifiableListView(list)
    : list;
}

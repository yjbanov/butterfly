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

/// A Key is an identifier for [Widget]s and [Element]s. A new Widget will only
/// be used to reconfigure an existing Element if its Key is the same as its
/// original Widget's Key.
///
/// Keys must be unique amongst the Elements with the same parent.
abstract class Key {
  /// Default constructor, used by subclasses.
  const Key.constructor(); // so that subclasses can call us, since the Key() factory constructor shadows the implicit constructor

  /// Construct a ValueKey<String> with the given String.
  /// This is the simplest way to create keys.
  factory Key(String value) => new ValueKey<String>(value);
}

/// A kind of [Key] that uses a value of a particular type to identify itself.
///
/// For example, a ValueKey<String> is equal to another ValueKey<String> if
/// their values match.
class ValueKey<T> extends Key {
  const ValueKey(this.value) : super.constructor();
  final T value;
  bool operator ==(dynamic other) {
    if (other is! ValueKey<T>) return false;
    final ValueKey<T> typedOther = other;
    return value == typedOther.value;
  }

  int get hashCode => value.hashCode;
  String toString() => '$value';
}

/// A [Key] that is only equal to itself.
class UniqueKey extends Key {
  const UniqueKey() : super.constructor();
  String toString() => '[$hashCode]';
}

/// A kind of [Key] that takes its identity from the object used as its value.
///
/// Used to tie the identity of a Widget to the identity of an object used to
/// generate that Widget.
class ObjectKey extends Key {
  const ObjectKey(this.value) : super.constructor();
  final Object value;
  bool operator ==(dynamic other) {
    if (other is! ObjectKey) return false;
    final ObjectKey typedOther = other;
    return identical(value, typedOther.value);
  }

  int get hashCode => identityHashCode(value);
  String toString() => '[${value.runtimeType}(${value.hashCode})]';
}

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

import 'tree.dart' as tree;
import 'util.dart';

/// TODO: port Flutter's key system.
abstract class Key<V> {
  const Key(this.value);

  final V value;
}

abstract class VirtualNode {
  const VirtualNode({this.key});
  final Key key;

  tree.Node instantiate();
}

abstract class MultiChildVirtualNode extends VirtualNode {
  const MultiChildVirtualNode({Key key, this.children})
    : super(key: key);

  final List<VirtualNode> children;
}

/// A kind of node that's composed of other nodes.
abstract class Widget extends VirtualNode {
  const Widget({Key key}) : super(key: key);
}

/// A widget built out of other [VirtualNode]s and has no mutable state.
///
/// As a matter of good practice prefer making stateless widgets immutable, or
/// even better, support `const`. Because mutations on a stateless widget do not
/// make sense, immutabity sets the right expectation that the state cannot be
/// altered.
abstract class StatelessWidget extends Widget {
  const StatelessWidget({Key key}) : super(key: key);

  tree.Node instantiate() => new tree.StatelessWidgetNode(this);

  VirtualNode build();
}

/// A widget that's built from a mutable [State] object.
///
/// As a matter of good practice, prefer making the widget class immutable, or
/// even better, support `const`. However, the [State] object can be mutable. In
/// fact, it should be mutable. If you find that the state object is immutable,
/// consider switching to a [StatelessWidget].
abstract class StatefulWidget extends Widget {
  const StatefulWidget({Key key}) : super(key: key);

  State createState();

  tree.Node instantiate() => new tree.StatefulWidgetNode(this);
}

/// Mutable state of a [StatefulWidget].
abstract class State<T extends StatefulWidget> {
  VirtualNode build();
}

/// A kind of node that maps directly to the render system's native element, for
/// example an HTML element such as `<div>`, `<button>`.
class VirtualElement extends MultiChildVirtualNode {
  const VirtualElement(this.tag, {Key key, this.attributes, List<VirtualNode> children})
    : super(key: key, children: children);

  final String tag;
  final Attributes attributes;

  @override
  tree.Node instantiate() => new tree.ElementNode(this);
}

/// An immutable hierarchical collection of attributes.
class Attributes {
  /// Creates a `const` map of attributes.
  const Attributes.constant(this._data, {Attributes base})
      : _base = base;

  /// Creates a non-`const` immutable map of attributes.
  Attributes(Map<String, String> data, {Attributes base})
      : _data = fixedMap(data),
        _base = base;

  final Map<String, String> _data;
  final Attributes _base;

  String operator[](String name) => this.getAttribute(name);

  bool operator==(Attributes other) {
    return identical(this, other) || (
      identical(this._data, other._data) && (
        identical(this._base, other._base) ||
        this._base == other._base
      )
    );
  }

  /// Convenience over `operator[]` for cases when null-aware operators are
  /// used (operators do not mix with null-aware operators).
  String getAttribute(String name) => _data[name] ?? _base?.getAttribute(name);

  /// Flat map of all attributes.
  Map<String, String> get all => _base == null
    ? _data
    : <String, String>{}
        ..addAll(_base.all)
        ..addAll(_data);
}

/// A kind of node that maps directly to the render system's native node
/// representing a text value.
class Text extends VirtualNode {
  final String value;
  const Text(this.value);

  tree.Node instantiate() => new tree.TextNode(this);
}

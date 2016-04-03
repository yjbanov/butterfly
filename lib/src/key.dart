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

part of butterfly;

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
    if (other is! ValueKey<T>)
      return false;
    final ValueKey<T> typedOther = other;
    return value == typedOther.value;
  }
  int get hashCode => value.hashCode;
  String toString() => '[\'$value\']';
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
    if (other is! ObjectKey)
      return false;
    final ObjectKey typedOther = other;
    return identical(value, typedOther.value);
  }
  int get hashCode => identityHashCode(value);
  String toString() => '[${value.runtimeType}(${value.hashCode})]';
}

typedef void GlobalKeyRemoveListener(GlobalKey key);

/// A GlobalKey is one that must be unique across the entire application. It is
/// used by components that need to communicate with other components across the
/// application's element
abstract class GlobalKey<T extends State<StatefulWidget>> extends Key {
  const GlobalKey.constructor() : super.constructor(); // so that subclasses can call us, since the Key() factory constructor shadows the implicit constructor

  /// Constructs a LabeledGlobalKey, which is a GlobalKey with a label used for debugging.
  /// The label is not used for comparing the identity of the key.
  factory GlobalKey({ String debugLabel }) => new LabeledGlobalKey<T>(debugLabel); // the label is purely for debugging purposes and is otherwise ignored

  static final Map<GlobalKey, RenderNode> _registry = new Map<GlobalKey, RenderNode>();
  static final Map<GlobalKey, int> _debugDuplicates = new Map<GlobalKey, int>();
  static final Map<GlobalKey, Set<GlobalKeyRemoveListener>> _removeListeners = new Map<GlobalKey, Set<GlobalKeyRemoveListener>>();
  static final Set<GlobalKey> _removedKeys = new Set<GlobalKey>();

  void register(RenderNode element) {
    assert(() {
      if (_registry.containsKey(this)) {
        int oldCount = _debugDuplicates.putIfAbsent(this, () => 1);
        assert(oldCount >= 1);
        _debugDuplicates[this] = oldCount + 1;
      }
      return true;
    });
    _registry[this] = element;
  }

  void unregister(RenderNode element) {
    assert(() {
      if (_registry.containsKey(this) && _debugDuplicates.containsKey(this)) {
        int oldCount = _debugDuplicates[this];
        assert(oldCount >= 2);
        if (oldCount == 2) {
          _debugDuplicates.remove(this);
        } else {
          _debugDuplicates[this] = oldCount - 1;
        }
      }
      return true;
    });
    if (_registry[this] == element) {
      _registry.remove(this);
      _removedKeys.add(this);
    }
  }

  RenderNode get _currentTreeNode => _registry[this];
  Node get currentVirtualNode => _currentTreeNode?.configuration;
  T get currentState {
    RenderNode element = _currentTreeNode;
    if (element is RenderStatefulWidget) {
      RenderStatefulWidget statefulElement = element;
      return statefulElement.state;
    }
    return null;
  }

  static void registerRemoveListener(GlobalKey key, GlobalKeyRemoveListener listener) {
    assert(key != null);
    Set<GlobalKeyRemoveListener> listeners =
        _removeListeners.putIfAbsent(key, () => new Set<GlobalKeyRemoveListener>());
    bool added = listeners.add(listener);
    assert(added);
  }

  static void unregisterRemoveListener(GlobalKey key, GlobalKeyRemoveListener listener) {
    assert(key != null);
    assert(_removeListeners.containsKey(key));
    bool removed = _removeListeners[key].remove(listener);
    if (_removeListeners[key].isEmpty)
      _removeListeners.remove(key);
    assert(removed);
  }

  static bool debugCheckForDuplicates() {
    String message = '';
    for (GlobalKey key in _debugDuplicates.keys) {
      message += 'The following GlobalKey was found multiple times among mounted elements: $key (${_debugDuplicates[key]} instances)\n';
      message += 'The most recently registered instance is: ${_registry[key]}\n';
    }
    if (!_debugDuplicates.isEmpty)
      throw new StateError('Incorrect GlobalKey usage: $message');
    return true;
  }

  static void notifyListeners() {
    if (_removedKeys.isEmpty)
      return;
    try {
      for (GlobalKey key in _removedKeys) {
        if (!_registry.containsKey(key) && _removeListeners.containsKey(key)) {
          Set<GlobalKeyRemoveListener> localListeners = new Set<GlobalKeyRemoveListener>.from(_removeListeners[key]);
          for (GlobalKeyRemoveListener listener in localListeners)
            listener(key);
        }
      }
    } finally {
      _removedKeys.clear();
    }
  }

}

/// Each LabeledGlobalKey instance is a unique key.
/// The optional label can be used for documentary purposes. It does not affect
/// the key's identity.
class LabeledGlobalKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  const LabeledGlobalKey(this._debugLabel) : super.constructor();
  final String _debugLabel;
  String toString() => '[GlobalKey ${_debugLabel != null ? _debugLabel : hashCode}]';
}

/// A kind of [GlobalKey] that takes its identity from the object used as its value.
///
/// Used to tie the identity of a Widget to the identity of an object used to
/// generate that Widget.
class GlobalObjectKey extends GlobalKey {
  const GlobalObjectKey(this.value) : super.constructor();
  final Object value;
  bool operator ==(dynamic other) {
    if (other is! GlobalObjectKey)
      return false;
    final GlobalObjectKey typedOther = other;
    return identical(value, typedOther.value);
  }
  int get hashCode => identityHashCode(value);
  String toString() => '[$runtimeType ${value.runtimeType}(${value.hashCode})]';
}

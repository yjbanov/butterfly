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

import 'package:meta/meta.dart';

import 'key.dart';
import 'framework.dart';
import 'surface.dart';

/// A kind of node that's composed of other nodes.
abstract class Widget extends Node {
  const Widget({Key key}) : super(key: key);
}

/// A widget built out of other [Node]s and has no mutable state.
///
/// As a matter of good practice prefer making stateless widgets immutable, or
/// even better, support `const`. Because mutations on a stateless widget do not
/// make sense, immutabity sets the right expectation that the state cannot be
/// altered.
abstract class StatelessWidget extends Widget {
  const StatelessWidget({Key key}) : super(key: key);

  RenderNode instantiate(RenderParent parent) => new RenderStatelessWidget(parent);

  Node build();
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

  RenderNode instantiate(RenderParent parent) => new RenderStatefulWidget(parent);
}

typedef dynamic StateSettingFunction();

/// Mutable state of a [StatefulWidget].
abstract class State<T extends StatefulWidget> {
  RenderStatefulWidget _node;
  T _config;
  T get config => _config;

  Node build();

  @protected
  void setState(StateSettingFunction fn) {
    assert(() {
      if (fn == null) {
        throw new ArgumentError.notNull('fn');
      }
      return true;
    }());
    fn();
    _node.scheduleUpdate();
  }

  /// Lifecycle method called before the widget is unmounted in the DOM.
  ///
  /// Perform cleanup like canceling stream subscriptions here.
  void willUnmount() {}
}

// TODO: this begs for a better API
void internalSetStateNode(State state, RenderStatefulWidget node) {
  state._node = node;
}

class RenderStatelessWidget extends RenderParent<StatelessWidget> {
  RenderStatelessWidget(RenderParent parent) : super(parent);

  RenderNode _child;

  @override
  Surface get surface => _child.surface;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

  @override
  void update(StatelessWidget newWidget) {
    assert(newWidget != null);
    if (!identical(widget, newWidget)) {
      // Build the new widget and decide whether to reuse the child node
      // or replace with a new one.
      Node newChildWidget = newWidget.build();
      assert(newChildWidget != null);
      if (_child != null && canUpdateRenderNode(_child, newChildWidget)) {
        _child.update(newChildWidget);
      } else {
        // Replace child
        _child?.detach();
        _child = newChildWidget.instantiate(this);
        _child.update(newChildWidget);
        _child.attach(this);
      }
    } else if (hasDescendantsNeedingUpdate) {
      // Own widget is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.widget);
    }
    super.update(newWidget);
  }
}

class RenderStatefulWidget extends RenderParent<StatefulWidget> {
  RenderStatefulWidget(RenderParent parent) : super(parent);

  State _state;
  State get state => _state;
  RenderNode _child;
  bool _isDirty = false;

  @override
  Surface get surface => _child.surface;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

  void scheduleUpdate() {
    _isDirty = true;
    super.scheduleUpdate();
  }

  void update(StatefulWidget newWidget) {
    assert(newWidget != null);
    if (!identical(widget, newWidget)) {
      // Build the new widget and decide whether to reuse the child node
      // or replace with a new one.
      // If there is an existing widget, call it's #willUnmount lifecycle.
      _state?.willUnmount();
      _state = newWidget.createState();
      _state._config = newWidget;
      internalSetStateNode(_state, this);
      Node newChildWidget = _state.build();
      if (_child != null &&
          identical(newChildWidget.runtimeType,
              _child.widget.runtimeType)) {
        _child.update(newChildWidget);
      } else {
        _child?.detach();
        _child = newChildWidget.instantiate(this);
        _child.update(newChildWidget);
        _child.attach(this);
      }
    } else if (_isDirty) {
      _child.update(_state.build());
    } else if (hasDescendantsNeedingUpdate) {
      // Own widget is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.widget);
    }

    _isDirty = false;
    super.update(newWidget);
  }
}

typedef void GlobalKeyRemoveListener(GlobalKey key);

/// A GlobalKey is one that must be unique across the entire application. It is
/// used by components that need to communicate with other components across the
/// application's element
abstract class GlobalKey<T extends State<StatefulWidget>> extends Key {
  const GlobalKey.constructor()
      : super.constructor(); // so that subclasses can call us, since the Key() factory constructor shadows the implicit constructor

  /// Constructs a LabeledGlobalKey, which is a GlobalKey with a label used for debugging.
  /// The label is not used for comparing the identity of the key.
  factory GlobalKey({String debugLabel}) => new LabeledGlobalKey<T>(
      debugLabel); // the label is purely for debugging purposes and is otherwise ignored

  static final Map<GlobalKey, RenderNode> _registry =
      new Map<GlobalKey, RenderNode>();
  static final Map<GlobalKey, int> _debugDuplicates = new Map<GlobalKey, int>();
  static final Map<GlobalKey, Set<GlobalKeyRemoveListener>> _removeListeners =
      new Map<GlobalKey, Set<GlobalKeyRemoveListener>>();
  static final Set<GlobalKey> _removedKeys = new Set<GlobalKey>();

  void register(RenderNode element) {
    assert(() {
      if (_registry.containsKey(this)) {
        int oldCount = _debugDuplicates.putIfAbsent(this, () => 1);
        assert(oldCount >= 1);
        _debugDuplicates[this] = oldCount + 1;
      }
      return true;
    }());
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
    }());
    if (_registry[this] == element) {
      _registry.remove(this);
      _removedKeys.add(this);
    }
  }

  RenderNode get _currentTreeNode => _registry[this];
  Node get currentVirtualNode => _currentTreeNode?.widget;
  T get currentState {
    RenderNode element = _currentTreeNode;
    if (element is RenderStatefulWidget) {
      RenderStatefulWidget statefulElement = element;
      return statefulElement.state;
    }
    return null;
  }

  static void registerRemoveListener(
      GlobalKey key, GlobalKeyRemoveListener listener) {
    assert(key != null);
    Set<GlobalKeyRemoveListener> listeners = _removeListeners.putIfAbsent(
        key, () => new Set<GlobalKeyRemoveListener>());
    bool added = listeners.add(listener);
    assert(added);
  }

  static void unregisterRemoveListener(
      GlobalKey key, GlobalKeyRemoveListener listener) {
    assert(key != null);
    assert(_removeListeners.containsKey(key));
    bool removed = _removeListeners[key].remove(listener);
    if (_removeListeners[key].isEmpty) _removeListeners.remove(key);
    assert(removed);
  }

  static bool debugCheckForDuplicates() {
    String message = '';
    for (GlobalKey key in _debugDuplicates.keys) {
      message +=
          'The following GlobalKey was found multiple times among mounted elements: $key (${_debugDuplicates[key]} instances)\n';
      message +=
          'The most recently registered instance is: ${_registry[key]}\n';
    }
    if (!_debugDuplicates.isEmpty)
      throw new StateError('Incorrect GlobalKey usage: $message');
    return true;
  }

  static void notifyListeners() {
    if (_removedKeys.isEmpty) return;
    try {
      for (GlobalKey key in _removedKeys) {
        if (!_registry.containsKey(key) && _removeListeners.containsKey(key)) {
          Set<GlobalKeyRemoveListener> localListeners =
              new Set<GlobalKeyRemoveListener>.from(_removeListeners[key]);
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
  String toString() =>
      '[GlobalKey ${_debugLabel != null ? _debugLabel : hashCode}]';
}

/// A kind of [GlobalKey] that takes its identity from the object used as its value.
///
/// Used to tie the identity of a Widget to the identity of an object used to
/// generate that Widget.
class GlobalObjectKey extends GlobalKey {
  const GlobalObjectKey(this.value) : super.constructor();
  final Object value;
  bool operator ==(dynamic other) {
    if (other is! GlobalObjectKey) return false;
    final GlobalObjectKey typedOther = other;
    return identical(value, typedOther.value);
  }

  int get hashCode => identityHashCode(value);
  String toString() => '[$runtimeType ${value.runtimeType}(${value.hashCode})]';
}

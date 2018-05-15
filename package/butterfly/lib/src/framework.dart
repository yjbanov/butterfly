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
import 'surface.dart';

export 'key.dart';

/// Describes the state of the UI.
///
/// This class is at the core of the framework.
@immutable
abstract class Widget {
  const Widget({this.key});

  /// Identifies this widget among its siblings.
  final Key key;

  Renderer instantiate(ParentRenderer parent);
}

/// Translates [Widget] objects into [Surface] commands, and maintains the state
/// of the UI.
/// 
/// Renderers can have child renderers, thus forming a tree. The tree is
/// doubly-linked, i.e. the parent maintains references to its children, and
/// children maintain references to their parent. When a child is detached, this
/// cycle must be explicitly removed.
/// 
/// Renderers are persistent across frames. A renderer update the UI when its
/// [update] method is called with a widget containing the desired new state
/// of the UI. The render is responsible to compute the optimal surface updates
/// necessary to transition from the current UI state to the new UI state.
abstract class Renderer<N extends Widget> {
  Renderer(this._parent);

  /// The [Surface] that this renderer renders into.
  /// 
  /// There is a many-to-one correspondence between renderers and surfaces.
  /// Some renderers create new surfaces. Others "decorate" surfaces created
  /// by their child renderers.
  Surface get surface;

  /// The parent of this renderer.
  ParentRenderer get parent => _parent;
  ParentRenderer _parent;

  /// Visits _direct_ children of this renderer, if any.
  void visitChildren(void visitor(Renderer child));

  /// Disassociate this renderer from its parent.
  ///
  /// This operation can be used to temporarily remove renderers in order to move
  /// them around.
  void detach() {
    parent.surface.removeChild(surface);
    _parent == null;
    if (_widget.key is GlobalKey) {
      final GlobalKey key = _widget.key;
      key.unregister(this);
    }
  }

  /// Attached this node to a [newParent].
  void attach(ParentRenderer newParent) {
    assert(newParent != null);
    _parent = newParent;
  }

  /// The [Widget] that instantiated this renderer.
  N get widget => _widget;
  N _widget;

  /// Updates this renderer and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  @mustCallSuper
  void update(N newWidget) {
    assert(newWidget != null);
    _widget = newWidget;
    if (_widget.key is GlobalKey) {
      final GlobalKey key = _widget.key;
      key.register(this);
    }
  }
}

/// A widget built out of other [Widget]s and has no mutable state.
///
/// As a matter of good practice prefer making stateless widgets immutable, or
/// even better, support `const`. Because mutations on a stateless widget do not
/// make sense, immutabity sets the right expectation that the state cannot be
/// altered.
abstract class StatelessWidget extends Widget {
  const StatelessWidget({Key key}) : super(key: key);

  Renderer instantiate(ParentRenderer parent) => new StatelessWidgetRenderer(parent);

  Widget build();
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

  Renderer instantiate(ParentRenderer parent) => new StatefulWidgetRenderer(parent);
}

typedef dynamic StateSettingFunction();

/// Mutable state of a [StatefulWidget].
abstract class State<T extends StatefulWidget> {
  StatefulWidgetRenderer _renderer;

  T _config;
  T get config => _config;

  Widget build();

  @protected
  void setState(StateSettingFunction fn) {
    assert(() {
      if (fn == null) {
        throw new ArgumentError.notNull('fn');
      }
      return true;
    }());
    fn();
    _renderer.scheduleUpdate();
  }

  /// Lifecycle method called before the widget is unmounted in the DOM.
  ///
  /// Perform cleanup like canceling stream subscriptions here.
  void willUnmount() {}
}

class StatelessWidgetRenderer extends ParentRenderer<StatelessWidget> {
  StatelessWidgetRenderer(ParentRenderer parent) : super(parent);

  Renderer _child;

  @override
  Surface get surface => _child.surface;

  @override
  void visitChildren(void visitor(Renderer child)) {
    visitor(_child);
  }

  @override
  void update(StatelessWidget newWidget) {
    assert(newWidget != null);
    if (!identical(widget, newWidget)) {
      // Build the new widget and decide whether to reuse the child node
      // or replace with a new one.
      Widget newChildWidget = newWidget.build();
      assert(newChildWidget != null);
      if (_child != null && canUpdateRenderer(_child, newChildWidget)) {
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

class StatefulWidgetRenderer extends ParentRenderer<StatefulWidget> {
  StatefulWidgetRenderer(ParentRenderer parent) : super(parent);

  State _state;
  State get state => _state;
  Renderer _child;
  bool _isDirty = false;

  @override
  Surface get surface => _child.surface;

  @override
  void visitChildren(void visitor(Renderer child)) {
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
      _state._renderer = this;
      Widget newChildWidget = _state.build();
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

  static final Map<GlobalKey, Renderer> _registry =
      new Map<GlobalKey, Renderer>();
  static final Map<GlobalKey, int> _debugDuplicates = new Map<GlobalKey, int>();
  static final Map<GlobalKey, Set<GlobalKeyRemoveListener>> _removeListeners =
      new Map<GlobalKey, Set<GlobalKeyRemoveListener>>();
  static final Set<GlobalKey> _removedKeys = new Set<GlobalKey>();

  void register(Renderer element) {
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

  void unregister(Renderer element) {
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

  Renderer get _currentRenderer => _registry[this];
  Widget get currentWidget => _currentRenderer?.widget;
  T get currentState {
    Renderer element = _currentRenderer;
    if (element is StatefulWidgetRenderer) {
      StatefulWidgetRenderer statefulElement = element;
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


/// A widget that has a flat list of children.
@immutable
abstract class MultiChildWidget extends Widget {
  const MultiChildWidget({Key key, this.children}) : super(key: key);

  /// Child widgets of this widget.
  /// 
  /// To update the list of widgets, instead of mutating this list, create
  /// a new instance of this widget with the new list. The framework will
  /// automatically compute the minimal updates that need to be performed
  /// to update the UI.
  final List<Widget> children;
}

/// Whether [widget] can be updated from [widget].
///
/// This is used to decide whether a widget should be moved, replaced, removed or
/// updated using the new widget.
bool canUpdateRenderer(Renderer node, Widget widget) {
  if (!identical(node.widget.runtimeType, widget.runtimeType)) {
    return false;
  }

  return node.widget.key == widget.key;
}

/// A widget that has children.
abstract class ParentRenderer<N extends Widget> extends Renderer<N> {
  ParentRenderer(ParentRenderer parent) : super(parent);

  /// Whether any of this widget's descentant widgets need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

  // TODO(yjbanov): rename to setState
  void scheduleUpdate() {
    _hasDescendantsNeedingUpdate = true;
    ParentRenderer parent = _parent;
    while (parent != null) {
      parent._hasDescendantsNeedingUpdate = true;
      parent = parent.parent;
    }
  }

  /// Updates this widget and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` widget and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  @override
  @mustCallSuper
  void update(N newWidget) {
    _hasDescendantsNeedingUpdate = false;
    super.update(newWidget);
  }
}

/// A widget that decorates its child's element.
///
/// Contrast this class with [SingleChildParent], which creates its own element
/// that wraps that of its child.
@experimental
@immutable
abstract class Decoration extends Widget {
  const Decoration({Key key, @required this.child}) : super(key: key);

  /// The only child of this widget.
  ///
  /// Cannot be `null`.
  final Widget child;

  DecorationRenderer instantiate(ParentRenderer parent);
}

abstract class DecorationRenderer<N extends Decoration> extends ParentRenderer<N> {
  DecorationRenderer(ParentRenderer parent) : super(parent);

  Renderer _currentChild;

  @override
  Surface get surface => _currentChild.surface;

  @override
  void visitChildren(void visitor(Renderer child)) {
    if (_currentChild != null) {
      visitor(_currentChild);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    if (newWidget == _currentChild._widget) {
      if (hasDescendantsNeedingUpdate) {
        _currentChild.update(newWidget.child);
      }
      return;
    }

    final childConfig = newWidget.child;
    if (_currentChild == null || !canUpdateRenderer(_currentChild, childConfig)) {
      Renderer child = childConfig.instantiate(this);
      child.update(childConfig);
      child.attach(this);
      _currentChild = child;
    } else {
      _currentChild.update(childConfig);
    }

    super.update(newWidget);
  }
}

/// A superclass of widgets that render to a dedicated [Surface] object and do
/// not have children.
abstract class LeafWidget extends Widget {
  const LeafWidget({ Key key }) : super(key: key);

  LeafWidgetRenderer<LeafWidget> instantiate(ParentRenderer parent) => new LeafWidgetRenderer(parent);
}

/// A superclass of a renderer that renders a [LeafWidget].
class LeafWidgetRenderer<N extends LeafWidget> extends Renderer<N> {
  LeafWidgetRenderer(ParentRenderer<Widget> parent) : super(parent);

  @override
  final Surface surface = new Surface();

  @override
  void visitChildren(void Function(Renderer<Widget> child) visitor) {
    // This widget has no children.
  }
}

/// A widget that has exactly one child.
@immutable
abstract class SingleChildParent extends Widget {
  // TODO(yjbanov): assert non-null child when const assert are supported by dart2js
  const SingleChildParent({Key key, @required this.child}) : super(key: key);

  /// The only child of this widget.
  ///
  /// Cannot be `null`.
  final Widget child;

  RenderSingleChildParent instantiate(ParentRenderer parent);
}

abstract class RenderSingleChildParent<N extends SingleChildParent>
    extends ParentRenderer<N> {
  RenderSingleChildParent(ParentRenderer parent) : super(parent);

  Renderer _currentChild;

  @override
  void visitChildren(void visitor(Renderer child)) {
    if (_currentChild != null) {
      visitor(_currentChild);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    assert(newWidget != null);
    if (newWidget == _currentChild?._widget) {
      if (hasDescendantsNeedingUpdate) {
        _currentChild.update(newWidget.child);
      }
      return;
    }

    final childWidget = newWidget.child;
    if (_currentChild == null || !canUpdateRenderer(_currentChild, childWidget)) {
      if (_currentChild != null) {
        _currentChild.detach();
      }

      Renderer child = childWidget.instantiate(this);
      child.update(childWidget);
      child.attach(this);
      _currentChild = child;
    } else {
      _currentChild.update(childWidget);
    }

    super.update(newWidget);
  }
}

/// A widget that has multiple children.
abstract class MultiChildParentRenderer<N extends MultiChildWidget>
    extends ParentRenderer<N> {
  MultiChildParentRenderer(ParentRenderer parent) : super(parent);

  List<Renderer> _currentChildren;

  @override
  void visitChildren(void visitor(Renderer child)) {
    if (_currentChildren == null) {
      return;
    }

    for (Renderer child in _currentChildren) {
      visitor(child);
    }
  }

  @override
  @mustCallSuper
  void update(N newWidget) {
    if (!identical(widget, newWidget)) {
      List<Widget> newChildList = newWidget.children;

      if (newChildList != null &&
          newChildList.isNotEmpty &&
          _currentChildren == null) {
        _currentChildren = <Renderer>[];
      }

      if (_currentChildren == null || _currentChildren.isEmpty) {
        if (newChildList != null && newChildList.isNotEmpty) {
          _appendChildren(newChildList);
        }
      } else if (newChildList == null && newChildList.isEmpty) {
        if (_currentChildren != null && _currentChildren.isNotEmpty) {
          _removeAllCurrentChildren();
        }
      } else {
        // Both are not empty
        int from = 0;
        while (from < _currentChildren.length &&
            from < newChildList.length &&
            canUpdateRenderer(_currentChildren[from], newChildList[from])) {
          _currentChildren[from].update(newChildList[from]);
          from++;
        }

        if (from == _currentChildren.length) {
          if (from < newChildList.length) {
            // More children were added at the end, append them
            _appendChildren(newChildList.sublist(from));
          }
        } else if (from == newChildList.length) {
          // Some children at the end were removed, remove them
          for (int i = _currentChildren.length - 1; i >= from; i--) {
            _currentChildren[i].detach();
          }
          _currentChildren = _currentChildren.sublist(0, from);
        } else {
          // Walk lists from the end and try to update as much as possible
          int currTo = _currentChildren.length;
          int newTo = newChildList.length;
          while (currTo > from &&
              newTo > from &&
              canUpdateRenderer(
                  _currentChildren[currTo - 1], newChildList[newTo - 1])) {
            _currentChildren[currTo - 1].update(newChildList[newTo - 1]);
            currTo--;
            newTo--;
          }

          if (newTo == from && currTo > from) {
            // Some children in the middle were removed, remove them
            for (int i = currTo - 1; i >= from; i--) {
              _currentChildren[i].detach();
            }
            _currentChildren.removeRange(from, currTo);
          } else if (currTo == from && newTo > from) {
            // New children were inserted in the middle, insert them
            List<Widget> newChildren = newChildList.sublist(from, newTo);

            List<Renderer> insertedChildren = <Renderer>[];
            for (Widget vn in newChildren) {
              Renderer child = vn.instantiate(this);
              child.update(vn);
              child.attach(this);
              insertedChildren.add(child);
            }

            _currentChildren.insertAll(from, insertedChildren);

            Surface refNode = _currentChildren[newTo].surface;
            for (Renderer node in insertedChildren) {
              surface.insertBefore(node.surface, refNode);
            }
          } else {
            // We're strictly in the middle of both lists, at which point nodes
            // moved around, were added, or removed. If the nodes are keyed, map
            // them by key and figure out all the moves.

            // TODO: this implementation is very naive; it plucks _all_ children
            // and rearranges them according to new widget. A smarter
            // implementation would compute the minimum sufficient number of
            // moves to transform the tree into the desired widget configuration.

            List<Renderer> disputedRange = <Renderer>[];
            for (int i = from; i < currTo; i++) {
              Renderer child = _currentChildren[i];
              child.detach();
              disputedRange.add(child);
            }

            List<Renderer> newRange = <Renderer>[];
            Surface refNode = currTo < _currentChildren.length
                ? _currentChildren[currTo].surface
                : null;
            for (int i = from; i < newTo; i++) {
              Widget newChild = newChildList[i];
              // First try to fing an existing node that could be updated
              bool updated = false;
              for (Renderer child in disputedRange) {
                if (canUpdateRenderer(child, newChild)) {
                  child.update(newChild);
                  child.attach(this);
                  if (refNode == null) {
                    surface.append(child.surface);
                  } else {
                    surface.insertBefore(child.surface, refNode);
                  }
                  updated = true;
                  newRange.add(child);
                  break;
                }
              }

              if (!updated) {
                Renderer child = newChild.instantiate(this);
                child.update(newChild);
                child.attach(this);
                if (refNode == null) {
                  surface.append(child.surface);
                } else {
                  surface.insertBefore(child.surface, refNode);
                }
                newRange.add(child);
              }
            }

            _currentChildren = <Renderer>[]
              ..addAll(_currentChildren.sublist(0, from))
              ..addAll(newRange)
              ..addAll(_currentChildren.sublist(currTo));
            assert(_currentChildren.length == surface.childCount);
            assert(_currentChildren.length == newChildList.length);
          }
        }
      }
    } else if (hasDescendantsNeedingUpdate) {
      for (Renderer child in _currentChildren) {
        child.update(child.widget);
      }
    }
    super.update(newWidget);
  }

  void _appendChildren(List<Widget> newChildList) {
    assert(newChildList != null && newChildList.isNotEmpty);
    for (Widget vn in newChildList) {
      Renderer node = vn.instantiate(this);
      node.update(vn);
      node.attach(this);
      _currentChildren.add(node);
      surface.append(node.surface);
    }
  }

  void _removeAllCurrentChildren() {
    for (Renderer child in _currentChildren) {
      child.detach();
    }
    _currentChildren = <Renderer>[];
  }
}

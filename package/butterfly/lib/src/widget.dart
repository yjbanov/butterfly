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

/// A kind of node that's composed of other nodes.
abstract class Widget extends Node {
  const Widget({Key key}) : super(key: key);
}

abstract class InheritedWidget extends SingleChildParent {
  const InheritedWidget({ Key key, Widget child })
      : super(key: key, child: child);

  @override
  RenderInheritedWidget instantiate(Tree tree) => new RenderInheritedWidget(tree);

  /// Whether the framework should notify widgets that inherit from this widget.
  ///
  /// When this widget is rebuilt, sometimes we need to rebuild the widgets that
  /// inherit from this widget but sometimes we do not. For example, if the data
  /// held by this widget is the same as the data held by `oldWidget`, then then
  /// we do not need to rebuild the widgets that inherited the data held by
  /// `oldWidget`.
  ///
  /// The framework distinguishes these cases by calling this function with the
  /// widget that previously occupied this location in the tree as an argument.
  /// The given widget is guaranteed to have the same [runtimeType] as this
  /// object.
  @protected
  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

/// A [RenderNode] that uses an [InheritedWidget] as its configuration.
class RenderInheritedWidget extends RenderSingleChildParent<InheritedWidget> {
  RenderInheritedWidget(Tree tree) : super(tree);

  final Set<RenderNode> _dependents = new HashSet<RenderNode>();

  @override
  bool canUpdateUsing(Node node) {
    return node.runtimeType == this._configuration.runtimeType;
  }

  @override
  void _updateInheritance() {
    final Map<Type, RenderInheritedWidget> incomingWidgets = _parent?._inheritedWidgets;
    if (incomingWidgets != null)
      _inheritedWidgets = new HashMap<Type, RenderInheritedWidget>.from(incomingWidgets);
    else
      _inheritedWidgets = new HashMap<Type, RenderInheritedWidget>();
    assert(_configuration != null);
    _inheritedWidgets[_configuration.runtimeType] = this;
  }

  void notifyClients(InheritedWidget oldWidget) {
    if (!_configuration.updateShouldNotify(oldWidget))
      return;
    dispatchDidChangeDependencies();
  }

  @override
  void update(InheritedWidget newConfiguration) {
    final oldWidget = _configuration;
    super.update(newConfiguration);
    notifyClients(oldWidget);
  }

  /// Notifies all dependent elements that this inherited widget has changed.
  ///
  /// [RenderInheritedWidget] calls this function if [InheritedWidget.updateShouldNotify]
  /// returns true. This method may only be called during the build phase.
  void dispatchDidChangeDependencies() {
    for (RenderNode dependent in _dependents) {
      assert(() {
        // check that it really is our descendant
        RenderNode ancestor = dependent._parent;
        while (ancestor != this && ancestor != null)
          ancestor = ancestor._parent;
        return ancestor == this;
      }());
      // check that it really depends on us
      assert(dependent._dependencies.contains(this));
      dependent.didChangeDependencies();
    }
  }
}

/// A handle to the location of a widget in the widget tree.
abstract class BuildContext {
  InheritedWidget inheritFromWidgetOfExactType(Type targetType);
}

/// A widget built out of other [Node]s and has no mutable state.
///
/// As a matter of good practice prefer making stateless widgets immutable, or
/// even better, support `const`. Because mutations on a stateless widget do not
/// make sense, immutabity sets the right expectation that the state cannot be
/// altered.
abstract class StatelessWidget extends Widget {
  const StatelessWidget({Key key}) : super(key: key);

  RenderNode instantiate(Tree tree) => new RenderStatelessWidget(tree);

  Node build(BuildContext context);
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

  RenderNode instantiate(Tree tree) => new RenderStatefulWidget(tree);
}

typedef dynamic StateSettingFunction();

/// Mutable state of a [StatefulWidget].
abstract class State<T extends StatefulWidget> {
  RenderStatefulWidget _node;
  T _config;
  T get config => _config;

  Node build(BuildContext context);

  @protected
  void setState(StateSettingFunction fn) {
    assert(() {
      if (fn == null) {
        throw new ArgumentError.notNull('fn');
      }
      return true;
    });
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
  RenderStatelessWidget(Tree tree) : super(tree);

  RenderNode _child;

  @override
  html.Node get nativeNode => _child.nativeNode;

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    parent.replaceChildNativeNode(oldNode, replacement);
  }

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

  @override
  void dispatchEvent(Event event) {
    _child.dispatchEvent(event);
  }

  @override
  bool canUpdateUsing(Node node) {
    return node.runtimeType == this._configuration.runtimeType;
  }

  @override
  void update(StatelessWidget newConfiguration) {
    assert(newConfiguration != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      Node newChildConfiguration = newConfiguration.build(this);
      assert(newChildConfiguration != null);
      if (_child != null && _canUpdate(_child, newChildConfiguration)) {
        _child.update(newChildConfiguration);
      } else {
        // Replace child
        _child?.detach();
        _child = newChildConfiguration.instantiate(tree);
        _child.attach(this);
        _child.update(newChildConfiguration);
      }
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }
    super.update(newConfiguration);
  }
}

class RenderStatefulWidget extends RenderParent<StatefulWidget> {
  RenderStatefulWidget(Tree tree) : super(tree);

  State _state;
  State get state => _state;
  RenderNode _child;
  bool _isDirty = false;

  @override
  html.Node get nativeNode => _child.nativeNode;

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    parent.replaceChildNativeNode(oldNode, replacement);
  }

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

  @override
  void dispatchEvent(Event event) {
    _child.dispatchEvent(event);
  }

  void scheduleUpdate() {
    _isDirty = true;
    super.scheduleUpdate();
  }

  @override
  bool canUpdateUsing(Node node) {
    return node.runtimeType == this._configuration.runtimeType;
  }

  void update(StatefulWidget newConfiguration) {
    assert(newConfiguration != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      // If there is an existing configuration, call it's #willUnmount lifecycle.
      _state?.willUnmount();
      _state = newConfiguration.createState();
      _state._config = newConfiguration;
      internalSetStateNode(_state, this);
      Node newChildConfiguration = _state.build(this);
      if (_child != null &&
          identical(newChildConfiguration.runtimeType,
              _child.configuration.runtimeType)) {
        _child.update(newChildConfiguration);
      } else {
        _child?.detach();
        _child = newChildConfiguration.instantiate(tree);
        _child.attach(this);
        _child.update(newChildConfiguration);
      }
    } else if (_isDirty) {
      _child.update(_state.build(this));
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }

    _isDirty = false;
    super.update(newConfiguration);
  }
}

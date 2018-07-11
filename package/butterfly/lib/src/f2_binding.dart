// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:meta/meta.dart';

import 'f2.dart';

class WidgetsBinding {
  WidgetsBinding._(this.hostElement);

  static WidgetsBinding get instance => _instance;
  static WidgetsBinding _instance;

  final html.Element hostElement;

  static void initialize({html.Element hostElement}) {
    hostElement ??= html.document.body;
    _instance = WidgetsBinding._(hostElement);
  }

  /// The [BuildOwner] in charge of executing the build pipeline for the
  /// widget tree rooted at this binding.
  BuildOwner get buildOwner => _buildOwner;
  final BuildOwner _buildOwner = new BuildOwner();

  /// Whether we are currently in a frame. This is used to verify
  /// that frames are not scheduled redundantly.
  ///
  /// This is public so that test frameworks can change it.
  ///
  /// This flag is not used in release builds.
  @protected
  bool debugBuildingDirtyElements = false;

  void drawFrame() {
    assert(!debugBuildingDirtyElements);
    assert(() {
      debugBuildingDirtyElements = true;
      return true;
    }());
    try {
      if (renderViewElement != null)
        buildOwner.buildScope(renderViewElement);
      buildOwner.finalizeTree();
    } finally {
      assert(() {
        debugBuildingDirtyElements = false;
        return true;
      }());
    }
  }

  /// The [Element] that is at the root of the hierarchy (and which wraps the
  /// [RenderView] object at the root of the rendering hierarchy).
  ///
  /// This is initialized the first time [runApp] is called.
  Element get renderViewElement => _renderViewElement;
  Element _renderViewElement;

  /// Takes a widget and attaches it to the [renderViewElement], creating it if
  /// necessary.
  ///
  /// This is called by [runApp] to configure the widget tree.
  ///
  /// See also [RenderObjectToWidgetAdapter.attachToRenderTree].
  void attachRootWidget(Widget rootWidget) {
    RenderView renderView = new RenderView(hostElement);
    _renderViewElement = new RenderObjectToWidgetAdapter(
      container: renderView,
      debugShortDescription: '[root]',
      child: rootWidget
    ).attachToRenderTree(buildOwner, renderViewElement);
  }
}

/// The root render object.
class RenderView extends RenderObject {
  RenderView(html.Element hostElement) : super(hostElement);
}

/// A bridge from a [RenderObject] to an [Element] tree.
///
/// The given container is the [RenderObject] that the [Element] tree should be
/// inserted into. It must be a [RenderObject] that implements the
/// [RenderObjectWithChildMixin] protocol. The type argument `T` is the kind of
/// [RenderObject] that the container expects as its child.
///
/// Used by [runApp] to bootstrap applications.
class RenderObjectToWidgetAdapter extends RenderObjectWidget {
  /// Creates a bridge from a [RenderObject] to an [Element] tree.
  ///
  /// Used by [WidgetsBinding] to attach the root widget to the [RenderView].
  RenderObjectToWidgetAdapter({
    this.child,
    this.container,
    this.debugShortDescription
  }) : super(key: new GlobalObjectKey(container));

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The [RenderObject] that is the parent of the [Element] created by this widget.
  final RenderView container;

  /// A short description of this widget used by debugging aids.
  final String debugShortDescription;

  @override
  RenderObjectToWidgetElement createElement() => new RenderObjectToWidgetElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => container;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) { }

  /// Inflate this widget and actually set the resulting [RenderObject] as the
  /// child of [container].
  ///
  /// If `element` is null, this function will create a new element. Otherwise,
  /// the given element will have an update scheduled to switch to this widget.
  ///
  /// Used by [runApp] to bootstrap applications.
  RenderObjectToWidgetElement attachToRenderTree(BuildOwner owner, [RenderObjectToWidgetElement element]) {
    if (element == null) {
      owner.lockState(() {
        element = createElement();
        assert(element != null);
        element.assignOwner(owner);
      });
      owner.buildScope(element, () {
        element.mount(null, null);
      });
    } else {
      element._newWidget = this;
      element.markNeedsBuild();
    }
    return element;
  }

  @override
  String toStringShort() => debugShortDescription ?? super.toStringShort();
}

/// A [RootRenderObjectElement] that is hosted by a [RenderObject].
///
/// This element class is the instantiation of a [RenderObjectToWidgetAdapter]
/// widget. It can be used only as the root of an [Element] tree (it cannot be
/// mounted into another [Element]; it's parent must be null).
///
/// In typical usage, it will be instantiated for a [RenderObjectToWidgetAdapter]
/// whose container is the [RenderView] that connects to the Flutter engine. In
/// this usage, it is normally instantiated by the bootstrapping logic in the
/// [WidgetsFlutterBinding] singleton created by [runApp].
class RenderObjectToWidgetElement extends RootRenderObjectElement {
  /// Creates an element that is hosted by a [RenderObject].
  ///
  /// The [RenderObject] created by this element is not automatically set as a
  /// child of the hosting [RenderObject]. To actually attach this element to
  /// the render tree, call [RenderObjectToWidgetAdapter.attachToRenderTree].
  RenderObjectToWidgetElement(RenderObjectToWidgetAdapter widget) : super(widget);

  @override
  RenderObjectToWidgetAdapter get widget => super.widget;

  Element _child;

  static const Object _rootChildSlot = const Object();

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null)
      visitor(_child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    assert(parent == null);
    super.mount(parent, newSlot);
    _rebuild();
  }

  @override
  void update(RenderObjectToWidgetAdapter newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _rebuild();
  }

  // When we are assigned a new widget, we store it here
  // until we are ready to update to it.
  Widget _newWidget;

  @override
  void performRebuild() {
    if (_newWidget != null) {
      // _newWidget can be null if, for instance, we were rebuilt
      // due to a reassemble.
      final Widget newWidget = _newWidget;
      _newWidget = null;
      update(newWidget);
    }
    super.performRebuild();
    assert(_newWidget == null);
  }

  void _rebuild() {
    try {
      _child = updateChild(_child, widget.child, _rootChildSlot);
      assert(_child != null);
    } catch (exception, stack) {
      final FlutterErrorDetails details = new FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'widgets library',
        context: 'attaching to the render tree'
      );
      FlutterError.reportError(details);
      final Widget error = ErrorWidget.builder(details);
      _child = updateChild(null, error, _rootChildSlot);
    }
  }

  @override
  RenderObject get renderObject => super.renderObject;

  @override
  void insertChildRenderObject(RenderObject child, dynamic slot) {
    assert(slot == _rootChildSlot);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    assert(renderObject.child == child);
    renderObject.child = null;
  }
}

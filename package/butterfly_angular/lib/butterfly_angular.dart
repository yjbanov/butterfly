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

/// Support for placing Angular components in a Butterfly application.
library butterfly_angular;

import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:angular/src/core/application_ref.dart';
import 'package:angular/src/di/injector/hierarchical.dart';
import 'package:angular/src/di/injector/injector.dart';
import 'package:angular/src/platform/dom/events/event_manager.dart';
import 'package:butterfly/butterfly.dart';
import 'package:logging/logging.dart';
import 'package:angular/src/core/linker/app_view_utils.dart' as ng;

// Statics needed for Angular Component.
NgZone _zone;
ApplicationRefImpl _application;
PlatformRefImpl _platform;
_RootInjector _injector;
ExceptionHandler _exceptionHandler;
bool _isAngularInitialized = false;

/// Initializes Angular's dependencies.
///
/// This should be called once in `main`, before calling [runApp].
/// Calling this function multiple times is not supported.
void bootstrapAngular() {
  assert(!_isAngularInitialized);
  _injector = new _RootInjector();
  _exceptionHandler = new ExceptionHandler(Logger.root);
  _zone = createNgZone();
  ng.appViewUtils = new ng.AppViewUtils(
      'lazy_tortoise', null, new EventManager(const [], _zone));
  _platform = new PlatformRefImpl();
  createPlatform(_injector);
  _application = new ApplicationRefImpl(_platform, _zone, _injector);
  _isAngularInitialized = true;
}

/// The root of an Angular application.
///
/// Any child [AngularWidget] widgets must have this as a parent.
class AngularApplicationWidget extends MultiChildNode {
  /// A single injector which is provided to all child elements.
  ///
  /// TODO(jonahwilliams): use `BuildContext` to provide this to children.
  final Injector injector;

  const AngularApplicationWidget({this.injector, List<Widget> children, key})
      : super(key: key, children: children);

  @override
  RenderNode instantiate(Tree tree) => new AngularApplicationRenderNode(tree);
}

/// A render node for an Angular Application.
///
/// Makes Angular dependencies availible to child elements.
///
/// TODO(jonahwilliams): replace with single child node or decoration when
/// those interfaces are ready.
class AngularApplicationRenderNode
    extends RenderMultiChildParent<AngularApplicationWidget> {
  AngularApplicationRenderNode(Tree tree) : super(tree) {
    assert(_isAngularInitialized);
  }

  @override
  bool canUpdateUsing(Node node) => node is AngularApplicationWidget;

  @override
  final html.Node nativeNode = new html.DivElement();
}

/// A specialized injector to provide Angular platform dependencies.
class _RootInjector extends Injector implements HierarchicalInjector {
  const _RootInjector();

  @override
  dynamic get(Object token, [throwsNotFound]) {
    if (identical(token, ApplicationRef)) {
      return _application;
    }
    if (identical(token, PlatformRef)) {
      return _platform;
    }
    if (identical(token, NgZone)) {
      return _zone;
    }
    if (identical(token, PLATFORM_INITIALIZER)) {
      return null;
    }
    if (identical(token, ExceptionHandler)) {
      return _exceptionHandler;
    }
    if (identical(token, APP_INITIALIZER)) {
      return const [];
    }
    return throwIfNotFound;
  }

  @override
  Object injectOptional(Object token, [Object orElse]) => null;

  @override
  T inject<T>(Object token) => null;

  @override
  T injectFromAncestry<T>(Object token) {
    return null;
  }

  @override
  Object injectFromAncestryOptional(Object token,
      [Object orElse = throwIfNotFound]) {
    return null;
  }

  @override
  T injectFromParent<T>(Object token) {
    return null;
  }

  @override
  Object injectFromParentOptional(Object token,
      [Object orElse = throwIfNotFound]) {
    return null;
  }

  @override
  T injectFromSelf<T>(Object token) {
    return null;
  }

  @override
  Object injectFromSelfOptional(Object token,
      [Object orElse = throwIfNotFound]) {
    return null;
  }

  @override
  HierarchicalInjector get parent => null;
}

/// A base class for placing an Angular component into a widget tree.
abstract class AngularWidget extends Widget {
  const AngularWidget({Key key}) : super(key: key);

  @override
  AngularRenderNode instantiate(Tree tree);
}

/// A [RenderNode] for an [AngularWidget].
///
/// Extend this class to map widget configuration to Angular `@Input`s and
/// `@Output`s.
///
/// TODO(jonahwilliams): handle attach and detach with a [GlobalKey].
abstract class AngularRenderNode<T extends AngularWidget, S>
    extends RenderNode<T> {
  /// Override with the [ComponentFactory] exported from the Angular template
  /// file (generated code).
  ///
  /// Updating this field is not supported, so generally this should be
  /// static or point directly towards the .template.dart file.
  ComponentFactory get componentFactory;

  /// A list of html nodes to be projected into `ng-content`.
  ///
  /// Angular does not support dynamically updating projected values.  This
  /// should generally point towards a static list of [html.Element].
  List<List<html.Node>> get projectedNodes => const [];

  /// Override with a specific [Injector] instance.
  ///
  /// Otherwise provides an empty [Injector].
  Injector get injector => const Injector.empty();

  html.Node _nativeNode;
  ComponentRef<S> componentRef;

  AngularRenderNode(Tree tree) : super(tree);

  @override
  void dispatchEvent(Event event) {}

  @override
  html.Node get nativeNode => _nativeNode;

  /// The Angular component instance.
  ///
  /// Guaranteed to be non-null by the first call to [update].
  S get componentInstance => componentRef.instance;

  @override
  void attach(RenderParent parent) {
    componentRef = componentFactory.create(injector, projectedNodes);
    _nativeNode = componentRef.location;
    _application.registerChangeDetector(componentRef.changeDetectorRef);
    super.attach(parent);
  }

  @override
  void detach() {
    _application.unregisterChangeDetector(componentRef.changeDetectorRef);
    componentRef.destroy();
    super.detach();
  }

  @override
  bool canUpdateUsing(Node node) => node is AngularWidget;

  @override
  void visitChildren(void visitor(RenderNode child)) {}
}

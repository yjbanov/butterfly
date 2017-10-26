import 'dart:html' as html;
import 'package:angular/angular.dart';
import 'package:angular/src/core/application_ref.dart';
import 'package:angular/src/di/injector/hierarchical.dart';
import 'package:angular/src/di/injector/injector.dart';
import 'package:angular/src/platform/dom/events/event_manager.dart';
import 'package:butterfly/butterfly.dart';
import 'package:meta/meta.dart';
import 'package:logging/logging.dart';
import 'package:angular/src/core/linker/app_view_utils.dart' as ng;

/// The root of an Angular application.
///
/// Any child [AngularWidget] widgets must have this as a parent.
class AngularApplicationWidget extends MultiChildNode {
  const AngularApplicationWidget({@required List<Widget> children, key})
      : super(key: key, children: children);

  @override
  RenderNode instantiate(Tree tree) => new AngularApplicationRenderNode(tree);
}

/// Statics needed for Angular Component.
/// TODO(jonahwilliams): replace when `BuildContext` like API is availible.
NgZone _zone;
NgZone get zone => _zone;

ApplicationRefImpl _application;
ApplicationRefImpl get application => _application;

PlatformRefImpl _platform;
PlatformRefImpl get platform => _platform;

_RootInjector _injector = const _RootInjector();
Injector get rootInjector => _injector;

ExceptionHandler _exceptionHandler = new ExceptionHandler(Logger.root);
ExceptionHandler get exceptionHandler => _exceptionHandler;

///

class AngularApplicationRenderNode
    extends RenderMultiChildParent<AngularApplicationWidget> {
  AngularApplicationRenderNode(Tree tree) : super(tree) {
    _zone = createNgZone();
    ng.appViewUtils =
        new ng.AppViewUtils('', null, new EventManager(const [], _zone));
    _platform = new PlatformRefImpl();
    createPlatform(_injector);
    _application = new ApplicationRefImpl(_platform, _zone, _injector);
  }

  @override
  bool canUpdateUsing(Node node) => identical(node, configuration);

  // TODO: implement nativeNode
  @override
  final html.Node nativeNode = new html.DivElement();
}

class _RootInjector extends Injector implements HierarchicalInjector {
  static final ExceptionHandler _exceptionHandler =
      new ExceptionHandler(Logger.root);

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

  // TODO: implement parent
  @override
  HierarchicalInjector get parent => null;
}

abstract class AngularWidget extends Widget {
  ComponentFactory get componentFactory;

  const AngularWidget({Key key}) : super(key: key);

  @override
  AngularRenderNode instantiate(Tree tree);
}

class AngularRenderNode<T extends AngularWidget> extends RenderNode<T> {
  html.Node _nativeNode;
  ComponentRef componentRef;

  AngularRenderNode(Tree tree, AngularWidget widget, Injector injector)
      : super(tree) {
    componentRef = widget.componentFactory.create(injector);
    _nativeNode = componentRef.location;
    _application.registerChangeDetector(componentRef.changeDetectorRef);
  }

  @override
  void dispatchEvent(Event event) {}

  @override
  html.Node get nativeNode => _nativeNode;

  @override
  void update(T newConfiguration) {
    super.update(newConfiguration);
  }

  @override
  void detach() {
    _application.unregisterChangeDetector(componentRef.changeDetectorRef);
    componentRef.destroy();
  }

  @override
  bool canUpdateUsing(Node node) => node is AngularWidget;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    // TODO: implement visitChildren
  }
}

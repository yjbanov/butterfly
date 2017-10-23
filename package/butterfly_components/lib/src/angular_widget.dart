import 'dart:html' as html;
import 'package:angular/angular.dart';
import 'package:butterfly/butterfly.dart';

abstract class AngularWidget extends Node {
  final String name;
  final List<Node> projected;
  
  const AngularWidget({Key key, this.name, this.projected = const []}) : super(key: key);
  
  @override
  AngularRenderNode instantiate(Tree tree);
}

class AngularRenderNode<T extends AngularWidget, S> extends RenderNode<T> {
  html.Node _nativeNode;
  ComponentRef<S> componentRef;
  
  AngularRenderNode(Tree tree, ComponentFactory componentFactory) : super(tree) {
    componentRef = componentFactory.create(const Injector.empty());
    _nativeNode = componentRef.location;
  }

  @override
  bool canUpdateUsing(Node node) => node is AngularWidget && node.name == configuration.name;

  @override
  void dispatchEvent(Event event) {}

  @override
  html.Node get nativeNode => _nativeNode ;
  set nativeNode(html.Node node) => _nativeNode = node;

  @override
  void visitChildren(void visitor(RenderNode child)) {}

  @override
  void detach() {
    componentRef.destroy();
  }
}
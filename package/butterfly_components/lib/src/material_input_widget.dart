import './angular_widget.dart';
import 'package:angular/src/di/injector/injector.dart';
import 'package:butterfly/butterfly.dart';
import 'package:angular/src/core/linker/component_factory.dart';
import 'package:angular_components/material_input/material_input.template.dart';

class MaterialInputWidget extends AngularWidget {
  const MaterialInputWidget({Key key}) : super(key: key);

  @override
  ComponentFactory get componentFactory => MaterialInputComponentNgFactory;

  @override
  AngularRenderNode instantiate(Tree tree) => new MaterialInputWidgetRenderNode(
      tree, this, new Injector.map(const {}, rootInjector));
}

class MaterialInputWidgetRenderNode
    extends AngularRenderNode<MaterialInputWidget> {
  MaterialInputWidgetRenderNode(
      Tree tree, AngularWidget widget, Injector injector)
      : super(tree, widget, injector);
}

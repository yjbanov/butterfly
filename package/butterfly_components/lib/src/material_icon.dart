import 'package:butterfly/butterfly.dart';
import 'package:butterfly_components/src/angular_widget.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_icon/material_icon.template.dart';
import 'package:angular/angular.dart';
import 'package:meta/meta.dart';
import 'dart:html' as html;

class MaterialIconWidget extends AngularWidget {
  final String size;
  final dynamic icon;
  final bool flip;
  final bool light;

  const MaterialIconWidget({
    Key key,
    this.size = '',
    @required this.icon,
    this.flip = false,
    this.light = false,
  })
      : super(key: key);

  @override
  AngularRenderNode instantiate(Tree tree) => new MaterialIconRenderNode(tree);
}

class MaterialIconRenderNode
    extends AngularRenderNode<MaterialIconWidget, MaterialIconComponent> {
  MaterialIconRenderNode(Tree tree) : super(tree, MaterialIconComponentNgFactory);

  @override
  void update(MaterialIconWidget newConfiguration) {
    if (configuration == null) {
      MaterialIconComponent instance = componentRef.instance;
      instance.icon = newConfiguration.icon;
      html.Element el = nativeNode;
      el
        ..setAttribute('size', newConfiguration.size)
        ..setAttribute('flip', newConfiguration.flip ? '' : null)
        ..setAttribute('light', newConfiguration.light ? '' : null);
    } else if (!identical(newConfiguration, configuration)) {
      MaterialIconComponent instance = componentRef.instance;
      if (!identical(newConfiguration.icon, configuration.icon)) {
        instance.icon = newConfiguration.icon;
      }
      html.Element el = nativeNode;
      el
        ..setAttribute('size', newConfiguration.size)
        ..setAttribute('flip', newConfiguration.flip ? '' : null)
        ..setAttribute('light', newConfiguration.light ? '' : null);
    }
    super.update(newConfiguration);
  }
}

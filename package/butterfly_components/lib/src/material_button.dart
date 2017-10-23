import 'dart:async';

import 'package:butterfly/butterfly.dart';
import 'dart:html' as html;
import 'angular_widget.dart';
import 'package:meta/meta.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_button/material_button.template.dart';

class MaterialButtonWidget extends AngularWidget {
  final bool raised;
  final bool disabled;
  final bool tabbable;
  final String tabIndex;

  // !!!!!DO NOT USE TEAR-OFF!!!!!s
  final void Function(html.UIEvent) onTrigger;

  const MaterialButtonWidget({
    Key key,
    this.raised = false,
    this.disabled = false,
    this.tabbable = true,
    this.tabIndex,
    @required this.onTrigger,
  })
      : super(key: key, name: 'material-button');

  @override
  MaterialButtonRenderNode instantiate(Tree tree) =>
      new MaterialButtonRenderNode(tree);
}

class MaterialButtonRenderNode
    extends AngularRenderNode<MaterialButtonWidget, MaterialButtonComponent> {
  StreamSubscription _onTrigger;

  MaterialButtonRenderNode(Tree tree) : super(tree, MaterialButtonComponentNgFactory);

  @override
  void update(MaterialButtonWidget newConfiguration) {
    if (configuration == null) {
      MaterialButtonComponent instance = componentRef.instance;
      instance
        ..raised = newConfiguration.raised
        ..disabled = newConfiguration.disabled
        ..tabbable = newConfiguration.tabbable;
      if (newConfiguration.tabIndex != null) {
        instance.tabindex = newConfiguration.tabIndex;
      }
      _onTrigger = instance.trigger.listen(newConfiguration.onTrigger);
      componentRef.changeDetectorRef.markForCheck();
    } else if (!identical(newConfiguration, configuration)) {
      MaterialButtonComponent instance = componentRef.instance;
      if (configuration.raised != newConfiguration.raised) {
        instance.raised = newConfiguration.raised;
      }
      if (configuration.disabled != newConfiguration.disabled) {
        instance.disabled = newConfiguration.disabled;
      }
      if (configuration.tabbable != newConfiguration.tabbable) {
        instance.tabbable = newConfiguration.tabbable;
      }
      if (configuration.tabIndex != newConfiguration.tabIndex) {
        instance.tabindex = newConfiguration.tabIndex;
      }
      if (!identical(newConfiguration.onTrigger, configuration.onTrigger)) {
        _onTrigger?.cancel();
        _onTrigger = instance.trigger.listen(newConfiguration.onTrigger);
      }
    }
    super.update(newConfiguration);
  }

  @override
  void detach() {
    _onTrigger?.cancel();
    super.detach();
  }
}

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_button/material_button.template.dart';
import 'package:angular_components/theme/dark_theme.dart';
import 'package:butterfly/butterfly.dart';
import 'dart:html' as html;
import 'angular_widget.dart';
import 'package:meta/meta.dart';

class MaterialButtonWidget extends AngularWidget {
  @override
  ComponentFactory get componentFactory => MaterialButtonComponentNgFactory;

  final bool raised;
  final bool disabled;
  final bool tabbable;
  final String tabIndex;
  final void Function(html.UIEvent) onTrigger;

  const MaterialButtonWidget({
    Key key,
    this.raised = false,
    this.disabled = false,
    this.tabbable = true,
    this.tabIndex,
    @required this.onTrigger,
  })
      : super(key: key);

  @override
  MaterialButtonRenderNode instantiate(Tree tree) =>
      new MaterialButtonRenderNode(tree, this);
}

class MaterialButtonRenderNode extends AngularRenderNode<MaterialButtonWidget> {
  StreamSubscription _onTrigger;
  

  MaterialButtonRenderNode(Tree tree, AngularWidget widget)
      : super(
          tree,
          widget,
          new Injector.map({
            AcxDarkTheme: new AcxDarkTheme(false),
          }, rootInjector),
        );

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

  @override
  bool canUpdateUsing(Node node) => node is MaterialButtonWidget;
}

import 'package:butterfly/butterfly.dart';
import 'package:butterfly_components/butterfly_components.dart';
import 'dart:html' as html;

class App extends StatefulWidget {

  @override
  State createState() => new AppState();
}

class AppState extends State<App> {
  bool toggled = false;
  void Function(html.UIEvent) onTrigger;
  MaterialButtonWidget _button;

  AppState() {
    onTrigger = (_) {
      this.setState(() {
        toggled = !toggled;
      });
    };
    _button = new MaterialButtonWidget(onTrigger: onTrigger);
  }
  
  @override
  Node build() {
    return div()([
      span()([
        text(toggled ? 'Toggled' : 'Not Toggled')
      ]),
      _button,
    ]);
  }
}
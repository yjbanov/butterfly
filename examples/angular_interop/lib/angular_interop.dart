import 'package:butterfly/butterfly.dart';
import 'package:butterfly_components/butterfly_components.dart';
import 'dart:html' as html;

class App extends StatefulWidget {
  const App();

  @override
  State createState() => new AppState();
}

class AppState extends State<App> {
  bool toggled = false;
  bool disabled = false;
  void Function(html.UIEvent) onTrigger;

  AppState() {
    onTrigger = (_) {
      this.setState(() {
        toggled = !toggled;
      });
    };
  }

  @override
  Node build() {
    return div()([
      div()([text(toggled ? 'Toggled' : 'Not Toggled')]),
      new AngularApplicationWidget(
        children: [
          new MaterialButtonWidget(onTrigger: onTrigger, raised: true),
        ],
      ),
    ]);
  }
}

import 'dart:html' as html;
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:butterfly/butterfly.dart';
import 'package:angular_interop/angular_interop.dart';

void main() {
  bootstrap(AppComponent);
}

@Component(selector: 'foo', template: '')
class AppComponent implements OnInit {
  final html.Element _element;

  AppComponent(this._element);

  @override
  void ngOnInit() {
    runApp(new App(), _element);
  }
}

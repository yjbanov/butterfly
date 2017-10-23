import 'dart:async';
import 'dart:html' as html;

import 'package:butterfly/butterfly.dart';
import 'package:angular_interop/angular_interop.dart';

Future<Null> main() async {
  runApp(new App(), html.querySelector('#app-host'));
}

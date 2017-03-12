import 'package:butterfly/butterfly.dart';

class Dx implements Node {
  Dx(String value);

  @override
  Key get key => null;

  @override
  instantiate(_) {
    return null;
  }
}

class MyElement extends StatelessWidget {
  @override
  Node build() {
    return text('foo');
  }
}

class ExampleWidget extends StatelessWidget {
  @override
  Node build() {
    var local = 'foo';
    return div()([
      new MyElement(),
      text("test"),
      text((233).toString()),
      text((22 + 23).toString())
    ]);
  }
}

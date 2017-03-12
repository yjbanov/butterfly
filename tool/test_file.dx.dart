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


class ExampleWidget extends StatelessWidget {

  @override
  Node build() {
    var local = 'foo';
    return new Dx('''
    <div>
      <MyElement bazz=${local}></MyElement>
      ${"test"}
      ${(233).toString()}
      ${(22 + 23).toString()}
    </div>
    ''');
  }
}

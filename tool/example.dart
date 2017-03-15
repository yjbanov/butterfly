import 'package:butterfly/butterfly.dart';

class FooWidget extends StatelessWidget {
  @override
  Node build() {
    var local = false;
    var bar = 2;
    var items = [1, 2, 3].map((x) => text("${x}")).toList();

    return new MyComponent(foo: bar)([
      text("This is text"),
      element('div')(),
      element('polymer-element')(),
      text("SO IS THIS"),
      text("${local}"),
      new NestedComponent()(items)
    ]);
  }
}

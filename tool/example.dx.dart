import 'package:butterfly/butterfly.dart';

class FooWidget extends StatelessWidget {
  @override
  Node build() {
    var local = false;
    var bar = 2;
    var items = [1, 2, 3].map((x) => Dx('''"${x}"''')).toList();

    return Dx('''
      <MyComponent foo=${bar}>
        "This is text"
        <div></div>
        <polymer-element/>
        "SO IS THIS"
        "${local}"
        <NestedComponent>
          ${items}
        </NestedComponent>
      </MyComponent>
    ''');
  }
}

# butterfly_angular

A library for integrating 

## Usage

A simple usage example:
```dart
    import 'package:butterfly/butterfly.dart';
    import 'package:butterfly_angular/butterfly_angular.dart';
    import './my_component.template.dart';

    /// A [Widget] which describes the configuration of the Angular component.
    class MyComponentWidget extends AngularWidget {
      final bool someInput;
      final void Function(String) someOutput;

      MyComponentWidget({
        @required this.someOutput,
        this.someInput = false,
        Key key}) : super(key: key);
    }

    /// A [RenderNode] which maps configuration options to the component
    /// instance.
    class MyComponentRenderNode extends AngularRenderNode<MyComponentWidget, MyComponent> {
      StreamSubscription _someOutputSub;

      @override
      ComponentFactory get componentFactory => MyComponentNgFactory;

      MyComponentRenderNode(Tree tree) : super(tree);

      @override
      void update(MyComponentWidget newConfiguration) {
        if (!identical(newConfiguration.someInput, configuration?.someInput)) {
          componentInstance.someInput = newConfiguration.someInput;
        }
        if (!identical(newConfiguration.someOutput, configuration?.someOutput)) {
          _someOutputSub?.cancel();
          _someOutputSub = componentInstance.someOutput.listen(newConfiguration.someOutput);
        }
      }

      @override
      void detach() {
        _someOutputSub?.cancel();
        super.detach();
      }
    }
    
    void printHello(String value) {
      print(value);
    }

    main() {
      bootstrapAngular();
      runApp(div()([
        const MyComponentWidget(someInput: true, someOutput: printHello),
      ]), selector);
    }
```

## Features and bugs


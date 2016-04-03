// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('browser')

import 'dart:html' as html;

import 'package:test/test.dart';

import 'package:butterfly/butterfly.dart';
import 'package:butterfly/testing.dart';

main() {
  group('text', () {
    test('renders simple text', () {
      ApplicationTester tester = runTestApp(new SimpleTextWidget());
      expect(tester.innerHtml, 'hello world!');
    });

    test('renders changing text', () {
      var widget = new ChangingTextWidget();
      ApplicationTester tester = runTestApp(widget);
      expect(tester.innerHtml, 'initial');

      // Repeated re-renders without actual change should be a noop
      tester.renderFrame();
      expect(tester.innerHtml, 'initial');

      // Now with the actual change
      widget.state.value = 'updated';
      expect(tester.innerHtml, 'initial', reason: 'have not rendered yet');
      tester.renderFrame();
      expect(tester.innerHtml, 'updated');
    });
  });

  group('element', () {
    test('renders simple element', () {
      expect(
        runTestApp(new SimpleElementWidget()).innerHtml,
        '<div></div>'
      );
    });

    test('renders nested elements', () {
      expect(
        runTestApp(new NestedElementWidget()).innerHtml,
        '<div><span></span><button></button></div>'
      );
    });

    test('updates the native nodes with new configuration', () {
      var widget = new NodeUpdatingWidget();
      var tester = runTestApp(widget);
      expect(tester.innerHtml, '<div>initial</div>');
      html.Element div1 = tester.hostElement.childNodes.single;
      html.Text text1 = div1.childNodes.single;

      widget.state.value = 'updated';
      tester.renderFrame();
      expect(tester.innerHtml, '<div>updated</div>');

      html.Element div2 = tester.hostElement.childNodes.single;
      html.Text text2 = div2.childNodes.single;
      expect(div2, same(div1));
      expect(text2, same(text1));
    });

  });

  group('MultiChildNode', () {
    test('does not update if config is identical', () {
      var tester = runTestApp(new IdenticalConfigElement());
      UpdateTrackingRenderText trackingNode = tester.findNodeOfType(UpdateTrackingRenderText);

      expect(tester.innerHtml, '<div>never updated</div>');
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
    });

    test('updates children if descendants need update', () {
      var widget = new ElementWithTrackingChild();
      var tester = runTestApp(widget);
      RenderParent statefulNode = tester.findNodeOfConfigurationType(ElementWithTrackingChild);
      UpdateTrackingRenderText trackingNode1 = tester.findNodeOfType(UpdateTrackingRenderText);
      expect(trackingNode1.updateCount, 1);

      statefulNode.scheduleUpdate();
      tester.renderFrame();

      UpdateTrackingRenderText trackingNode2 = tester.findNodeOfType(UpdateTrackingRenderText);
      expect(trackingNode2, same(trackingNode1));
      expect(trackingNode2.updateCount, 2);
    });

    group('child list diffing', () {
      ApplicationTester tester;
      ChildListWidgetState listState;

      setUp(() {
        var widget = new ChildListWidget();
        listState = widget.state;
        tester = runTestApp(widget);
      });

      tearDown(() {
        tester = null;
        listState = null;
      });

      testKeys(List<int> keys) {
        listState.childKeys = keys;
        tester.renderFrame();
        var innerHtml = keys
          .map((key) => '<span>${key}</span>')
          .join();
        expect(tester.innerHtml, '<div>${innerHtml}</div>');
      }

      test('appends new children added to previously empty child list', () {
        testKeys([]);
        testKeys([1, 2, 3]);
      });

      test('appends new children added to previously non-empty child list', () {
        testKeys([1, 2]);
        testKeys([1, 2, 3, 4, 5]);
      });

      test('deletes all children', () {
        testKeys([1, 2]);
        testKeys([]);
      });

      test('updates all children with the same key', () {
        testKeys([1, 2, 3]);
        testKeys([1, 2, 3]);
      });

      test('truncates child list', () {
        testKeys([1, 2, 3, 4, 5]);
        testKeys([1, 2, 3]);
      });

      test('removes children in the middle', () {
        testKeys([1, 2, 3, 4]);
        testKeys([1, 4]);
      });

      test('inserts children in the middle', () {
        testKeys([1, 4]);
        testKeys([1, 2, 3, 4]);
      });

      test('replaces range with a longer range', () {
        testKeys([1, 2, 3, 4, 9]);
        testKeys([1, 5, 6, 7, 8, 9]);
      });

      test('replaces range with a shorter range', () {
        testKeys([1, 2, 3, 4]);
        testKeys([1, 10, 4]);
      });

      test('moves children', () {
        testKeys([1, 2, 3, 4, 5]);
        testKeys([1, 4, 3, 2, 5]);
      });
    });
  });

  group('attributes', () {
    test('are set', () {
      expect(
        runTestApp(new SimpleAttributesWidget()).innerHtml,
        '<div id="this_is_id" width="300"></div>'
      );
    });
  });

  group('props', () {
    test('are set', () {
      var widget = new ElementPropsWidget();
      var tester = runTestApp(widget);
      html.InputElement input = tester.querySelectorAll('input').single;
      expect(input.value, 'foo');
      expect(input.checked, true);

      widget.state.value = 'bar';
      widget.state.checked = false;
      widget.state.scheduleUpdate();
      tester.renderFrame();

      expect(input.value, 'bar');
      expect(input.checked, false);
    });
  });

  group('events', () {
    test('are captured by listeners', () {
      var widget = new EventListeningWidget();
      var tester = runTestApp(widget);
      expect(tester.innerHtml, '<button>0</button>');

      var button = tester.querySelector('button') as html.ButtonElement;
      button.click();

      tester.renderFrame();
      expect(tester.innerHtml, '<button>1</button>');
    });
  });
}

class UpdateTrackingRenderText extends RenderText {
  UpdateTrackingRenderText(Tree tree, Text config) : super(tree, config);

  int updateCount = 0;

  @override
  void update(Text newConfig) {
    updateCount++;
    super.update(newConfig);
  }
}

class UpdateTrackingText extends Text {
  const UpdateTrackingText(String value) : super(value);

  RenderNode instantiate(Tree tree) => new UpdateTrackingRenderText(tree, this);
}

class IdenticalConfigElement extends StatelessWidget {
  static const updateTracker = const UpdateTrackingText('never updated');
  static const config = const Element(
    'div',
    children: const [updateTracker]
  );
  build() => config;
}

class SimpleTextWidget extends StatelessWidget {
  Node build() => text('hello world!');
}

class ChangingTextWidget extends StatefulWidget {
  final ChangingTextWidgetState state = new ChangingTextWidgetState();

  ChangingTextWidgetState createState() => state;
}

class ChangingTextWidgetState extends State<ChangingTextWidget> {
  String _value = 'initial';
  set value(String newValue) {
    _value = newValue;
    scheduleUpdate();
  }

  Node build() => text(_value);
}

class SimpleElementWidget extends StatelessWidget {
  Node build() => div()();
}

class NestedElementWidget extends StatelessWidget {
  Node build() => div()([
    span()(),
    button()(),
  ]);
}

class SimpleAttributesWidget extends StatelessWidget {
  Node build() => div(attrs: {
    'id': 'this_is_id',
    'width': '300',
  })();
}

class NodeUpdatingWidget extends StatefulWidget {
  final NodeUpdatingWidgetState state = new NodeUpdatingWidgetState();
  NodeUpdatingWidgetState createState() => state;
}

class NodeUpdatingWidgetState extends State<NodeUpdatingWidget> {
  String _value = 'initial';
  set value(String newValue) {
    _value = newValue;
    scheduleUpdate();
  }

  Node build() => div()([
    text(_value)
  ]);
}

class ChildListWidget extends StatefulWidget {
  ChildListWidgetState state = new ChildListWidgetState();

  ChildListWidgetState createState() => state;
}

class ChildListWidgetState extends State<ChildListWidget> {
  List<int> _childKeys;
  set childKeys(List<int> keys) {
    _childKeys = keys;
    scheduleUpdate();
  }

  Node build() {
    if (_childKeys == null) {
      return new Element('div');
    }

    return div()(
      _childKeys
        .map((key) => new Element(
          'span',
          key: new ValueKey(key),
          children: [text(key.toString())]
        ))
        .toList()
    );
  }
}

class ElementWithTrackingChild extends StatelessWidget {
  Node build() => new UpdateTrackingText('foo');
}

class ElementPropsWidget extends StatefulWidget {
  ElementPropsWidgetState state = new ElementPropsWidgetState();
  ElementPropsWidgetState createState() => state;
}

class ElementPropsWidgetState extends State<ElementPropsWidget> {
  String value = 'foo';
  bool checked = true;

  Node build() {
    return checkbox(
      attrs: const {
        'id': 'first-name',
      },
      props: (p) => p
        ..value = value
        ..checked = checked
    )();
  }
}

class EventListeningWidget extends StatefulWidget {
  EventListeningWidgetState createState() => new EventListeningWidgetState();
}

class EventListeningWidgetState extends State<EventListeningWidget> {
  int counter = 0;

  Node build() {
    return button(
      eventListeners: {
        EventType.click: (Event event) {
          expect(event.nativeEvent is html.MouseEvent, isTrue);
          counter++;
          scheduleUpdate();
        }
      }
    )([
      text('$counter')
    ]);
  }
}

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

import 'package:test/test.dart';

import 'package:butterfly/butterfly.dart';
import 'package:butterfly/testing.dart';

main() {
  group('text', () {
    test('renders simple text', () {
      WidgetTester tester = testWidget(new SimpleTextWidget());
      tester.expectRenderCreate('<span>hello world!</span>');
    });

    test('renders changing text', () {
      var widget = new ChangingTextWidget();
      WidgetTester tester = testWidget(widget);
      tester.expectRenderCreate('<span>initial</span>');

      // Repeated re-renders without actual change should be a noop
      tester.renderFrame();
      tester.expectRenderNoop();

      // Now with the actual change
      widget.state.value = 'updated';
      tester.expectRenderUpdate(new ElementUpdate(0)..updateText('updated'));
    });
  });

  group('element', () {
    test('renders simple element', () {
      final tester = testWidget(new SimpleElementWidget());
      tester.expectRenderCreate('<div></div>');
    });

    test('renders nested elements', () {
      final tester = testWidget(new NestedElementWidget());
      tester.expectRenderCreate('<div><span></span><button></button></div>');
    });
  });

  group('MultiChildNode', () {
    test('does not update if config is identical', () {
      var tester = testWidget(new IdenticalConfigElement());

      tester.expectRenderCreate('<div><span>never updated</span></div>');

      UpdateTrackingRenderText trackingNode =
          tester.findNodeOfType(UpdateTrackingRenderText);
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
    });

    test('updates children if descendants need update', () {
      var widget = new ElementWithTrackingChild();
      var tester = testWidget(widget);

      tester.renderFrame();

      RenderParent statefulNode =
          tester.findNodeOfConfigurationType(ElementWithTrackingChild);
      UpdateTrackingRenderText trackingNode1 =
          tester.findNodeOfType(UpdateTrackingRenderText);
      expect(trackingNode1.updateCount, 1);

      statefulNode.scheduleUpdate();
      tester.renderFrame();

      UpdateTrackingRenderText trackingNode2 =
          tester.findNodeOfType(UpdateTrackingRenderText);
      expect(trackingNode2, same(trackingNode1));
      expect(trackingNode2.updateCount, 2);
    });

    group('child list diffing', () {
      WidgetTester tester;
      ChildListWidgetState listState;

      setUp(() {
        var widget = new ChildListWidget();
        listState = widget.state;
        tester = testWidget(widget);
      });

      tearDown(() {
        tester = null;
        listState = null;
      });

      testCreate(List<int> keys) {
        listState.childKeys = keys;
        var innerHtml =
            keys.map((key) => '<span _bkey="${key}">${key}</span>').join();
        tester.expectRenderCreate('<div>${innerHtml}</div>');
      }

      testUpdate({
        List<int> keys = const [],
        Map<int, int> inserts = const {},
        Map<int, int> moves = const {},
        List<int> removes = const [],
      }) {
        listState.setState(() {
          listState.childKeys = keys;
        });
        final update = new ElementUpdate(0);
        inserts.forEach((int key, int position) {
          update.insertChildElement(position)
            ..tag = 'span'
            ..key = new ValueKey('$key')
            ..updateText('$key');
        });
        moves.forEach((int from, int to) {
          update.moveChild(to, from);
        });
        removes.forEach(update.removeChild);
        tester.expectRenderUpdate(update);
      }

      test('appends new children added to previously empty child list', () {
        testCreate([]);
        testUpdate(keys: [
          1,
          2,
          3
        ], inserts: {
          1: 0,
          2: 0,
          3: 0,
        });
      });

      test('appends new children added to previously non-empty child list', () {
        testCreate([1, 2]);
        testUpdate(keys: [
          1,
          2,
          3,
          4,
          5
        ], inserts: {
          3: 2,
          4: 2,
          5: 2,
        });
      });

      test('deletes all children', () {
        testCreate([1, 2]);
        testUpdate(keys: [], removes: [0, 1]);
      });

      test('truncates child list', () {
        testCreate([0, 1, 2, 3, 4]);
        testUpdate(keys: [0, 1, 2], removes: [3, 4]);
      });

      test('removes children in the middle', () {
        testCreate([0, 1, 2, 3]);
        testUpdate(keys: [0, 3], removes: [1, 2]);
      });

      test('inserts children in the middle', () {
        testCreate([1, 4]);
        testUpdate(keys: [
          1,
          2,
          3,
          4
        ], inserts: {
          2: 1,
          3: 1,
        });
      });

      test('replaces range with a longer range', () {
        testCreate([1, 2, 3, 4, 9]);
        testUpdate(keys: [
          1,
          5,
          6,
          7,
          8,
          9
        ], removes: [
          1,
          2,
          3
        ], inserts: {
          5: 4,
          6: 4,
          7: 4,
          8: 4,
        });
      });

      test('replaces range with a shorter range', () {
        testCreate([1, 2, 3, 4]);
        testUpdate(keys: [
          1,
          10,
          4
        ], removes: [
          1,
          2
        ], inserts: {
          10: 3,
        });
      });

      test('moves children', () {
        testCreate([1, 2, 3, 4, 5]);
        testUpdate(keys: [
          1,
          4,
          3,
          2,
          5
        ], moves: {
          3: 1,
          2: 1,
        });
      });
    });
  });

  group('attributes', () {
    test('are set', () {
      testWidget(new SimpleAttributesWidget())
          .expectRenderCreate('<div id="this_is_id" width="300"></div>');
    });
  });

  group('events', () {
    test('are captured by listeners', () {
      final widget = new EventListeningWidget();
      final tester = testWidget(widget);

      tester.renderFrame();

      final EventListeningWidgetState state =
          tester.findStateOfType(EventListeningWidgetState);
      expect(state.counter, 0);

      RenderElement buttonElement = tester.findElementNode(byTag: 'button');
      tester.module.dispatchEvent({
        'type': 'click',
        'bid': buttonElement.baristaId,
      });

      tester.renderFrame();
      expect(state.counter, 1);
    });
  });

  group('style', () {
    test('applies single style', () {
      var s = new Style('width: 10px;');
      var widget = new WidgetWithStyle(s);
      var tester = testWidget(widget);
      tester.expectRenderCreate('<div class="${s.identifierClass}"></div>');
    });
  });

  group('styles', () {
    Style s1, s2, s3, s4, s5;
    WidgetWithMultipleStyles widget;

    setUp(() {
      widget = new WidgetWithMultipleStyles();
      s1 = new Style('width: 10px;');
      s2 = new Style('height: 50px;');
      s3 = new Style('color: green;');
      s4 = new Style('max-height: 500px;');
      s5 = new Style('min-height: 10px;');
    });

    void testStyles(List<Style> styles) {
      widget.state.styles = styles;
      var tester = testWidget(widget);
      var buf = new StringBuffer();
      buf.write('<div');
      if (styles != null && styles.isNotEmpty) {
        buf.write(' class="');
        buf.write(styles.map((s) => s.identifierClass).join(' '));
        buf.write('"');
      }
      buf.write('></div>');
      tester.expectRenderCreate(buf.toString());
    }

    test('applies multiple styles', () {
      testStyles([s1, s2]);
    });

    test('appends styles from null', () {
      testStyles(null);
      testStyles([s1, s2]);
    });

    test('appends styles from empty', () {
      testStyles([]);
      testStyles([s1, s2]);
    });

    test('removes styles to null', () {
      testStyles([s1, s2]);
      testStyles(null);
    });

    test('removes styles to empty', () {
      testStyles([s1, s2]);
      testStyles([]);
    });

    test('inserts styles', () {
      testStyles([s1, s5]);
      testStyles([s1, s2, s3, s4, s5]);
    });

    test('removes styles in the middle', () {
      testStyles([s1, s2, s3, s4, s5]);
      testStyles([s1, s5]);
    });

    test('shuffles styles', () {
      testStyles([s1, s2, s3, s4]);
      testStyles([s4, s3, s1, s2]);
    });
  });
}

class WidgetWithStyle extends StatelessWidget {
  WidgetWithStyle(this.style);

  Style style;

  build() => div(style: style)();
}

class WidgetWithMultipleStyles extends StatefulWidget {
  final state = new WidgetWithMultipleStylesState();
  createState() => state;
}

class WidgetWithMultipleStylesState extends State {
  List<Style> styles;

  build() => div(styles: styles)();
}

class UpdateTrackingRenderText extends RenderElement {
  UpdateTrackingRenderText(Tree tree) : super(tree);

  int updateCount = 0;

  @override
  void update(Element newConfig, ElementUpdate update) {
    updateCount++;
    super.update(newConfig, update);
  }
}

class UpdateTrackingText extends Element {
  UpdateTrackingText(String text) : super('span', text: text);

  RenderNode instantiate(Tree tree) => new UpdateTrackingRenderText(tree);
}

class IdenticalConfigElement extends StatelessWidget {
  static final updateTracker = new UpdateTrackingText('never updated');
  static final config = new Element('div', children: [updateTracker]);
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
    setState(() {
      _value = newValue;
    });
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
    setState(() {
      _value = newValue;
    });
  }

  Node build() => div()([text(_value)]);
}

class ChildListWidget extends StatefulWidget {
  ChildListWidgetState state = new ChildListWidgetState();

  ChildListWidgetState createState() => state;
}

class ChildListWidgetState extends State<ChildListWidget> {
  List<int> _childKeys;
  set childKeys(List<int> keys) {
    _childKeys = keys;
  }

  @override
  setState(StateSettingFunction fn) {
    super.setState(fn);
  }

  Node build() {
    if (_childKeys == null) {
      return new Element('div');
    }

    return div()(_childKeys
        .map((key) =>
            new Element('span', key: new ValueKey(key), text: key.toString()))
        .toList());
  }
}

class ElementWithTrackingChild extends StatelessWidget {
  Node build() => new UpdateTrackingText('foo');
}

class EventListeningWidget extends StatefulWidget {
  EventListeningWidgetState createState() => new EventListeningWidgetState();
}

class EventListeningWidgetState extends State<EventListeningWidget> {
  int counter = 0;

  _buttonClicked(Event event) {
    setState(() {
      counter++;
    });
  }

  Node build() {
    return button(eventListeners: {EventType.click: _buttonClicked})(
        [text('$counter')]);
  }
}

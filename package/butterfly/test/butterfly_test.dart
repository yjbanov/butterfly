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
      tester.expectRenders('<div><div>hello world!</div></div>');
    });

    test('renders changing text', () {
      var widget = new ChangingTextWidget();
      WidgetTester tester = testWidget(widget);
      tester.expectRenders('<div><div>initial</div></div>');

      // Repeated re-renders without actual change should be a noop
      tester.renderFrame();
      tester.expectRenderNoop();

      // Now with the actual change
      widget.state.value = 'updated';
      tester.expectRenders('<div><div>updated</div></div>');
    });
  });

  group('surface', () {
    test('renders simple surface', () {
      final tester = testWidget(new SimpleSurfaceWidget());
      tester.expectRenders('<div><div></div></div>');
    });

    test('renders nested surface', () {
      final tester = testWidget(new NestedElementWidget());
      tester.expectRenders('<div><div><div>a</div><div>b</div></div></div>');
    });
  });

  group('MultiChildWidget', () {
    test('does not update if config is identical', () {
      var tester = testWidget(new IdenticalConfigElement());

      tester.expectRenders('<div><div><div>never updated</div></div></div>');

      UpdateTrackingRenderText trackingNode =
          tester.findRenderWidgetOfType(UpdateTrackingRenderText);
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

      ParentRenderer statefulNode =
          tester.findWidgetOfType(ElementWithTrackingChild);
      UpdateTrackingRenderText trackingNode1 =
          tester.findRenderWidgetOfType(UpdateTrackingRenderText);
      expect(trackingNode1.updateCount, 1);

      statefulNode.scheduleUpdate();
      tester.renderFrame();

      UpdateTrackingRenderText trackingNode2 =
          tester.findRenderWidgetOfType(UpdateTrackingRenderText);
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
        var innerHtml = keys.map((key) => '<div>${key}</div>').join();
        tester.expectRenders('<div><div>${innerHtml}</div></div>');
      }

      testUpdate(List<int> keys) {
        listState.setState(() {
          listState.childKeys = keys;
        });
        var innerHtml = keys.map((key) => '<div>${key}</div>').join();
        tester.expectRenders('<div><div>${innerHtml}</div></div>');
      }

      test('appends new children added to previously empty child list', () {
        testCreate([]);
        testUpdate([1, 2, 3]);
      });

      test('appends new children added to previously non-empty child list', () {
        testCreate([1, 2]);
        testUpdate([1, 2, 3, 4, 5]);
      });

      test('deletes all children', () {
        testCreate([1, 2]);
        testUpdate([]);
      });

      test('truncates child list', () {
        testCreate([0, 1, 2, 3, 4]);
        testUpdate([0, 1, 2]);
      });

      test('removes children in the middle', () {
        testCreate([0, 1, 2, 3]);
        testUpdate([0, 3]);
      });

      test('inserts children in the middle', () {
        testCreate([1, 4]);
        testUpdate([1, 2, 3, 4]);
      });

      test('replaces range with a longer range', () {
        testCreate([1, 2, 3, 4, 9]);
        testUpdate([1, 5, 6, 7, 8, 9]);
      });

      test('replaces range with a shorter range', () {
        testCreate([1, 2, 3, 4]);
        testUpdate([1, 10, 4]);
      });

      test('moves children', () {
        testCreate([1, 2, 3, 4, 5]);
        testUpdate([1, 4, 3, 2, 5]);
      });
    });
  });
}

class UpdateTrackingText extends Text {
  UpdateTrackingText(String text) : super(text);

  TextRenderer instantiate(ParentRenderer parent) => new UpdateTrackingRenderText(parent, this);
}

class UpdateTrackingRenderText extends TextRenderer {
  UpdateTrackingRenderText(ParentRenderer parent, UpdateTrackingText element)
      : super(parent, element);

  int updateCount = 0;

  @override
  void update(Text newConfig) {
    updateCount++;
    super.update(newConfig);
  }
}

class IdenticalConfigElement extends StatelessWidget {
  static final updateTracker = new UpdateTrackingText('never updated');
  static final config = new Row(children: [updateTracker]);
  build() => config;
}

class SimpleTextWidget extends StatelessWidget {
  Widget build() => new Text('hello world!');
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

  Widget build() => new Text(_value);
}

class SimpleSurfaceWidget extends LeafWidget {}

class NestedElementWidget extends StatelessWidget {
  Widget build() => new TestListLike(
    children: <Widget>[
      new Text('a'),
      new Text('b'),
    ],
  );
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

  Widget build() => new Container(
    child: new Text(_value),
  );
}

class ChildListWidget extends StatefulWidget {
  final ChildListWidgetState state = new ChildListWidgetState();

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

  Widget build() {
    if (_childKeys == null) {
      return TestListLike();
    }

    return new TestListLike(
      children: _childKeys
        .map<Widget>((key) => new Text(key.toString(), key: new ValueKey(key)))
        .toList(),
    );
  }
}

class ElementWithTrackingChild extends StatelessWidget {
  Widget build() => new UpdateTrackingText('foo');
}

/// A dummy container of a flat list of children.
class TestListLike extends MultiChildWidget {
  TestListLike({
    Key key,
    List<Widget> children,
    this.decoration,
  }) : super(
    key: key,
    children: children,
  );

  final BoxDecoration decoration;

  @override
  TestListLikeRenderer instantiate(ParentRenderer parent) => new TestListLikeRenderer(parent);
}

class TestListLikeRenderer extends MultiChildParentRenderer<TestListLike> {
  TestListLikeRenderer(ParentRenderer parent) : super(parent);

  @override
  final Surface surface = new Surface();

  @override
  void update(TestListLike newWidget) {
    if (widget != null) {
      final BoxDecoration oldDecoration = widget.decoration;
      final BoxDecoration newDecoration = newWidget.decoration;
      if (!identical(oldDecoration, newDecoration)) {
        oldDecoration.update(newDecoration, surface);
      }
    } else {}
    super.update(newWidget);
  }
}

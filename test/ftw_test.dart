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

import 'package:flutter_ftw/ftw.dart';
import 'package:flutter_ftw/testing.dart';
import 'package:flutter_ftw/src/tree.dart' as tree;

main() {
  group('text', () {
    test('renders simple text', () {
      ApplicationTester tester = runTestApp(new SimpleTextWidget());
      expect(tester.html, 'hello world!');
    });

    test('renders changing text', () {
      var widget = new ChangingTextWidget();
      ApplicationTester tester = runTestApp(widget);
      expect(tester.html, 'initial');

      // Repeated re-renders without actual change should be a noop
      tester.renderFrame();
      expect(tester.html, 'initial');

      // Now with the actual change
      widget.state.value = 'updated';
      expect(tester.html, 'initial', reason: 'have not rendered yet');
      tester.renderFrame();
      expect(tester.html, 'updated');
    });
  });

  group('element', () {
    test('renders simple element', () {
      expect(
        runTestApp(new SimpleElementWidget()).html,
        '<div></div>'
      );
    });

    test('renders nested elements', () {
      expect(
        runTestApp(new NestedElementWidget()).html,
        '<div><span></span><button></button></div>'
      );
    });

    test('updates the native nodes with new configuration', () {
      var widget = new NodeUpdatingWidget();
      var tester = runTestApp(widget);
      expect(tester.html, '<div>initial</div>');
      html.Element div1 = tester.hostElement.childNodes.single;
      html.Text text1 = div1.childNodes.single;

      widget.state.value = 'updated';
      tester.renderFrame();
      expect(tester.html, '<div>updated</div>');

      html.Element div2 = tester.hostElement.childNodes.single;
      html.Text text2 = div2.childNodes.single;
      expect(div2, same(div1));
      expect(text2, same(text1));
    });

  });

  group('MultiChildNode', () {
    test('does not update if config is identical', () {
      var tester = runTestApp(new IdenticalConfigElement());
      UpdateTrackingTextNode trackingNode = tester.findNodeOfType(UpdateTrackingTextNode);

      expect(tester.html, '<div>never updated</div>');
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
      tester.renderFrame();
      expect(trackingNode.updateCount, 1);
    });

    test('updates children if descendants need update', () {
      var widget = new ElementWithTrackingChild();
      var tester = runTestApp(widget);
      tree.ParentNode statefulNode = tester.findNodeOfConfigurationType(ElementWithTrackingChild);
      UpdateTrackingTextNode trackingNode1 = tester.findNodeOfType(UpdateTrackingTextNode);
      expect(trackingNode1.updateCount, 1);

      statefulNode.scheduleUpdate();
      tester.renderFrame();

      UpdateTrackingTextNode trackingNode2 = tester.findNodeOfType(UpdateTrackingTextNode);
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
        expect(tester.html, '<div>${innerHtml}</div>');
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
        runTestApp(new SimpleAttributesWidget()).html,
        '<div id="this_is_id" width="300"></div>'
      );
    });
  });
}

class UpdateTrackingTextNode extends tree.TextNode {
  UpdateTrackingTextNode(Text config) : super(config);

  int updateCount = 0;

  @override
  void update(Text newConfig) {
    updateCount++;
    super.update(newConfig);
  }
}

class UpdateTrackingText extends Text {
  const UpdateTrackingText(String value) : super(value);

  tree.Node instantiate() => new UpdateTrackingTextNode(this);
}

class IdenticalConfigElement extends StatelessWidget {
  static const updateTracker = const UpdateTrackingText('never updated');
  static const config = const VirtualElement(
    'div',
    children: const [updateTracker]
  );
  build() => config;
}

class SimpleTextWidget extends StatelessWidget {
  VirtualNode build() => text('hello world!');
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

  VirtualNode build() => text(_value);
}

class SimpleElementWidget extends StatelessWidget {
  VirtualNode build() => div();
}

class NestedElementWidget extends StatelessWidget {
  VirtualNode build() => div([
    span(),
    button(),
  ]);
}

class SimpleAttributesWidget extends StatelessWidget {
  VirtualNode build() => div({
    'id': 'this_is_id',
    'width': '300',
  });
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

  VirtualNode build() => div([
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

  VirtualNode build() {
    if (_childKeys == null) {
      return new VirtualElement('div');
    }

    return div(_childKeys
      .map((key) => new VirtualElement(
        'span',
        key: new ValueKey(key),
        children: [text(key.toString())]
      ))
      .toList()
    );
  }
}

class ElementWithTrackingChild extends StatelessWidget {
  VirtualNode build() => new UpdateTrackingText('foo');
}

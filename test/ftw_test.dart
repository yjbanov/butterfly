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

  group('attributes', () {
    test('are set', () {
      expect(
        runTestApp(new SimpleAttributesWidget()).html,
        '<div id="this_is_id" width="300"></div>'
      );
    });
  });
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

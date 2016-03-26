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
      ChangingTextWidgetState state = new ChangingTextWidgetState();
      ApplicationTester tester = runTestApp(
        new ChangingTextWidget()..state = state
      );
      expect(tester.html, 'initial');

      // Repeated re-renders without actual change should be a noop
      tester.renderFrame();
      expect(tester.html, 'initial');

      // Now with the actual change
      state.value = 'updated';
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
  VirtualNode build() => const Text('hello world!');
}

class ChangingTextWidget extends StatefulWidget {
  ChangingTextWidgetState state;

  ChangingTextWidgetState createState() => state;
}

class ChangingTextWidgetState extends State<ChangingTextWidget> {
  String _value = 'initial';
  set value(String newValue) {
    _value = newValue;
    scheduleUpdate();
  }

  VirtualNode build() => new Text(_value);
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

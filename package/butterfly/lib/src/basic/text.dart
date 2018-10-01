// Copyright 2017 Google Inc. All Rights Reserved.
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

import 'dart:html' as html;

import '../f2.dart';

/// A section of text.
class Text extends LeafRenderObjectWidget {
  final String value;

  const Text(this.value, {Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderText()
      ..text = value;
  }

  @override
  void updateRenderObject(BuildContext context, RenderText renderObject) {
    renderObject.text = value;
  }
}

/// Renders text into a `<p>` tag.
class RenderText extends RenderObject {
  RenderText() : super(html.ParagraphElement());

  String get text => _text;
  String _text;
  set text(String newValue) {
    if (identical(newValue, _text)) {
      return;
    }
    element.text = newValue;
    _text = newValue;
  }
}

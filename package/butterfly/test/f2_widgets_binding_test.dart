// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:test/test.dart';

import 'package:butterfly/src/f2.dart';
import 'package:butterfly/src/f2_widgets_binding.dart';
import 'testing.dart';

void main() {
  test('$WidgetsBinding draws a frame', () {
    final host = html.DivElement();
    WidgetsBinding.initialize(hostElement: host);
    WidgetsBinding.instance
      ..attachRootWidget(_P())
      ..drawFrame();
    expectHtml(
      WidgetsBinding.instance.renderViewElement.renderObject,
      '<div><p></p></div>',
    );
  });
}

class _P extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderP();
  }
}

class _RenderP extends RenderObject {
  _RenderP() : super(html.Element.tag('p'));
}

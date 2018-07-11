import 'package:test/test.dart';

import 'package:butterfly/src/f2_object.dart';

void expectHtml(RenderObject renderObject, String html) {
  expect(debugGetRenderObjectHtml(renderObject), html);
}

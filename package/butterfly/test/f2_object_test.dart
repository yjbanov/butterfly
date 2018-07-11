// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:test/test.dart';

import 'package:butterfly/src/f2_object.dart';
import 'testing.dart';

RenderObject testParent, a, b, c, x, y, z;

void main() {
  group(RenderObject, () {
    setUp(() {
      testParent = _P();
      html.document.body.append(testParent.element);
      a = _A();
      b = _B();
      c = _C();
      x = _X();
      y = _Y();
      z = _Z();
    });

    tearDown(() {
      testParent.element.remove();
    });

    group('insert', () {
      _insertTests();
    });

    group('remove', () {
      _removeTests();
    });

    group('move', () {
      _moveTests();
    });

    group('iterator', () {
      test('iterates over children', () {
        testParent..insert(z)..insert(y)..insert(x);
        expect(testParent.toList(), [x, y, z]);
      });

      test('is empty when there are no children', () {
        expect(testParent.toList(), []);
      });

      test('throws when child is removed during iteration', () {
        testParent.insert(x);
        final iterator = testParent.iterator;
        expect(iterator.moveNext(), true);
        expect(iterator.current, x);
        testParent.remove(x);
        expect(
          () => iterator.moveNext(),
          throwsConcurrentModificationError,
        );
      });

      test('throws when child is moved to another parent', () {
        final p1 = _P()..insert(c)..insert(b)..insert(a);
        final p2 = _P()..insert(z)..insert(y)..insert(x);

        final iterator = p1.iterator;
        expect(iterator.moveNext(), true);
        expect(iterator.moveNext(), true);
        expect(iterator.current, b);

        p1.remove(b);
        p2.insert(b, after: y);

        expect(
          () => iterator.moveNext(),
          throwsConcurrentModificationError,
        );
      });
    });

    group('hasChildren', () {
      test('is false when there are no children', () {
        expect(testParent.hasChildren, false);
      });

      test('is true when there are children', () {
        testParent.insert(x);
        expect(testParent.hasChildren, true);
      });
    });
  });
}

void _insertTests() {
  test('a few children at the end', () {
    testParent.insert(x);
    expectHtml(testParent, '<p><x></x></p>');
    expect(testParent.firstChild, x);
    expect(x.previousSibling, null);
    expect(x.nextSibling, null);
    expect(x.parent, testParent);

    testParent.insert(y, after: x);
    expectHtml(testParent, '<p><x></x><y></y></p>');
    expect(testParent.firstChild, x);
    expect(x.previousSibling, null);
    expect(x.nextSibling, y);
    expect(y.previousSibling, x);
    expect(y.nextSibling, null);
    expect(x.parent, testParent);
    expect(y.parent, testParent);

    testParent.insert(z, after: y);
    expectHtml(
      testParent,
      '<p><x></x><y></y><z></z></p>',
    );
    expect(y.nextSibling, z);
    expect(z.nextSibling, null);
    expect(z.previousSibling, y);
  });

  test('a few children at the start', () {
    testParent.insert(x);
    expectHtml(
      testParent,
      '<p><x></x></p>',
    );
    expect(testParent.firstChild, x);

    testParent.insert(y);
    expectHtml(
      testParent,
      '<p><y></y><x></x></p>',
    );
    expect(testParent.firstChild, y);

    testParent.insert(z);
    expectHtml(
      testParent,
      '<p><z></z><y></y><x></x></p>',
    );
    expect(testParent.firstChild, z);
    for (var child in [x, y, z]) {
      expect(child.parent, testParent);
    }
    expect(z.nextSibling, y);
    expect(y.nextSibling, x);
    expect(x.nextSibling, null);
    expect(x.previousSibling, y);
    expect(y.previousSibling, z);
    expect(z.previousSibling, null);
  });

  test('in the middle', () {
    testParent.insert(x);
    testParent.insert(y, after: x);
    expectHtml(
      testParent,
      '<p><x></x><y></y></p>',
    );

    testParent.insert(z, after: x);
    expectHtml(
      testParent,
      '<p><x></x><z></z><y></y></p>',
    );
    expect(testParent.firstChild, x);
    expect(x.nextSibling, z);
    expect(z.nextSibling, y);
    expect(y.nextSibling, null);
    expect(y.previousSibling, z);
    expect(z.previousSibling, x);
    expect(x.previousSibling, null);
  });
}

void _removeTests() {
  setUp(() {
    testParent..insert(z)..insert(y)..insert(x);
  });

  test('first', () {
    testParent.remove(x);

    // Test removed element:
    expect(x.previousSibling, null);
    expect(x.nextSibling, null);
    expect(x.parent, null);

    // Test remaining elements:
    expect(testParent.firstChild, y);
    expect(y.nextSibling, z);
    expect(z.nextSibling, null);
    expect(z.previousSibling, y);
    expect(y.previousSibling, null);

    expectHtml(
      testParent,
      '<p><y></y><z></z></p>',
    );
  });

  test('middle', () {
    testParent.remove(y);

    // Test removed element:
    expect(y.previousSibling, null);
    expect(y.nextSibling, null);
    expect(y.parent, null);

    // Test remaining elements:
    expect(testParent.firstChild, x);
    expect(x.nextSibling, z);
    expect(z.nextSibling, null);
    expect(z.previousSibling, x);
    expect(x.previousSibling, null);

    expectHtml(
      testParent,
      '<p><x></x><z></z></p>',
    );
  });

  test('last', () {
    testParent.remove(z);

    // Test removed element:
    expect(z.previousSibling, null);
    expect(z.nextSibling, null);
    expect(z.parent, null);

    // Test remaining elements:
    expect(testParent.firstChild, x);
    expect(x.nextSibling, y);
    expect(y.nextSibling, null);
    expect(y.previousSibling, x);
    expect(x.previousSibling, null);

    expectHtml(
      testParent,
      '<p><x></x><y></y></p>',
    );
  });

  test('all one by one', () {
    testParent.remove(x);
    testParent.remove(y);
    testParent.remove(z);
    expectHtml(testParent, '<p></p>');
  });

  test('removeAll', () {
    testParent.removeAll();
    expectHtml(testParent, '<p></p>');
  });
}

void _moveTests() {
  setUp(() {
    testParent..insert(z)..insert(y)..insert(x);
  });

  test('first to last', () {
    testParent.move(x, after: z);
    expectHtml(testParent, '<p><y></y><z></z><x></x></p>');
  });
}

class _P extends RenderObject {
  _P() : super(html.Element.tag('p'));
}

class _X extends RenderObject {
  _X() : super(html.Element.tag('x'));
}

class _Y extends RenderObject {
  _Y() : super(html.Element.tag('y'));
}

class _Z extends RenderObject {
  _Z() : super(html.Element.tag('z'));
}

class _A extends RenderObject {
  _A() : super(html.Element.tag('a'));
}

class _B extends RenderObject {
  _B() : super(html.Element.tag('b'));
}

class _C extends RenderObject {
  _C() : super(html.Element.tag('c'));
}

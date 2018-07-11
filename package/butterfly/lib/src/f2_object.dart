// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
typedef void RenderObjectVisitor(RenderObject child);

/// An object in the render tree.
abstract class RenderObject extends Iterable<RenderObject> {
  final html.Element element;

  RenderObject get parent => _parent;
  RenderObject _parent;

  RenderObject get firstChild => _firstChild;
  RenderObject _firstChild;

  RenderObject get previousSibling => _previousSibling;
  RenderObject _previousSibling;

  RenderObject get nextSibling => _nextSibling;
  RenderObject _nextSibling;

  RenderObject(this.element) : assert(element != null);

  /// Whether this object has at least one child.
  bool get hasChildren => _firstChild != null;

  /// Insert child into this render object's child list after the given child.
  ///
  /// If `after` is null, then this inserts the child at the start of the list,
  /// and the child becomes the new [firstChild].
  void insert(RenderObject child, {RenderObject after}) {
    // If `after` is specified then this object must be its parent.
    assert(after == null || identical(after._parent, this));
    // If `after` is specified then we must have at least one child.
    assert(after == null || _firstChild != null);
    assert(child != after);
    assert(child._parent == null);

    child._parent = this;
    if (after == null) {
      // Sibling not specified: prepend by convention.
      if (_firstChild == null) {
        element.append(child.element);
        child._nextSibling = null;
      } else {
        element.insertBefore(child.element, _firstChild.element);
        _firstChild._previousSibling = child;
        child._nextSibling = _firstChild;
      }
      child._previousSibling = null;
      _firstChild = child;
    } else if (after._nextSibling == null) {
      // Specified sibling is the last child: append.
      element.append(child.element);
      after._nextSibling = child;
      child._previousSibling = after;
      child._nextSibling = null;
    } else {
      // We're inserting strictly in the middle: insert.
      element.insertBefore(child.element, after._nextSibling.element);
      RenderObject afterAfter = after._nextSibling;
      child._previousSibling = after;
      child._nextSibling = afterAfter;
      after._nextSibling = child;
      afterAfter._previousSibling = child;
    }

    assert(_firstChild != null);
    assert(_firstChild._previousSibling == null);
  }

  /// Remove this child from the child list.
  ///
  /// Requires the child to be present in the child list.
  void remove(RenderObject child) {
    assert(child._parent == this);
    final left = child._previousSibling;
    final right = child._nextSibling;
    if (identical(_firstChild, child)) {
      // Note, this will also correctly null out `_firstChild` if `child`
      // happens to be the sole child of this render object.
      _firstChild = right;
    }
    if (left != null) {
      left._nextSibling = right;
    }
    if (right != null) {
      right._previousSibling = left;
    }
    child._parent = null;
    child._previousSibling = null;
    child._nextSibling = null;
    child.element.remove();
  }

  /// Remove all their children from this render object's child list.
  ///
  /// More efficient than removing them individually.
  void removeAll() {
    while (firstChild != null) {
      remove(firstChild);
    }
  }

  /// Move this child in the child list to be before the given child.
  ///
  /// More efficient than removing and re-adding the child. Requires the child
  /// to already be in the child list at some position. Pass null for before to
  /// move the child to the end of the child list.
  void move(RenderObject child, {RenderObject after}) {
    // TODO(yjbanov): actually make it more efficient than removing and readding.
    assert(child.parent == this);
    assert(after == null || after.parent == this);
    assert(child != after);

    remove(child);
    insert(child, after: after);
  }

  @override
  Iterator<RenderObject> get iterator => _RenderObjectIterator(this);
}

class _RenderObjectIterator implements Iterator<RenderObject> {
  _RenderObjectIterator(this._parent);

  final RenderObject _parent;
  RenderObject _currentChild;

  @override
  RenderObject get current => _currentChild;

  @override
  bool moveNext() {
    if (_currentChild == null) {
      _currentChild = _parent._firstChild;
      return _currentChild != null;
    } else if (_currentChild._nextSibling != null) {
      _checkParentChildRelationship();
      _currentChild = _currentChild._nextSibling;
      return true;
    } else {
      _checkParentChildRelationship();
      return false;
    }
  }

  void _checkParentChildRelationship() {
    if (!identical(_currentChild._parent, _parent)) {
      throw ConcurrentModificationError(
          'Current child has moved to another parent during iteration.');
    }
  }
}

String debugGetRenderObjectHtml(RenderObject renderObject) =>
    renderObject.element.outerHtml;

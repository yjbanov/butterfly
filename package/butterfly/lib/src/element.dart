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

part of butterfly;

/// A special HTML attribute value for valueless attributes that indicates that
/// the attribute is present.
///
/// An example of valueless attribute is "checked" on a checkbox input:
///
///     <input type="checkbox" checked>
const attributePresent = '__present__';

/// The opposite of [attributePresent].
const attributeAbsent = '__absent__';

int _butterflyIdCounter = 0;
String _nextButterflyId() => '${_butterflyIdCounter++}';

/// Converts a boolean [condition] into [attributePresent] and
/// [attributeAbsent].
String attributePresentIf(bool condition) =>
    condition ? attributePresent : attributeAbsent;

/// A node that maps to an HTML element and can have multiple children.
///
/// Most of the time you will pick a widget from a library that's implemented
/// using this base class. Library authors may extend this class (but do not
/// have to) as a convenience to implement specialized widgets, such as buttons,
/// checkboxes and text fields, backed by an HTML element.
abstract class ElementBase extends MultiChildNode {
  const ElementBase(this.tag, {Key key, List<Node> children})
      : super(key: key, children: children);

  /// The tag of the HTML element, such as `<div>`.
  final String tag;
}

/// The render node counterpart for the [ElementBase].
///
/// It is expected (but not mandated) that a concrete implementation of an
/// [ElementBase] would have its render node extend this class. It provides
/// conveniences, such as [butterflyId], `tag` and `key` syncing. An implementor
/// would only need to implement the syncinc logic behind widget-specific
/// properties.
///
/// A note on [canUpdateUsing], it expected that an implementation is based on
/// the type of the widget rather than element `tag`. There is a limited number
/// of HTML tags, but a wide variety of widgets that can be implemented using
/// the them. A `<div>` that represents an expansion panel has nothing in common
/// with a `<div>` that represents an icon button, and therefore cannot be
/// updated using an icon button configuration. Contrast this to the general-
/// purpose [Element] class, which places no special semantics on the element
/// it is working with. It is perfectly OK to have any element configuration be
/// updated using any other element configuration, as long as the tag is the
/// same (element tags are immutable).
abstract class RenderElementBase<N extends ElementBase>
    extends RenderMultiChildParent<N> {
  RenderElementBase(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId(ElementUpdate update) {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      update.updateBaristaId(_butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration, ElementUpdate update) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    } else {
      update.tag = newConfiguration.tag;
      final key = newConfiguration.key;

      if (key != null) {
        update.key = key;
      }
    }
    super.update(newConfiguration, update);
  }
}

/// Like [ElementBase] but has exactly one child.
///
/// Use this class to implement custom elements that semantically have exactly
/// one child. It is more efficient than [ElementBase], which allows arbitrary
/// number of children.
abstract class SingleChildElementBase extends SingleChildParent {
  const SingleChildElementBase(this.tag, {Key key, Node child})
      : super(key: key, child: child);

  /// The tag of the HTML element, such as `<div>`.
  final String tag;
}

/// The render node counterpart for [SingleChildElementBase], like
/// [RenderElementBase] but has exactly one child.
abstract class RenderSingleChildElementBase<N extends SingleChildElementBase>
    extends RenderSingleChildParent<N> {
  RenderSingleChildElementBase(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId(ElementUpdate update) {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      update.updateBaristaId(_butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration, ElementUpdate update) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    } else {
      update.tag = newConfiguration.tag;
      final key = newConfiguration.key;

      if (key != null) {
        update.key = key;
      }
    }
    super.update(newConfiguration, update);
  }
}

/// Like [ElementBase] but has no children.
abstract class LeafElementBase extends Node {
  const LeafElementBase(this.tag, {Key key}) : super(key: key);

  /// The tag of the HTML element, such as `<div>`.
  final String tag;
}

/// The render node counterpart for [LeafElementBase], like
/// [RenderElementBase] but no children.
abstract class RenderLeafElementBase<N extends LeafElementBase>
    extends RenderNode<N> {
  RenderLeafElementBase(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId(ElementUpdate update) {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      update.updateBaristaId(_butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration, ElementUpdate update) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    } else {
      update.tag = newConfiguration.tag;
      final key = newConfiguration.key;

      if (key != null) {
        update.key = key;
      }
    }
    super.update(newConfiguration, update);
  }

  @override
  void visitChildren(_) {}
}

/// A generic HTML element, useful when you want a simple ad hoc element such
/// as `<div>`, `<button>`.
class Element extends ElementBase {
  const Element(
    String tag, {
    Key key,
    this.attributes,
    this.eventListeners,
    this.style,
    this.styles,
    this.classNames,
    this.text,
    List<Node> children,
  })
      : super(tag, key: key, children: children);

  final Map<String, String> attributes;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;
  final List<String> classNames;
  final String text;

  @override
  RenderNode instantiate(Tree t) => new RenderElement(t);
}

class RenderElement extends RenderElementBase<Element> {
  RenderElement(Tree tree) : super(tree);

  @override
  bool canUpdateUsing(Node node) {
    return node is Element && node.tag == this._configuration.tag;
  }

  @override
  void update(Element newConfiguration, ElementUpdate update) {
    if (_configuration != null) {
      if (_configuration.text != newConfiguration.text) {
        update.updateText(newConfiguration.text);
      }
      _updateEventListeners(newConfiguration.eventListeners, update);
      _updateAttributes(newConfiguration.attributes, update);
      _updateStyles(newConfiguration, update);
    } else {
      if (newConfiguration.eventListeners != null &&
          newConfiguration.eventListeners.isNotEmpty) {
        ensureButterflyId(update);
      }

      update.updateText(newConfiguration.text);

      if (newConfiguration.attributes != null &&
          newConfiguration.attributes.isNotEmpty) {
        newConfiguration.attributes.forEach((String name, String value) {
          update.updateAttribute(name, value);
        });
      }

      _setStyles(newConfiguration, update);
    }
    super.update(newConfiguration, update);
  }

  void _updateEventListeners(
      Map<EventType, EventListener> eventListeners, ElementUpdate update) {
    if (eventListeners != null && eventListeners.isNotEmpty) {
      ensureButterflyId(update);
    }
  }

  void _updateAttributes(Map<String, String> newAttrs, ElementUpdate update) {
    final oldAttrs = _configuration.attributes;
    if (newAttrs != oldAttrs) {
      // TODO(yjbanov): attribute updates are probaby sub-optimal.

      // Find updates
      for (final newName in newAttrs.keys) {
        final newValue = newAttrs[newName];
        if (oldAttrs[newName] != newValue) {
          update.updateAttribute(newName, newValue);
        }
      }

      // Find removes
      for (final oldName in oldAttrs.keys) {
        if (!newAttrs.containsKey(oldName)) {
          // TODO(yjbanov): this won't go far. Need explicit "remove attribute" op.
          update.updateAttribute(oldName, '');
        }
      }
    }
  }

  void _updateStyles(Element newConfig, ElementUpdate update) {
    Style oldStyle = _configuration.style;
    Style newStyle = newConfig.style;
    List<Style> oldStyles = _configuration.styles;
    List<Style> newStyles = newConfig.styles;
    List<String> oldClassNames = _configuration.classNames;
    List<String> newClassNames = newConfig.classNames;

    if (newStyle != oldStyle ||
        newStyles == null && oldStyles != null ||
        newStyles != null && oldStyles == null ||
        newClassNames == null && oldClassNames != null ||
        newClassNames != null && oldClassNames == null ||
        newStyles != null && newStyles.length != oldStyles.length ||
        newClassNames != null && newClassNames.length != oldClassNames.length) {
      if (newStyle != null) {
        if (!newStyle._isRegistered) {
          _tree.registerStyle(newStyle);
        }
        update.addClassName(newStyle.identifierClass);
      }
      if (newStyles != null) {
        for (int i = 0; i < newStyles.length; i++) {
          final Style style = newStyles[i];
          if (!style._isRegistered) {
            _tree.registerStyle(style);
          }
          update.addClassName(style.identifierClass);
        }
      }
      if (newClassNames != null) {
        for (int i = 0; i < newClassNames.length; i++) {
          update.addClassName(newClassNames[i]);
        }
      }
    }
  }

  void _setStyles(Element newConfig, ElementUpdate update) {
    Style newStyle = newConfig.style;
    List<Style> newStyles = newConfig.styles;
    List<String> newClassNames = newConfig.classNames;

    if (newStyle != null) {
      if (!newStyle._isRegistered) {
        _tree.registerStyle(newStyle);
      }
      update.addClassName(newStyle.identifierClass);
    }
    if (newStyles != null) {
      for (int i = 0; i < newStyles.length; i++) {
        final Style style = newStyles[i];
        if (!style._isRegistered) {
          _tree.registerStyle(style);
        }
        update.addClassName(style.identifierClass);
      }
    }
    if (newClassNames != null) {
      for (int i = 0; i < newClassNames.length; i++) {
        update.addClassName(newClassNames[i]);
      }
    }
  }

  @override
  void dispatchEvent(Event event) {
    if (this.butterflyId == event.targetBaristaId) {
      final listener = _configuration.eventListeners[event.type];
      if (listener != null) {
        listener(event);
      }
    } else {
      super.dispatchEvent(event);
    }
  }
}

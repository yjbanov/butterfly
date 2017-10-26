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

void _setButterflyIdAttribute(html.Element element, String butterflyId) {
  element.setAttribute('_bid', butterflyId);
}

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
  RenderElementBase(Tree tree, N widget)
      : nativeNode = new html.Element.tag(widget.tag),
        super(tree);

  @override
  final html.Element nativeNode;

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId() {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      _setButterflyIdAttribute(nativeNode, _butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    }
    super.update(newConfiguration);
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
  RenderSingleChildElementBase(Tree tree, N widget)
      : nativeNode = new html.Element.tag(widget.tag),
        super(tree);

  @override
  final html.Element nativeNode;

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId() {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      _setButterflyIdAttribute(nativeNode, _butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    }
    super.update(newConfiguration);
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
  RenderLeafElementBase(Tree tree, N widget)
      : nativeNode = new html.Element.tag(widget.tag),
        super(tree);

  @override
  final html.Element nativeNode;

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _butterflyId;
  String get butterflyId => _butterflyId;

  @protected
  void ensureButterflyId() {
    if (_butterflyId == null) {
      _butterflyId = _nextButterflyId();
      _setButterflyIdAttribute(nativeNode, _butterflyId);
    }
  }

  @mustCallSuper
  @override
  void update(N newConfiguration) {
    if (_configuration != null) {
      assert(_configuration.tag == newConfiguration.tag);
    }
    super.update(newConfiguration);
  }
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
  RenderNode instantiate(Tree t) => new RenderElement(t, this);
}

class RenderElement extends RenderElementBase<Element> {
  RenderElement(Tree tree, Element element) : super(tree, element);

  @override
  bool canUpdateUsing(Node node) {
    return node is Element && node.tag == this._configuration.tag;
  }

  @override
  void update(Element element) {
    if (!identical(element, configuration)) {
      _updateAttributes(element);
      _updateEventListeners(element.eventListeners);
      _updateStyles(element);
    }
    if (configuration == null || configuration.text != element.text) {
      if (element.text != null) {
        nativeNode.text = element.text;
      } else {
        nativeNode.text = '';
      }
    }
    super.update(element);
  }

  Style _appliedStyle;
  List<Style> _appliedStyles;

  void _addStyle(Style style) {
    if (!style._isRegistered) {
      tree.registerStyle(style);
    }
    nativeNode.classes.add(style.identifierClass);
  }

  void _updateStyles(Element newConfiguration) {
    var style = newConfiguration.style;
    if (!identical(_appliedStyle, style)) {
      bool hasStyle = _appliedStyle != null;
      bool willHaveStyle = style != null;

      if (hasStyle && !willHaveStyle) {
        nativeNode.classes.remove(_appliedStyle.identifierClass);
      } else if (!hasStyle && willHaveStyle) {
        _addStyle(style);
      } else {
        nativeNode.classes.remove(_appliedStyle.identifierClass);
        _addStyle(style);
      }
    }
    _appliedStyle = style;

    var styles = newConfiguration.styles;
    if (!identical(_appliedStyles, styles)) {
      bool hasStyles = _appliedStyles != null && _appliedStyles.isNotEmpty;
      bool willHaveStyles = styles != null && styles.isNotEmpty;

      if (!hasStyles && !willHaveStyles) {
        return;
      }

      if (hasStyles && !willHaveStyles) {
        // Simply remove all
        for (Style style in _appliedStyles) {
          nativeNode.classes.remove(style.identifierClass);
        }
      } else if (!hasStyles && willHaveStyles) {
        // Simply add all
        for (Style style in styles) {
          _addStyle(style);
        }
      } else {
        // Do the diffing
        int i = 0;
        while (i < _appliedStyles.length && i < styles.length &&
            identical(_appliedStyles[i], styles[i])) {
          i++;
        }
        for (int j = i; j < _appliedStyles.length; j++) {
          nativeNode.classes.remove(_appliedStyles[j].identifierClass);
        }
        while (i < styles.length) {
          _addStyle(styles[i]);
          i++;
        }
      }
      _appliedStyles = styles;
    }
  }

  void _updateAttributes(Element newConfiguration) {
    if (configuration == null || configuration.attributes == null) {
      if (newConfiguration.attributes != null) {
        _setAttributes(newConfiguration);
      }
    } else {
      _diffAttributes(newConfiguration);
    }
  }

  void _setAttributes(Element newConfiguration) {
    Map<String, String> attributes = newConfiguration.attributes;
    for (String attributeName in attributes.keys) {
      String value = attributes[attributeName];
      nativeNode.setAttribute(attributeName, value);
    }
  }

  void _diffAttributes(Element newConfiguration) {
    Map<String, String> oldAttrs = configuration.attributes;
    Map<String, String> newAttrs = newConfiguration.attributes;

    if (identical(oldAttrs, newAttrs) || oldAttrs == newAttrs) {
      return;
    }

    for (String attributeName in newAttrs.keys) {
      String oldValue = oldAttrs[attributeName];
      String newValue = newAttrs[attributeName];
      assert(!(oldValue == null && newValue == null));
      if (oldValue == null && newValue != null) {
        nativeNode.setAttribute(attributeName, newValue);
      } else if (oldValue != null && newValue == null) {
        // TODO(yjbanov): is there a more efficient way to do this?
        nativeNode.attributes.remove(attributeName);
      } else if (!looseIdentical(oldValue, newValue)) {
        nativeNode.setAttribute(attributeName, newValue);
      }
    }
  }

  void _updateEventListeners(Map<EventType, EventListener> eventListeners) {
    if (eventListeners != null && eventListeners.isNotEmpty) {
      ensureButterflyId();
      for (EventType type in eventListeners.keys) {
        tree.registerEventType(type);
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

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

typedef void PropSetter(Props props);
typedef void EventListener(Event event);

/// An event emitted by an element.
class Event {
  Event(this.type, this.nativeEvent);

  final EventType type;

  /// The native HTML event that triggered this event.
  final html.Event nativeEvent;
}

/// A kind of node that maps directly to the render system's native element, for
/// example an HTML element such as `<div>`, `<button>`.
class Element extends MultiChildNode {
  const Element(this.tag, {
    Key key,
    Map<String, String> attributes,
    List<Node> children,
    this.props,
    this.eventListeners,
    this.style,
    this.styles
  }) : this.attributes = attributes,
       super(key: key, children: children);

  final String tag;
  final Map<String, String> attributes;
  final PropSetter props;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;

  @override
  RenderNode instantiate(Tree t) => new RenderElement(t, this);
}

abstract class Props {
  /// A property on `<input>`
  set checked(bool value);

  /// A property on `<input>`
  set value(String newValue);

  /// A property on `<input>`
  set type(String type);
}

class RenderElement extends RenderMultiChildParent<Element> with ElementProps {
  RenderElement(Tree tree, Element configuration)
    : nativeNode = new html.Element.tag(configuration.tag),
      super(tree, configuration);

  @override
  final html.Element nativeNode;

  @override
  void update(Element newConfiguration) {
    if (!identical(newConfiguration, configuration)) {
      _updateAttributes(newConfiguration);
      _updateProps(newConfiguration);
      _updateEventListeners(newConfiguration.eventListeners);
      _updateStyles(newConfiguration);
    }
    super.update(newConfiguration);
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

  void _updateEventListeners(Map<EventType, EventListener> eventListeners) {
    tree.registerEventListeners(this, eventListeners);
  }

  bool handlesEvent(Event event) {
    var eventListeners = _configuration.eventListeners;
    return eventListeners != null && eventListeners.containsKey(event.type);
  }

  void dispatchEvent(Event event) {
    var eventListeners = _configuration.eventListeners;
    assert(eventListeners != null && eventListeners.containsKey(event.type));
    eventListeners[event.type](event);
    super.dispatchEvent(event);
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

  void _updateProps(Element newConfiguration) {
    if (newConfiguration.props != null) {
      newConfiguration.props(this);
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
}

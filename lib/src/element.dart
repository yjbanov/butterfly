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

part of flutter.web;

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
  const Element(this.tag, {Key key, Map<String, String> attributes,
      List<Node> children, this.props, this.eventListeners})
    : this.attributes = attributes,
      super(key: key, children: children);

  final String tag;
  final Map<String, String> attributes;
  final PropSetter props;
  final Map<EventType, EventListener> eventListeners;

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
  final html.Node nativeNode;

  @override
  void update(Element newConfiguration) {
    if (!identical(newConfiguration, configuration)) {
      _updateAttributes(newConfiguration);
      _updateProps(newConfiguration);
      _updateEventListeners(newConfiguration.eventListeners);
    }
    super.update(newConfiguration);
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
    html.Element nativeElement = nativeNode as html.Element;
    for (String attributeName in attributes.keys) {
      String value = attributes[attributeName];
      nativeElement.setAttribute(attributeName, value);
    }
  }

  void _diffAttributes(Element newConfiguration) {
    Map<String, String> oldAttrs = configuration.attributes;
    Map<String, String> newAttrs = newConfiguration.attributes;

    if (identical(oldAttrs, newAttrs) || oldAttrs == newAttrs) {
      return;
    }

    html.Element nativeElement = nativeNode as html.Element;
    for (String attributeName in newAttrs.keys) {
      String oldValue = oldAttrs[attributeName];
      String newValue = newAttrs[attributeName];
      assert(!(oldValue == null && newValue == null));
      if (oldValue == null && newValue != null) {
        nativeElement.setAttribute(attributeName, newValue);
      } else if (oldValue != null && newValue == null) {
        // TODO(yjbanov): is there a more efficient way to do this?
        nativeElement.attributes.remove(attributeName);
      } else if (!looseIdentical(oldValue, newValue)) {
        nativeElement.setAttribute(attributeName, newValue);
      }
    }
  }
}

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

part of flutter_ftw.tree;

class ElementNode extends MultiChildNode<VirtualElement> with ElementProps {
  ElementNode(Tree tree, VirtualElement configuration)
    : nativeNode = new html.Element.tag(configuration.tag),
      super(tree, configuration);

  @override
  final html.Node nativeNode;

  @override
  void update(VirtualElement newConfiguration) {
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

  void _updateAttributes(VirtualElement newConfiguration) {
    if (configuration == null || configuration.attributes == null) {
      if (newConfiguration.attributes != null) {
        _setAttributes(newConfiguration);
      }
    } else {
      _diffAttributes(newConfiguration);
    }
  }

  void _updateProps(VirtualElement newConfiguration) {
    if (newConfiguration.props != null) {
      newConfiguration.props(this);
    }
  }

  void _setAttributes(VirtualElement newConfiguration) {
    Map<String, String> attributes = newConfiguration.attributes;
    html.Element nativeElement = nativeNode as html.Element;
    for (String attributeName in attributes.keys) {
      String value = attributes[attributeName];
      nativeElement.setAttribute(attributeName, value);
    }
  }

  void _diffAttributes(VirtualElement newConfiguration) {
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

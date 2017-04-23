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

/// Converts a boolean [condition] into [attributePresent] and
/// [attributeAbsent].
String attributePresentIf(bool condition) => condition
    ? attributePresent
    : attributeAbsent;

/// A kind of node that maps directly to the render system's native element, for
/// example an HTML element such as `<div>`, `<button>`.
class Element extends MultiChildNode {
  Element(this.tag, {
    Key key,
    List<Attribute> attributes,
    this.text,
    List<Node> children,
    this.eventListeners,
    this.style,
    this.styles
  }) : this.attributes = attributes,
       super(key: key, children: children);

  final String tag;

  final List<Attribute> attributes;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;
  final String text;

  /// Barista ID.
  ///
  /// Used to uniquely identify this element when dispatching events.
  String _bid;

  @override
  RenderNode instantiate(Tree t) => new RenderElement(t);
}

class Attribute {
  final String name;
  final String value;

  const Attribute(this.name, this.value);
}

class RenderElement extends RenderMultiChildParent<Element> {
  RenderElement(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _baristaId;

  static int _baristaIdCounter = 0;
  static String _nextBid() => '${_baristaIdCounter++}';

  @override
  void update(Element newConfiguration, ElementUpdate update) {
    // TODO(yjbanov): implement for realz
    if (_configuration == null) {
      update.updateTag(newConfiguration.tag);
      final key = newConfiguration.key;

      if (key != null) {
        update.setKey(key);
      }

      if (newConfiguration.eventListeners != null && newConfiguration.eventListeners.isNotEmpty) {
        if (newConfiguration._bid != null) {
          update.updateBaristaId(newConfiguration._bid);
        } else {
          newConfiguration._bid = _nextBid();
          update.updateBaristaId(newConfiguration._bid);
        }
      }

      update.updateText(newConfiguration.text);

      if (newConfiguration.attributes != null && newConfiguration.attributes.isNotEmpty) {
        for (final attribute in newConfiguration.attributes) {
          update.updateAttribute(attribute.name, attribute.value);
        }
      }
    }
    super.update(newConfiguration, update);
  }

  void dispatchEvent(Event event) {
    if (this._baristaId == event.targetBaristaId) {
      final listener = _configuration.eventListeners[event.type];
      if (listener != null) {
        listener(event);
      }
    } else {
      super.dispatchEvent(event);
    }
  }
}

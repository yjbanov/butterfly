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
    Map<String, String> attributes,
    this.text,
    List<Node> children,
    this.eventListeners,
    this.style,
    this.styles
  }) : this.attributes = attributes,
       super(key: key, children: children);

  final String tag;

  final Map<String, String> attributes;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;
  final String text;

  @override
  RenderNode instantiate(Tree t) => new RenderElement(t);
}

class RenderElement extends RenderMultiChildParent<Element> {
  RenderElement(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _baristaId;

  static int _baristaIdCounter = 0;
  static String _nextBid() => '${_baristaIdCounter++}';

  @override
  bool canUpdateUsing(Node node) {
    return node is Element && node.tag == this._configuration.tag;
  }

  @override
  void update(Element newConfiguration, ElementUpdate update) {
    // TODO(yjbanov): implement for realz
    if (_configuration != null) {
      if (_configuration.text != newConfiguration.text) {
        update.updateText(newConfiguration.text);
      }
      if (newConfiguration.eventListeners != null && newConfiguration.eventListeners.isNotEmpty) {
        if (_baristaId == null) {
          _baristaId = _nextBid();
          update.updateBaristaId(_baristaId);
        }
      }

      final newAttrs = newConfiguration.attributes;
      final oldAttrs = _configuration.attributes;
      if (newAttrs != oldAttrs) {
        // TODO(yjbanov): attribute updates are probaby sub-optimal.

        // Find updates
        for (String newName in newAttrs.keys) {
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

      // TODO(yjbanov): implement style diffing
    } else {
      update.updateTag(newConfiguration.tag);
      final key = newConfiguration.key;

      if (key != null) {
        update.setKey(key);
      }

      if (newConfiguration.eventListeners != null && newConfiguration.eventListeners.isNotEmpty) {
        if (_baristaId == null) {
          _baristaId = _nextBid();
          update.updateBaristaId(_baristaId);
        }
      }

      update.updateText(newConfiguration.text);

      if (newConfiguration.attributes != null && newConfiguration.attributes.isNotEmpty) {
        newConfiguration.attributes.forEach((String name, String value) {
          update.updateAttribute(name, value);
        });
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

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
String attributePresentIf(bool condition) =>
    condition ? attributePresent : attributeAbsent;

/// A kind of node that maps directly to the render system's native element, for
/// example an HTML element such as `<div>`, `<button>`.
class Element extends MultiChildNode {
  Element(
    this.tag, {
    Key key,
    this.attributes,
    this.eventListeners,
    this.style,
    this.styles,
    this.classNames,
    this.text,
    List<Node> children,
  })
      : super(key: key, children: children);

  final String tag;

  final Map<String, String> attributes;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;
  final List<String> classNames;
  final String text;

  @override
  RenderNode instantiate(Tree t) => new RenderElement(t);
}

class RenderElement extends RenderMultiChildParent<Element> {
  RenderElement(Tree tree) : super(tree);

  /// An automatically generated global identifier, created to refer to this
  /// element later, e.g. when we need to dispatch an event to it.
  String _baristaId;
  String get baristaId => _baristaId;

  static int _baristaIdCounter = 0;
  static String _nextBid() => '${_baristaIdCounter++}';

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
      update.tag = newConfiguration.tag;
      final key = newConfiguration.key;

      if (key != null) {
        update.key = key;
      }

      if (newConfiguration.eventListeners != null &&
          newConfiguration.eventListeners.isNotEmpty) {
        if (_baristaId == null) {
          _baristaId = _nextBid();
          update.updateBaristaId(_baristaId);
        }
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
      if (_baristaId == null) {
        _baristaId = _nextBid();
        update.updateBaristaId(_baristaId);
      }
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

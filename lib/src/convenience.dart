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

Element text(String value, {Key key}) => new Element('span', text: value, key: key);

VirtualElementBuilder element(String tag, {Key key, List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return new VirtualElementBuilder(tag, key, attrs, eventListeners, style, styles);
}

VirtualElementBuilder div({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('div', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder section({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('section', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder header({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('header', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder footer({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('footer', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h1({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h1', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h2({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h2', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h3({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h3', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h4({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h4', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h5({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h5', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder h6({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('h6', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder ul({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('ul', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder li({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('li', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder label({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('label', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder span({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('span', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder p({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('p', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder a({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('a', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder button({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return element('button', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder input(String type, {List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  List<Attribute> completeAttrs = <Attribute>[
    new Attribute('type', type),
  ];
  completeAttrs.addAll(attrs);
  return element('input', attrs: completeAttrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder checkbox({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('checkbox', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder radio({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('radio', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder password({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('password', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder submit({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('submit', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder textInput({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('text', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

VirtualElementBuilder buttonInput({List<Attribute> attrs,
    Map<EventType, EventListener> eventListeners, Style style, List<Style> styles}) {
  return input('button', attrs: attrs, eventListeners: eventListeners,
      style: style, styles: styles);
}

class VirtualElementBuilder {
  const VirtualElementBuilder(
    this._tag,
    this._key,
    this._attributes,
    this._eventListeners,
    this._style,
    this._styles
  );

  final String _tag;
  final Key _key;
  final List<Attribute> _attributes;
  final Map<EventType, EventListener> _eventListeners;
  final Style _style;
  final List<Style> _styles;

  Element call([List<Node> children]) {
    // TODO: validate tag name
    assert(_tag != null);
    assert(() {
      if (children == null) {
        return true;
      }

      for (var child in children) {
        assert(child is Node);
      }

      return true;
    });

    return new Element(
      _tag,
      key: _key,
      attributes: _attributes,
      children: children,
      eventListeners: _eventListeners,
      style: _style,
      styles: _styles
    );
  }
}

EventListener onKeyEnter(EventListener originalListener) => (Event event) {
  if (event['keyCode'] == 13) {
    originalListener(event);
  }
};

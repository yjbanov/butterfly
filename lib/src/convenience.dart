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

import 'framework.dart';

Text text(String value, {Key key}) => new Text(value, key: key);

VirtualElementBuilder element(String tag, {Key key, Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return new VirtualElementBuilder(tag, key, attrs, props, eventListeners);
}

VirtualElementBuilder div({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return element('div', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder span({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return element('span', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder button({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return element('button', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder input(String type, {Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  PropSetter propSetter;
  if (props != null) {
    propSetter = (Props p) {
      p.type = type;
      props(p);
    };
  } else {
    propSetter = (Props p) {
      p.type = type;
    };
  }
  return element('input', attrs: attrs, props: propSetter);
}

VirtualElementBuilder checkbox({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('checkbox', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder radio({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('radio', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder password({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('password', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder submit({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('submit', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder textInput({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('text', attrs: attrs, props: props, eventListeners: eventListeners);
}

VirtualElementBuilder buttonInput({Map<String, String> attrs, PropSetter props,
    Map<EventType, EventListener> eventListeners}) {
  return input('button', attrs: attrs, props: props, eventListeners: eventListeners);
}

class VirtualElementBuilder {
  const VirtualElementBuilder(
    this._tag,
    this._key,
    this._attributes,
    this._props,
    this._eventListeners
  );

  final String _tag;
  final Key _key;
  final Map<String, String> _attributes;
  final PropSetter _props;
  final Map<EventType, EventListener> _eventListeners;

  VirtualElement call([List<VirtualNode> children]) {
    // TODO: validate tag name
    assert(_tag != null);
    assert(() {
      if (children == null) {
        return true;
      }

      for (var child in children) {
        assert(child is VirtualNode);
      }

      return true;
    });

    return new VirtualElement(
      _tag,
      key: _key,
      attributes: _attributes,
      props: _props,
      children: children,
      eventListeners: _eventListeners
    );
  }
}

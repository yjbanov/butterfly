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

typedef dynamic EventListener(Event event);

// TODO: figure out how to supply event target
class Event {
  final String type;
  final bool bubbles;
  final bool cancelable;
  // TODO: Can we make it harder for people to pass non-JSONable values?
  final value;

  Event(String type, {bool canBubble: true, bool cancelable: true, this.value})
      : this.type = type,
        this.bubbles = canBubble,
        this.cancelable = cancelable;

  Map toJson() {
    var json = {
      'type': type,
      'bubbles': bubbles,
      'cancelable': cancelable,
    };
    if (value != null) {
      json['value'] = value;
    }
    return json;
  }

  static Event fromJson(Map json) {
    return new Event(
      json['type'],
      canBubble: json['bubbles'],
      cancelable: json['cancelable'],
      value: json['value']);
  }
}

class Envelope {
  final int recipient;
  final Event event;
  Envelope(this.recipient, this.event);

  Map toJson() {
    return {
      'event': event,
      'recipient': recipient,
    };
  }

  static Envelope fromJson(Map json) {
    return new Envelope(json['recipient'], Event.fromJson(json['event']));
  }
}

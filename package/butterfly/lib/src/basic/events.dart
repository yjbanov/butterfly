// Copyright 2017 Google Inc. All Rights Reserved.
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

/// A decorated box that contains a single child.
@immutable
class EventRecognizer extends Decoration {
  EventRecognizer({
    Key key,
    this.eventType,
    this.listener,
    Node child,
  })
      : super(key: key, child: child);

  final EventType eventType;
  final EventListener listener;

  @override
  RenderNode instantiate(Tree tree) => new RenderEventRecognizer(tree);
}

class RenderEventRecognizer extends RenderDecoration<EventRecognizer> {
  RenderEventRecognizer(Tree tree) : super(tree);

  final String _butterflyId = _nextButterflyId();

  @override
  bool canUpdateUsing(Node node) => node is EventRecognizer;

  @override
  void update(EventRecognizer newConfiguration, ElementUpdate update) {
    super.update(newConfiguration, update);
  }

  @override
  void dispatchEvent(Event event) {
    if (this._butterflyId == event.targetBaristaId &&
        event.type == _configuration.eventType) {
      _configuration.listener(event);
    } else {
      super.dispatchEvent(event);
    }
  }
}

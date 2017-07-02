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

abstract class EventArena extends StatelessWidget {
  final EventType eventType;
  final EventListener eventListener;
  final Node child;

  const EventArena({this.eventType, this.eventListener, this.child});

  @override
  Node build() {
    var listeners = {
      [eventType]: eventListener,
    };
    return new Element(
      'span',
      eventListeners: listeners,
      children: [child],
    );
  }
}

class ClickArena extends EventArena {
  ClickArena({
    EventListener onClick,
    Node child,
  })
      : super(
          eventType: EventType.click,
          eventListener: onClick,
          child: child,
        );
}

class DoubleClickArena extends EventArena {
  DoubleClickArena({
    EventListener onDoubleClick,
    Node child,
  })
      : super(
          eventType: EventType.dblclick,
          eventListener: onDoubleClick,
          child: child,
        );
}

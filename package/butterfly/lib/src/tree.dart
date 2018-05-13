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

/// Renders a [widget] into HTML DOM hosted by [host].
class Tree {
  // TODO(yjbanov): top-level node and host element shouldn't be final. They
  // should be replaceable.
  Tree(this.widget, this.host, [html.Element styleHost])
      : _styleHost = styleHost ?? html.document.head {
    assert(widget != null);
    assert(host != null);
  }

  /// The widget rendered by this tree.
  final Node widget;
  final html.Element host;
  final html.Element _styleHost;
  final Set<EventType> _globalEventTypes = new Set<EventType>();

  RenderNode _topLevelNode;

  StringBuffer _styleBuffer = new StringBuffer();

  void registerEventType(EventType type) {
    if (_globalEventTypes.contains(type)) {
      return;
    }
    _globalEventTypes.add(type);
    host.addEventListener(type.name, (html.Event nativeEvent) {
      // Find the closest parent that has _bid.
      html.Node nativeTarget = nativeEvent.target;
      while (nativeTarget != null &&
          !(nativeTarget as html.Element).attributes.containsKey('_bid')) {
        nativeTarget = nativeTarget.parent;
      }
      if (nativeTarget != null) {
        html.Element nativeElement = nativeTarget;
        Event event =
            new Event(type, nativeElement.getAttribute('_bid'), nativeEvent);
        dispatchEvent(event);
        renderFrame();
      }
    });
  }

  void registerStyle(Style style) {
    assert(!style._isRegistered);
    _styleBuffer.writeln('.${style.identifierClass} { ${style.css} }');
  }

  void dispatchEvent(Event event) {
    _topLevelNode.dispatchEvent(event);
  }

  void visitChildren(void visitor(RenderNode child)) {
    visitor(_topLevelNode);
  }

  void renderFrame() {
    if (_topLevelNode == null) {
      _topLevelNode = widget.instantiate(this);
      _topLevelNode.update(widget);
      host.append(_topLevelNode.nativeNode);
    } else {
      _topLevelNode.update(_topLevelNode.configuration);
    }

    if (_styleBuffer.isNotEmpty) {
      _styleHost.children
          .add(new html.StyleElement()..text = _styleBuffer.toString());
      _styleBuffer = new StringBuffer();
    }

    assert(() {
      _debugCheckParentChildRelationships();
      GlobalKey.debugCheckForDuplicates();
      return true;
    }());
    scheduleMicrotask(GlobalKey.notifyListeners);
  }

  bool _debugCheckParentChildRelationships() {
    _debugCheckParentChildRelationshipWith(_topLevelNode);
    return true;
  }
}

void _debugCheckParentChildRelationshipWith(RenderNode node) {
  node.visitChildren((RenderNode child) {
    assert(identical(child.parent, node));
    _debugCheckParentChildRelationshipWith(child);
  });
}

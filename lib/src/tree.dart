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

part of flutter.web;

/// Links back from the native node to [RenderElement].
///
/// This is used to lookup the event listeners given the event target.
final Expando<RenderElement> _backlink = new Expando<RenderElement>();

/// Retained virtual mirror of the DOM Tree.
class Tree {
  Tree(this._topLevelWidget, this._hostElement) {
    assert(_topLevelWidget != null);
    assert(_hostElement != null);
  }

  final Widget _topLevelWidget;
  final html.Element _hostElement;

  RenderNode _topLevelNode;

  final List<bool> _globalEventListeners = new List<bool>.filled(400, false);

  void _registerEventType(EventType type) {
    int index = type.index;
    if (_globalEventListeners[index]) {
      return;
    }
    _globalEventListeners[index] = true;
    _hostElement.addEventListener(type.typeName, (html.Event nativeEvent) {
      Event event = new Event(type, nativeEvent);
      // Find the closest render node interested in the event
      html.Node nativeTarget = nativeEvent.target;
      RenderElement node;
      while(nativeTarget != null &&
          (node = _backlink[nativeTarget]) == null || !node.handlesEvent(event)) {
        nativeTarget = nativeTarget.parent;
      }
      if (nativeTarget != null) {
        assert(node != null);
        assert(node.handlesEvent(event));
        node.dispatchEvent(event);
      }
    });
  }

  void registerEventListeners(RenderElement element, Map<EventType, EventListener> eventListeners) {
    if (eventListeners != null && eventListeners.isNotEmpty) {
      _backlink[element.nativeNode] = element;
      for (EventType type in eventListeners.keys) {
        _registerEventType(type);
      }
    } else {
      _backlink[element.nativeNode] = null;
    }
  }

  void visitChildren(void visitor(RenderNode child)) {
    visitor(_topLevelNode);
  }

  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    _hostElement.insertBefore(replacement, oldNode);
    oldNode.remove();
  }

  void renderFrame() {
    if (_topLevelNode == null) {
      _topLevelNode = _topLevelWidget.instantiate(this);
      _hostElement.append(_topLevelNode.nativeNode);
    } else {
      _topLevelNode.update(_topLevelNode.configuration);
    }

    assert(() {
      _debugCheckParentChildRelationships();
      GlobalKey.debugCheckForDuplicates();
      return true;
    });
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

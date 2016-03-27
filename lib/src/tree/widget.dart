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

class StatelessWidgetNode extends ParentNode<StatelessWidget> {
  StatelessWidgetNode(StatelessWidget configuration)
     : _child = configuration.build().instantiate(),
       super(configuration);

  Node _child;

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    parent.replaceChildNativeNode(oldNode, replacement);
  }

  html.Node get nativeNode => _child.nativeNode;

  @override
  void update(StatelessWidget newConfiguration) {
    assert(_child != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      VirtualNode newChildConfiguration = newConfiguration.build();
      if (_canUpdate(this, newChildConfiguration)) {
        _child.update(newChildConfiguration);
      } else {
        // Replace child
        _child.detach();
        _child = newChildConfiguration.instantiate();
      }
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }
    super.update(newConfiguration);
  }
}

class StatefulWidgetNode extends ParentNode<StatefulWidget> {
  StatefulWidgetNode(StatefulWidget configuration)
      : _state = configuration.createState(),
        super(configuration) {
    internalSetStateNode(_state, this);
    _child = _state.build().instantiate();
  }

  State _state;
  Node _child;
  bool _isDirty = false;

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    parent.replaceChildNativeNode(oldNode, replacement);
  }

  html.Node get nativeNode => _child.nativeNode;

  void scheduleUpdate() {
    _isDirty = true;
    super.scheduleUpdate();
  }

  void update(StatefulWidget newConfiguration) {
    assert(_child != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      _state = newConfiguration.createState();
      VirtualNode newChildConfiguration = _state.build();
      if (identical(newChildConfiguration.runtimeType, _child.configuration.runtimeType)) {
        _child.update(newChildConfiguration);
      } else {
        _child.detach();
        _child = newChildConfiguration.instantiate();
      }
    } else if (_isDirty) {
      _child.update(_state.build());
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }

    _isDirty = false;
    super.update(newConfiguration);
  }
}

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

class RenderStatelessWidget extends RenderParent<StatelessWidget> {
  RenderStatelessWidget(Tree tree, StatelessWidget configuration)
      : super(tree, configuration);

  RenderNode _child;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

  @override
  void replaceChildNativeNode(html.Node oldNode, html.Node replacement) {
    parent.replaceChildNativeNode(oldNode, replacement);
  }

  html.Node get nativeNode => _child.nativeNode;

  @override
  void update(StatelessWidget newConfiguration) {
    assert(newConfiguration != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      Node newChildConfiguration = newConfiguration.build();
      if (_child != null && _canUpdate(_child, newChildConfiguration)) {
        _child.update(newChildConfiguration);
      } else {
        // Replace child
        _child?.detach();
        _child = newChildConfiguration.instantiate(tree);
        _child.attach(this);
      }
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }
    super.update(newConfiguration);
  }
}

class RenderStatefulWidget extends RenderParent<StatefulWidget> {
  RenderStatefulWidget(Tree tree, StatefulWidget configuration)
      : super(tree, configuration);

  State _state;
  State get state => _state;
  RenderNode _child;
  bool _isDirty = false;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    visitor(_child);
  }

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
    assert(newConfiguration != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      _state = newConfiguration.createState();
      internalSetStateNode(_state, this);
      Node newChildConfiguration = _state.build();
      if (_child != null && identical(newChildConfiguration.runtimeType, _child.configuration.runtimeType)) {
        _child.update(newChildConfiguration);
      } else {
        _child?.detach();
        _child = newChildConfiguration.instantiate(tree);
        _child.attach(this);
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

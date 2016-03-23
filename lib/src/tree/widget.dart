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
  StatelessWidgetNode(StatelessWidget configuration) : super(configuration) {
    _buildNewChild(configuration);
  }

  Node _child;

  @override
  void update(StatelessWidget newConfiguration) {
    assert(_child != null);
    if (!identical(configuration, newConfiguration)) {
      // Build the new configuration and decide whether to reuse the child node
      // or replace with a new one.
      VirtualNode newChildConfiguration = newConfiguration.build();
      if (identical(newChildConfiguration.runtimeType, _child.configuration.runtimeType)) {
        _child.update(newChildConfiguration);
      } else {
        _child.detach();
        _buildNewChild(newConfiguration);
      }
    } else if (hasDescendantsNeedingUpdate) {
      // Own configuration is the same, but some children are scheduled to be
      // updated.
      _child.update(_child.configuration);
    }
    super.update(newConfiguration);
  }

  _buildNewChild(StatelessWidget newConfiguration) {
    _child = newConfiguration.build().instantiate();
    _child.attach(this);
    _child.update(_child.configuration);
  }
}

class StatefulWidgetNode extends ParentNode<StatefulWidget> {
  StatefulWidgetNode(StatefulWidget configuration)
      : _state = configuration.createState(),
        super(configuration) {
    _buildNewChild();
  }

  final State _state;
  Node _child;

  bool _isDirty = true;

  void scheduleUpdate() {
    _isDirty = true;
    super.scheduleUpdate();
  }

  void update(StatefulWidget newConfiguration) {
    if (_isDirty) {
      _child.detach();
      _buildNewChild();
    }
    super.update(newConfiguration);
  }

  _buildNewChild() {
    _child = _state.build().instantiate();
    _child.attach(this);
    _child.update(_child.configuration);
  }
}

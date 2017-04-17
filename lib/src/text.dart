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

/// A kind of node that maps directly to the render system's native node
/// representing a text value.
class Text extends Node {
  final String value;
  const Text(this.value, {Key key}) : super(key: key);

  RenderNode instantiate(Tree t) => new RenderText(t, this);
}

/// A node that carries textual information. This node is immutable.
class RenderText extends RenderNode<Text> {
  RenderText(Tree tree, Text configuration)
      : super(tree, configuration);

  @override
  void visitChildren(_) {}

  @override
  void dispatchEvent(_) {}

  void update(Text newConfiguration) {
    super.update(newConfiguration);
  }

  @override
  String toString() => 'TEXT(${configuration.value})';
}

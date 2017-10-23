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

/// A section of text.
///
/// TODO(jonahwilliams): styling options directly on text.
class Text extends Node {
  final String value;

  const Text(this.value);

  @override
  RenderNode instantiate(Tree tree) => new _TextRenderNode(tree);
}

/// A [RenderNode] for the [Text] node.
class _TextRenderNode extends RenderNode<Text> {
  _TextRenderNode(Tree tree) : super(tree);

  @override
  bool canUpdateUsing(Node node) => node is Text;

  @override
  void dispatchEvent(Event event) {}

  @override
  void visitChildren(void visitor(RenderNode child)) {}

  void update(Text newConfiguration, ElementUpdate update) {
    if (!identical(newConfiguration, configuration)) {
      update.tag = 'span';
      update.updateText(newConfiguration.value);
    }
    super.update(newConfiguration, update);
  }
}

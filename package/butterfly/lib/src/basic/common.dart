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
class Text extends Node {
  final String value;

  const Text(this.value, {Key key}) : super(key: key);

  @override
  RenderNode instantiate(RenderParent parent) => new TextRenderNode(parent, this);
}

/// A [RenderNode] for the [Text] node.
class TextRenderNode extends RenderNode<Text> {
  TextRenderNode(RenderParent parent, Text text)
      : surface = new Surface()..text = text.value,
        super(parent);

  @override
  final Surface surface;

  @override
  void visitChildren(void visitor(RenderNode child)) {}

  void update(Text newWidget) {
    if (newWidget.value != widget.value) {
      surface.text = newWidget.value;
    }
    super.update(newWidget);
  }
}

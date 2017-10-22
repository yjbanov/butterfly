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

@immutable
class BoxDecoration {
  const BoxDecoration({
    this.padding,
    this.border,
  });

  final String padding;
  final String border;

  void update(BoxDecoration other, html.Element element) {
    if (other.padding != padding) {
      element.style.setProperty('padding', other.padding);
    }
    if (other.border != border) {
      element.style.setProperty('border', other.border);
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final BoxDecoration typedOther = other;
    return padding == typedOther.padding && border == typedOther.border;
  }

  @override
  int get hashCode => padding.hashCode;
}

/// A decorated box that contains a single child.
@immutable
class Container extends SingleChildElementBase {
  Container({
    this.decoration,
  })
      : super('div');

  final BoxDecoration decoration;

  @override
  RenderContainer instantiate(Tree tree) => new RenderContainer(tree, this);
}

class RenderContainer extends RenderSingleChildElementBase<Container> {
  RenderContainer(Tree tree, Container container) : super(tree, container);

  @override
  bool canUpdateUsing(Node node) => node is Container;

  @override
  void update(Container newConfiguration) {
    if (_configuration != null) {
      final BoxDecoration oldDecoration = _configuration.decoration;
      final BoxDecoration newDecoration = newConfiguration.decoration;
      if (!identical(oldDecoration, newDecoration)) {
        oldDecoration.update(newDecoration, nativeNode);
      }
    } else {}
    super.update(newConfiguration);
  }
}

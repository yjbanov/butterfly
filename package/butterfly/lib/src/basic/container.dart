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

  void update(BoxDecoration other, Surface surface) {
    if (other.padding != padding) {
      surface.padding = other.padding;
    }
    if (other.border != border) {
      surface.border = other.border;
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
class Container extends SingleChildParent {
  Container({
    Key key,
    Node child,
    this.decoration,
  }) : super(
    key: key,
    child: child,
  );

  final BoxDecoration decoration;

  @override
  RenderContainer instantiate(RenderParent parent) => new RenderContainer(parent);
}

class RenderContainer extends RenderSingleChildParent<Container> {
  RenderContainer(RenderParent parent) : super(parent);

  @override
  final Surface surface = new Surface();

  @override
  void update(Container newWidget) {
    if (widget != null) {
      final BoxDecoration oldDecoration = widget.decoration;
      final BoxDecoration newDecoration = newWidget.decoration;
      if (!identical(oldDecoration, newDecoration)) {
        oldDecoration.update(newDecoration, surface);
      }
    } else {}
    super.update(newWidget);
  }
}

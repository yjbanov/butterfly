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

import 'dart:html' as html;

import 'package:meta/meta.dart';

import '../f2.dart';

@immutable
class BoxDecoration {
  const BoxDecoration({
    this.padding,
    this.border,
  });

  final String padding;
  final String border;

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
class Container extends SingleChildRenderObjectWidget {
  Container({
    Key key,
    Widget child,
    this.decoration,
  })  : assert(child != null),
        super(
          key: key,
          child: child,
        );

  final BoxDecoration decoration;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContainer()..decoration = decoration;
  }

  @override
  void updateRenderObject(BuildContext context, RenderContainer renderObject) {
    renderObject.decoration = decoration;
  }
}

class RenderContainer extends RenderObject {
  RenderContainer() : super(html.DivElement());

  BoxDecoration get decoration => _decoration;
  BoxDecoration _decoration;
  set decoration(BoxDecoration newValue) {
    if (identical(_decoration, newValue)) {
      return;
    }
    if (newValue != null) {
      if (_decoration?.padding != newValue.padding) {
        element.style.padding = newValue.padding;
      }
      if (_decoration?.border != newValue.border) {
        element.style.border = newValue.border;
      }
    } else {
      element.style.padding = '';
      element.style.border = '';
    }
    _decoration = newValue;
  }
}

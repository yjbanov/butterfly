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

/// Describes an HTML element's CSS style.
///
/// Butterfly encourages defining your styles in Dart code. You get the same
/// features as you do from SASS or LESS, but you don't need to deal with a
/// second language. Additionally, you get tree shaking, minification, code
/// completion. You can publish common styles as a simple Dart library, and
/// control visibility using Dart methods. Additional methods such as shadow
/// DOM are no longer necessary.
///
/// Example:
///
/// Here's an example of a SASS file:
///
///     $font-stack: Helvetica, sans-serif;
///     $primary-color: #333;
///
///     @mixin border-radius($radius) {
///       -webkit-border-radius: $radius;
///       border-radius: $radius;
///     }
///
///     .box {
///       @include border-radius(10px);
///       font: 100% $font-stack;
///       color: $primary-color;
///     }
///
/// Here it is using Butterfly API:
///
///     final fontStack = 'Helvetica, sans-serif';
///     final primaryColor = '#333';
///
///     borderRadius(String radius) => {
///       '-webkit-border-radius': radius,
///       'border-radius': radius,
///     };
///
///     final Style box = (
///       new StyleBuilder()
///         ..addMixin(borderRadius('10px'))
///         ..['font'] = '100% $fontStack'
///         ..['color'] = primaryColor
///       ).buildStyle();
///
/// Now you can apply this style to an element:
///
///     build() => div(style: box);
///
class Style {
  static int _idCounter = 1;

  Style(this.css) : identifierClass = 'bf${_idCounter++}';

  final String identifierClass;
  final String css;

  bool _isRegistered = false;
}

class StyleProperty {
  StyleProperty(this.name, this.value);

  final String name;
  final String value;
}

class StyleBuilder {
  final List<Map<String, String>> _mixins = <Map<String, String>>[];
  final Map<String, String> _properties = <String, String>{};

  void addMixin(Map<String, String> mixin) {
    _mixins.add(mixin);
  }

  void addProperty(StyleProperty property) {
    _properties[property.name] = property.value;
  }

  operator[]=(String name, String value) {
    _properties[name] = value;
  }

  /// Returns flat map of CSS properties.
  ///
  /// Properties in mixins that come last take precedence over those that come
  /// from mixins added earlier. Properties added using `operator[]=` have the
  /// highest precedence.
  Map<String, String> flatten() {
    var flat = <String, String>{};
    for (Map<String, String> mixin in _mixins) {
      flat.addAll(mixin);
    }
    flat.addAll(_properties);
    return flat;
  }

  /// Returns the final CSS of the style.
  Style buildStyle() {
    var buf = new StringBuffer();
    var flat = flatten();
    for (String property in flat) {
      buf.write('${property}: ${flat[property]}');
    }
    return new Style(buf.toString());
  }
}

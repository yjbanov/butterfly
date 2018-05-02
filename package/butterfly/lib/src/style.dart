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

/// Key for mixins in style expressions.
///
/// Example:
///
///     Style matButton = style({
///       mixin: someMixin,
///       'align-items': 'center',
///     });
final String mixin = r'$mixin$';

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
///     final Style box = style({
///       mixin: borderRadius('10px'),
///       'font': '100% $fontStack',
///       'color': primaryColor,
///     });
///
/// Now you can apply this style to an element:
///
///     build() => div(style: box);
///
Style style(Map<String, Object> styleExpression) {
  var buf = new StringBuffer();
  _flatten(styleExpression).forEach((String property, dynamic value) {
    if (value is String) {
      buf.write('${property}: ${value};');
    } else if (value is List) {
      for (String subValue in value) {
        buf.write('${property}: ${subValue};');
      }
    } else {
      assert(() {
        throw new ArgumentError.value(
            value.runtimeType, 'value type', 'Not supported');
      }());
    }
  });
  return new Style(buf.toString());
}

/// A uniquely identifiable CSS style that may be applied to an HTML element.
class Style {
  static int _idCounter = 1;

  Style(this.css) : identifierClass = 'bf${_idCounter++}';

  /// A [Style] object is applied to an element by using [identifierClass] as
  /// the CSS class.
  final String identifierClass;

  /// A valid CSS property list.
  ///
  /// Example:
  ///
  ///     """
  ///     height: 10px;
  ///     width: 50px;
  ///     """
  final String css;

  bool _isRegistered = false;
}

Map<String, dynamic> _flatten(Map<String, dynamic> styleExpression) {
  final flat = <String, dynamic>{};
  styleExpression.forEach((String property, dynamic value) {
    if (value is Map) {
      assert(() {
        if (!identical(property, mixin)) {
          throw 'Mixin in style expression whose key is not `mixin`:\n'
              'Property: ${property}\n'
              'Style expression:\n'
              '${styleExpression}';
        }
        return true;
      }());
      flat.addAll(_flatten(value));
    } else {
      flat[property] = value;
    }
  });
  return flat;
}

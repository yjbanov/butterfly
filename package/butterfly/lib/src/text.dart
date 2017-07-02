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

/// Some text.
class Text extends StatelessWidget {
  final String value;
  final TextStyle style;

  const Text(this.value, {this.style});

  @override
  Node build() {
    Style textStyle;
    if (style != null) {
      var buffer = new StringBuffer();
      if (style.color != null) {
        buffer.write('color: ${style.color.toCssRGB()};');
      }
      if (style.fontFamily != null) {
        buffer.write('font-family: ${style.fontFamily};');
      }
      if (style.fontWeight != null) {
        buffer.write('font-weight: ${style.fontWeight};');
      }
      if (style.textDecoration != null) {
        if (style.textDecoration.type == DecorationType.LineThrough) {
          buffer.write('text-decoration: linethrough;');
        } else if (style.textDecoration.type == DecorationType.Overline) {
          buffer.write('text-decoration: overline;');
        } else if (style.textDecoration.type == DecorationType.Underline) {
          buffer.write('text-decoration: underline;');
        }
      }
      textStyle = new Style(buffer.toString());
    }
    return new Element('span', text: value, style: textStyle);
  }
}

/// Some text styles.
class TextStyle {
  /// The text color.
  final Color color;

  /// The text decoration.
  final TextDecoration textDecoration;

  final String fontFamily;

  final double fontWeight;

  const TextStyle({
    this.color,
    this.textDecoration,
    this.fontFamily,
    this.fontWeight,
  });
}

class TextDecoration {
  /// The kind of text decoration.
  final DecorationType type;

  const TextDecoration({this.type});
}

enum DecorationType {
  Underline,
  Overline,
  LineThrough,
}

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

class Flex extends StatelessWidget {
  final List<Widget> children;
  final FlexDirection flexDirection;
  final String id;
  final List<String> classNames;

  const Flex({
    @required this.flexDirection,
    this.children = const [],
    this.id,
    this.classNames,
  });

  @override
  Node build() {
    Style style;
    if (flexDirection == FlexDirection.Column) {
      style = new Style('display: flex; flex-direction: column;');
    } else {
      style = new Style('display: flex; flex-direction: row;');
    }
    return new Element(
      'div',
      children: children,
      style: style,
      attributes: id != null ? {'id': id} : const {},
      classNames: classNames ?? const [],
    );
  }
}

class Row extends Flex {
  const Row({
    List<Node> children,
    String id,
    List<String> classNames,
  })
      : super(
          children: children,
          flexDirection: FlexDirection.Row,
          id: id,
          classNames: classNames,
        );
}

class Column extends Flex {
  const Column({
    List<Node> children,
    String id,
    List<String> classNames,
  })
      : super(
          children: children,
          flexDirection: FlexDirection.Column,
          id: id,
          classNames: classNames,
        );
}

enum FlexDirection {
  Row,
  Column,
}

class Container extends StatelessWidget {
  final Node child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration decoration;
  final String id;
  final List<String> classNames;

  const Container({
    this.child,
    this.padding,
    this.decoration,
    this.margin,
    this.id,
    this.classNames,
  });

  @override
  Node build() => new Element(
        'div',
        children: [child],
        style: _buildStyle(),
        attributes: id != null ? {'id': id} : const {},
        classNames: classNames ?? const [],
      );

  Style _buildStyle() {
    var buffer = new StringBuffer();
    if (padding != null) {
      buffer.write('padding: ${padding.top} ${padding.right} '
          '${padding.bottom} ${padding.left};');
    }
    if (margin != null) {
      buffer.write('margin: ${margin.top} ${margin.right} '
          '${margin.bottom} ${margin.left};');
    }
    if (decoration?.border != null) {
      if (decoration.border.left != null) {
        var b = decoration.border.left;
        buffer.write('border-left: ${b.width} ${b.color.toCssRGB()};');
      }
      if (decoration.border.right != null) {
        var b = decoration.border.right;
        buffer.write('border-right: ${b.width} ${b.color.toCssRGB()};');
      }
      if (decoration.border.top != null) {
        var b = decoration.border.top;
        buffer.write('border-top: ${b.width} ${b.color.toCssRGB()};');
      }
      if (decoration.border.bottom != null) {
        var b = decoration.border.bottom;
        buffer.write('border-bottom: ${b.width} ${b.color.toCssRGB()};');
      }
    }
    if (decoration?.color != null) {
      buffer.write('background-color: ${decoration.color.toCssRGB()};');
    }
    return new Style(buffer.toString());
  }
}

import 'dart:html' as html;

import 'package:meta/meta.dart';

import '../f2.dart';

/// A flexible element.
class Flex extends MultiChildRenderObjectWidget {
  final FlexAlign align;
  final FlexDirection direction;
  final JustifyContent justifyContent;
  final FlexWrap wrap;

  Flex({
    @required this.align,
    @required this.direction,
    @required this.justifyContent,
    @required this.wrap,
    @required List<Widget> children,
    Key key,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlex()
      ..align = align
      ..direction = direction
      ..justifyContent = justifyContent
      ..wrap = wrap;
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlex renderObject) {
    renderObject
      ..align = align
      ..direction = direction
      ..justifyContent = justifyContent
      ..wrap = wrap;
  }
}

class RenderFlex extends RenderObject {
  RenderFlex() : super(html.DivElement()) {
    element.style.display = 'flex';
  }

  FlexAlign get align => _align;
  FlexAlign _align;
  set align(FlexAlign newValue) {
    if (identical(newValue, _align)) {
      return;
    }
    element.style.alignItems = newValue._value;
    _align = newValue;
  }

  FlexDirection get direction => _direction;
  FlexDirection _direction;
  set direction(FlexDirection newValue) {
    if (identical(_direction, newValue)) {
      return;
    }
    element.style.flexDirection = newValue._value;
    _direction = newValue;
  }

  JustifyContent get justifyContent => _justifyContent;
  JustifyContent _justifyContent;
  set justifyContent(JustifyContent newValue) {
    if (identical(_justifyContent, newValue)) {
      return;
    }
    element.style.justifyContent = newValue._value;
    _justifyContent = newValue;
  }

  FlexWrap get wrap => _wrap;
  FlexWrap _wrap;
  set wrap(FlexWrap newValue) {
    if (identical(_wrap, newValue)) {
      return;
    }
    element.style.flexWrap = newValue._value;
    _wrap = newValue;
  }
}

/// A flexible element with column oriented children.
class Column extends Flex {
  /// Create a new column widget.
  Column({
    Key key,
    List<Widget> children = const [],
    FlexAlign align = FlexAlign.auto,
    JustifyContent justifyContent = JustifyContent.start,
    FlexWrap wrap = FlexWrap.noWrap,
  }) : super(
          key: key,
          children: children,
          align: align,
          direction: FlexDirection.column,
          justifyContent: justifyContent,
          wrap: wrap,
        );
}

/// A flexible element with row oriented children.
class Row extends Flex {
  /// Create a new row widget.
  Row({
    Key key,
    List<Widget> children = const [],
    FlexAlign align = FlexAlign.auto,
    JustifyContent justifyContent = JustifyContent.start,
    FlexWrap wrap = FlexWrap.noWrap,
  }) : super(
          key: key,
          children: children,
          align: align,
          direction: FlexDirection.row,
          justifyContent: justifyContent,
          wrap: wrap,
        );
}

/// A decoration which allows absolutely positioning a child.
///
/// The offset from either the window or a previous `relative` element in px.
class Positioned extends DecoratorWidget {
  final String left;
  final String top;

  Positioned({
    double leftOffset = 0.0,
    double topOffset = 0.0,
    @required Widget child,
    Key key,
  })  : left = '${leftOffset}px',
        top = '${topOffset}px',
        super(child: child, key: key);

  @override
  void decorate(RenderObject renderObject) {
    renderObject.element.style
      ..left = left
      ..top = top
      ..position = 'absoute';
  }
}

/// A decoration that controls the flex properties of a child.
class FlexChild extends DecoratorWidget {
  final int order;
  final double grow;
  final double shrink;
  final double basis;
  final FlexAlign alignSelf;

  const FlexChild({
    this.order,
    this.grow,
    this.shrink,
    this.basis,
    this.alignSelf,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  void decorate(RenderObject renderObject) {
    final html.CssStyleDeclaration style = renderObject.element.style;
    if (order == null) {
      style.order = null;
    } else {
      style.order = '${order}';
    }
    if (grow == null) {
      style.flexGrow = null;
    } else {
      style.flexGrow = '${grow}';
    }
    if (shrink == null) {
      style.flexShrink = null;
    } else {
      style.flexShrink = '${shrink}';
    }
    if (basis == null) {
      style.flexBasis = null;
    } else {
      style.flexBasis = '${basis}';
    }
    if (alignSelf == null) {
      style.alignSelf = null;
    } else {
      style.alignSelf = alignSelf._value;
    }
  }
}

/// Configuration for flex alignment properties.
@immutable
class FlexAlign {
  static const auto = const FlexAlign._('auto');
  static const start = const FlexAlign._('flex-start');
  static const end = const FlexAlign._('flex-end');
  static const center = const FlexAlign._('center');
  static const baseline = const FlexAlign._('baseline');
  static const stretch = const FlexAlign._('stretch');

  final String _value;

  const FlexAlign._(this._value);
}

/// Configuration for the flex direction.
@immutable
class FlexDirection {
  static const row = const FlexDirection._('row');
  static const rowReverse = const FlexDirection._('row-reverse');
  static const column = const FlexDirection._('column');
  static const columnReverse = const FlexDirection._('column-reverse');

  final String _value;

  const FlexDirection._(this._value);
}

/// Configuration for wrapping of flex items across lines.
@immutable
class FlexWrap {
  static const wrap = const FlexWrap._('wrap');
  static const noWrap = const FlexWrap._('no-wrap');
  static const wrapReverse = const FlexWrap._('wrap-reverse');

  final String _value;

  const FlexWrap._(this._value);
}

/// Configuration for justification of flex items.
@immutable
class JustifyContent {
  static const start = const JustifyContent._('start');
  static const end = const JustifyContent._('end');
  static const center = const JustifyContent._('center');
  static const spaceBetween = const JustifyContent._('space-between');
  static const spaceAround = const JustifyContent._('space-around');
  static const spaceEvenly = const JustifyContent._('space-evenly');

  final String _value;

  const JustifyContent._(this._value);
}

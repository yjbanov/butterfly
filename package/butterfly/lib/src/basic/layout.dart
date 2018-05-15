import 'package:meta/meta.dart';

import '../framework.dart';
import '../surface.dart';

/// A flexible element.
class Flex extends MultiChildWidget {
  final FlexAlign align;
  final FlexDirection direction;
  final JustifyContent justifyContent;
  final FlexWrap wrap;

  const Flex({
    @required this.align,
    @required this.direction,
    @required this.justifyContent,
    @required this.wrap,
    @required List<Widget> children,
    Key key,
  }) : super(key: key, children: children);

  @override
  Renderer instantiate(ParentRenderer parent) => new _FlexRenderer(parent);
}

class _FlexRenderer extends MultiChildParentRenderer<Flex> {
  _FlexRenderer(ParentRenderer parent) : super(parent);

  @override
  final Surface surface = new Surface();

  @override
  void update(Flex newWidget) {
    /// On the initial build, insert all styles.
    if (widget == null) {
      surface
        ..display = 'flex'
        ..justifyContent = newWidget.justifyContent._value
        ..flexDirection = newWidget.direction._value
        ..flexWrap = newWidget.wrap._value
        ..alignItems = newWidget.align._value;
    } else if (!identical(newWidget, widget)) {
      if (!identical(newWidget.justifyContent, widget.justifyContent)) {
        surface.justifyContent = newWidget.justifyContent._value;
      }
      if (!identical(newWidget.wrap, widget.wrap)) {
        surface.flexWrap = newWidget.wrap._value;
      }
      if (!identical(newWidget.align, widget.align)) {
        surface.alignItems = newWidget.align._value;
      }
      if (!identical(newWidget.direction, widget.direction)) {
        surface.flexDirection = newWidget.direction._value;
      }
    }
    super.update(newWidget);
  }
}

/// A flexible element with column oriented children.
class Column extends Flex {
  /// Create a new column widget.
  const Column({
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
  const Row({
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
class Positioned extends Decoration {
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
  DecorationRenderer instantiate(ParentRenderer parent) =>
      new PositionedRenderer(parent);
}

/// A [Renderer] that applies absolute positioning to a child.
class PositionedRenderer extends DecorationRenderer<Positioned> {
  PositionedRenderer(ParentRenderer parent) : super(parent);

  void update(Positioned newWidget) {
    if (!identical(newWidget, widget)) {
      surface
        ..left = newWidget.left
        ..top = newWidget.left
        ..position = 'absoute';
    }
    super.update(newWidget);
  }
}

/// A decoration that controls the flex properties of a child.
class FlexChild extends Decoration {
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
  DecorationRenderer instantiate(ParentRenderer parent) =>
      new _FlexChildDecoration(parent);
}

/// A [Renderer] that applies flex properties to a child element.
class _FlexChildDecoration extends DecorationRenderer<FlexChild> {
  _FlexChildDecoration(ParentRenderer parent) : super(parent);

  void update(FlexChild newWidget) {
    if (!identical(newWidget, widget)) {
      if (newWidget.order == null) {
        surface.order = null;
      } else {
        surface.order = '${newWidget.order}';
      }
      if (newWidget.grow == null) {
        surface.grow = null;
      } else {
        surface.grow = '${newWidget.grow}';
      }
      if (newWidget.shrink == null) {
        surface.shrink = null;
      } else {
        surface.shrink = '${newWidget.shrink}';
      }
      if (newWidget.basis == null) {
        surface.basis = null;
      } else {
        surface.basis = '${newWidget.basis}';
      }
      if (newWidget.alignSelf == null) {
        surface.alignSelf = null;
      } else {
        surface.alignSelf = newWidget.alignSelf._value;
      }
    }
    super.update(newWidget);
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

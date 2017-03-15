import 'package:charcode/charcode.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

/// A proof of concept rewriter for simple XML like expressions.
///
/// Technically all of these methods should be private but I think
/// underscores are ugly.
///
///     new Dx('<div>${_foo}</div>'); =>
///       new div()([_foo]);
///
///     new Dx('''
///     <myElement bar=${fizz} bazz={2}>
///       <div>Foo</div>
///     </myElement>
///     '''); =>
///
///      new MyElement(bar=fizz, bazz=2)([
///        new Div()(["Foo"]),
///      ]);
///
///      new Dx('''
///        <div>
///           "This is a text Ast"
///           "${localTextAst}"
///        </div>
///      '''); =>
///
///      div()([text("this is a text Ast"), text(localTextAst)])
///
///      new Dx('<my-element></my-element>'); =>
///
///      new Element('my-element')();
///
class Parser {
  List<Ast> _nodes;
  List<int> _runes;
  int _index;

  Parser();

  int get peek => _runes[_index];

  /// Parses the given dart extension (dx) fragment into dart code.
  Ast parse(String source) {
    _nodes = <Ast>[];
    _runes = source.runes.toList();
    _index = 0;
    while (true) {
      consumeWhitespace();
      if (isDone()) {
        break;
      }
      switch (peek) {
        case $open_angle:
          consume();
          parseElement();
          break;
        case $dollar:
          parseFragment();
          break;
        case $double_quote:
          parseText();
          break;
        default:
          throw new Exception('Illegal char: ${new String.fromCharCode(peek)}');
      }
    }
    return _nodes.single;
  }

  /// Parses "......" into a text Ast.
  void parseText() {
    final buffer = <int>[$double_quote];
    expect($double_quote);
    while (peek != $double_quote) {
      buffer.add(peek);
      consume();
    }
    expect($double_quote);
    buffer.add($double_quote);
    _nodes.add(new Text(new String.fromCharCodes(buffer)));
  }

  /// Parses `${...}` into a fragment.
  void parseFragment() {
    final buffer = <int>[];
    expect($dollar);
    expect($open_brace);
    while (peek != $close_brace) {
      buffer.add(peek);
      consume();
    }
    expect($close_brace);
    _nodes.add(new Fragment(new String.fromCharCodes(buffer)));
  }

  /// Parsers the start of an element.
  ///
  ///  `<` and `</`
  ///
  void parseElement() {
    if (peek == $slash) {
      consume();
      parseClosingAst();
    } else {
      parseOpeningAst();
    }
  }

  /// Parses the name of an opening element
  ///
  ///     `<my-element` or `<MyClass`
  ///       ^^^^^^^^^^       ^^^^^^^
  void parseOpeningAst() {
    consumeWhitespace();
    if (isLowerCase(peek)) {
      _nodes.add(new Node.element(parseElementName()));
    } else {
      _nodes.add(new Node.constructor(parseClassName()));
    }
    parseArguments();
  }

  /// Parses the attributes of an XML node into an [Argument]
  ///
  ///     <div foo=${bar} fizz=${buzz}
  ///          ^^^^^^^^^  ^^^^^^^^^^^^
  void parseArguments() {
    while (true) {
      consumeWhitespace();
      if (peek == $slash) {
        consume();
        expect($close_angle);
        break;
      } else if (peek == $close_angle) {
        consume();
        break;
      } else {
        // TODO: replace this with a more accurate procedure that handles spaces.
        final name = <int>[];
        final value = <int>[];
        while (peek != $equal) {
          name.add(peek);
          consume();
        }
        expect($equal);
        expect($dollar);
        expect($open_brace);
        while (peek != $close_brace) {
          value.add(peek);
          consume();
        }
        expect($close_brace);
        (_nodes.last as Node).arguments.add(new Argument(
            new String.fromCharCodes(name), new String.fromCharCodes(value)));
      }
    }
  }

  /// Parses a closing node and collects Ast nodes into their parents.
  ///
  ///     </div>
  ///       ^^^
  void parseClosingAst() {
    final name = isLowerCase(peek) ? parseElementName() : parseClassName();
    consumeWhitespace();
    expect($close_angle);
    final parent = _nodes.lastWhere((Ast) => Ast.name == name);
    Ast removed;
    do {
      removed = _nodes.removeLast();
      if (parent != removed) {
        (parent as Node).children.insert(0, removed);
      } else {
        _nodes.add(parent);
      }
    } while (removed != parent);
  }

  /// Parses the name of a widget Node like `_PrivateClass` or `Foo123`.
  String parseClassName() {
    final buffer = new StringBuffer();
    if (isUpperCase(peek) || peek == $underscore) {
      buffer.writeCharCode(peek);
      consume();
    } else {
      throw new Exception(
          'expected class name but found ${new String.fromCharCode(peek)}');
    }
    while (isDartCase(peek)) {
      buffer.writeCharCode(peek);
      consume();
    }
    return buffer.toString();
  }

  /// Parses the name of an html or polymer element like `div` or `my-element`
  String parseElementName() {
    final buffer = new StringBuffer();
    if (isLowerCase(peek)) {
      buffer.writeCharCode(peek);
      consume();
    } else {
      throw new Exception('');
    }
    while (isXmlCase(peek)) {
      buffer.writeCharCode(peek);
      consume();
    }
    return buffer.toString();
  }

  /// Consumes whitespace elements.
  void consumeWhitespace() {
    while (!isDone() &&
        (peek == $space || peek == $tab || peek == $lf || peek == $vt)) {
      consume();
    }
  }

  /// Consumes the given char, or throws if it is not found.
  void expect(int char) {
    if (peek != char) {
      throw new Exception('Expected: ${new String.fromCharCode(char)} found '
          '${new String.fromCharCode(peek)} at ${_index}');
    }
    consume();
  }

  /// Moves the index forward.
  void consume([int chars = 1]) {
    _index += chars;
  }

  bool isDone() => _index >= _runes.length;

  static bool isLetter(int char) =>
      (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A);

  static bool isDigit(int char) => (char >= 0x30 && char <= 0x39);

  static bool isUpperCase(int char) => (char >= 0x41 && char <= 0x5A);

  static bool isLowerCase(int char) => (char >= 0x61 && char <= 0x7A);

  static bool isDartCase(int char) =>
      isDigit(char) || isLetter(char) || char == $underscore;

  static bool isXmlCase(int char) =>
      isLetter(char) || isDigit(char) || char == $dash || char == $underscore;
}

/// Base class for Dart Extension's heterogeneous Ast.
abstract class Ast {
  /// The name of the node instance.
  String get name;

  const Ast();

  /// Produces regular Dart code from the Dart Extension AST.
  String toSource();
}

/// A Node, with either element or constructor semantics.
class Node extends Ast {
  final bool isElement;
  final String name;
  final List<Argument> arguments;
  final List<Ast> children;

  const Node(this.name, this.isElement, this.arguments, this.children);

  Node.element(this.name)
      : isElement = true,
        arguments = <Argument>[],
        children = <Ast>[];

  Node.constructor(this.name)
      : isElement = false,
        arguments = <Argument>[],
        children = <Ast>[];

  @override
  String toSource() {
    String nested;
    final args = arguments.map((x) => '$x').join(', ');
    if (children.isEmpty) {
      nested = '';
    } else if (children.length == 1 && children.first is Fragment) {
      nested = '${children.first}';
    } else {
      nested = '[' + children.map((x) => '$x').join(', ') + ']';
    }
    if (isElement) {
      return 'element(\'$name\'${args.isNotEmpty ? ", " : ""}$args)($nested)';
    }
    return 'new $name($args)($nested)';
  }

  @override
  String toString() => '<Node:$name:$arguments:$children>';

  @override
  bool operator ==(Object other) =>
      other is Node &&
      other.isElement == isElement &&
      other.name == name &&
      listsEqual(other.arguments, arguments) &&
      listsEqual(other.children, children);

  @override
  int get hashCode =>
      hash4(isElement, name, hashObjects(arguments), hashObjects(children));
}

/// Represents an XML attribute mapped to a named argument.
class Argument extends Ast {
  final String name;
  final String value;

  const Argument(this.name, this.value);

  @override
  String toString() => '<Argument:$name:$value>';

  @override
  String toSource() => '$name:$value';

  @override
  bool operator ==(Object other) =>
      other is Argument && other.name == name && other.value == value;

  @override
  int get hashCode => hash2(name, value);
}

/// Represents an inline fragment, usually a variable passed as a child.
class Fragment extends Ast {
  String get name => 'fragment';
  final String value;

  const Fragment(this.value);

  @override
  String toString() => '<Fragment:$value>';

  @override
  String toSource() => value;

  @override
  bool operator ==(Object other) => other is Fragment && other.value == value;

  @override
  int get hashCode => name.hashCode;
}

/// A text literal Ast
class Text extends Ast {
  String get name => 'text';
  final String value;

  const Text(this.value);

  @override
  String toString() => '<Text:$value>';

  @override
  String toSource() => 'text($value)';

  @override
  bool operator ==(Object other) => other is Text && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

import 'dart:io';


/// A proof of concept rewriter for simple XML like expressions.
///
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
///      new Dx('<my-element></my-element>');
///
///      Error! This isn't real xml
///
///

enum State {
  Neutral,
  OpenNode,
  CloseNode,
  Name,
  Args,
  ArgName,
  Text,
}

class Parser {
  const Parser();

  String parse(String source) {
    var state = State.Neutral;
    var nodes = <Node>[];
    var runes = source.runes.toList();
    var index = 0;

    while (index < runes.length) {
      var char = runes[index];
      switch (state) {
        case State.Neutral:
          if (index >= runes.length) {
            break;
          }
          while (_isSpace(char)) {
            index++;
            if (index >= runes.length) {
              break;
            }
            char = runes[index];
          }
          if (index >= runes.length) {
            break;
          }
          // `<`
          if (char != 0x3C) {
            state = State.Text;
            break;
          }
          index++;
          char = runes[index];
          if (char == 0x2F) {
            index++;
            state = State.CloseNode;
          } else {
            state = State.OpenNode;
          }
          break;
        case State.OpenNode:
          // `<`
          nodes.add(new CtrNode());
          state = State.Name;
          break;
        case State.Name:
          var buffer = <int>[];
          if (_isLetter(char)) {
            buffer.add(char);
            index++;
          } else {
            throw new Exception(
                'Element name must be valid identifer. found $char - $state : $index');
          }
          char = runes[index];
          while (_isLetter(char) || _isNum(char)) {
            buffer.add(char);
            index++;
            char = runes[index];
          }
          nodes.last.name = new String.fromCharCodes(buffer);
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          // `>`
          if (char == 0x3E) {
            index++;
            state = State.Neutral;
          } else {
            state = State.Args;
          }
          break;
        case State.CloseNode:
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          var buffer = <int>[];
          if (_isLetter(char)) {
            buffer.add(char);
            index++;
          } else {
            throw new Exception(
                'Element name must be valid identifer. found $char - $state : $index');
          }
          char = runes[index];
          while (_isLetter(char) || _isNum(char)) {
            buffer.add(char);
            index++;
            char = runes[index];
          }
          var name = new String.fromCharCodes(buffer);
          var parent = nodes.lastWhere((node) => node.name == name);
          Node removed;
          do {
            removed = nodes.removeLast();
            if (parent != removed) {
              parent.children.add(removed);
            } else {
              nodes.add(parent);
            }
          } while (removed != parent);
          state = State.Neutral;
          index++;
          break;
        case State.Args:
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          if (char == 0x3E) {
            index++;
            state = State.Neutral;
          } else {
            state = State.ArgName;
            break;
          }
          break;
        case State.ArgName:
          var buffer = <int>[];
          if (_isLetter(char)) {
            buffer.add(char);
            index++;
          } else {
            throw new Exception(
                'Element name must be valid identifer. found $char - $state : $index');
          }
          char = runes[index];
          while (_isLetter(char) || _isNum(char)) {
            buffer.add(char);
            index++;
            char = runes[index];
          }
          var name = new String.fromCharCodes(buffer);
          buffer.clear();
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          if (!char == 0x3D) {
            throw new Exception('Expected attribute to equal something');
          }
          index++;
          char = runes[index];
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          // expecting {literal} or ${literal}
          if (char == 0x24) {
            index++;
            char = runes[index];
          }
          if (char != 0x7B) {
            throw new Exception(
                'Values must be in \${\} or \{\}. found ${new String.fromCharCode(char)} : $state : $index');
          }
          index++;
          char = runes[index];
          while (char != 0x7D) {
            buffer.add(char);
            index++;
            char = runes[index];
          }
          index++;
          var value = new String.fromCharCodes(buffer);
          nodes.last.arguments.add(new CtrArg()
            ..name = name
            ..value = value);
          state = State.Args;
          break;
        case State.Text:
          // expecting {literal} or ${literal}
          while (_isSpace(char)) {
            index++;
            char = runes[index];
          }
          var buffer = <int>[];
          if (char == 0x24) {
            index++;
            char = runes[index];
          }
          if (char != 0x7B) {
            throw new Exception(
                'Values must be in \${\} or \{\}. found ${new String.fromCharCode(char)} : $state : $index');
          }
          index++;
          char = runes[index];
          while (char != 0x7D) {
            buffer.add(char);
            index++;
            char = runes[index];
          }
          index++;
          var value = new String.fromCharCodes(buffer);
          nodes.add(new TextNode()..value = value);
          state = State.Neutral;
          break;
      }
    }
    return '${nodes.single};';
  }

  bool _isSpace(int char) => char == 0x20 || char == 0x9 || char == 0xA;

  bool _isLetter(int char) =>
      (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A);

  bool _isNum(int char) => (char >= 0x30 && char <= 0x39);
}

abstract class Node {
  String get name;
  set name(String value);
}

class CtrNode extends Node {
  String name;
  final List<CtrArg> arguments = [];
  final List<CtrNode> children = [];

  CtrNode();

  String toString() {
    var start = name.codeUnitAt(0);
    var prefix = (start >= 0x41 && start <= 0x5A) ? 'new $name' : '$name';
    var argNodes = arguments.map((arg) => '$arg').join(',');
    var childNodes = children.reversed.map((node) => '$node').join(",");
    if (children.isEmpty) {
      return '$prefix($argNodes)()';
    }
    return '$prefix($argNodes)([$childNodes])';
  }
}

class CtrArg extends Node {
  String name;
  String value;
  
  CtrArg();

  String toString() => '$name: $value';
}

class TextNode extends Node {
  String get name => 'text';
  set name(String value) {}

  String value;

  String toString() => 'text($value)';
}


void main(List<String> args) {
  final parser = new Parser();
  final fileName = args.single;
  if (!fileName.endsWith('.dx.dart')) {
    throw new Exception('Not an annotated DX file');
  }
  final source = new File(fileName).readAsStringSync();
  final runes = source.runes.toList();
  String modified;
  for (Match match in [new RegExp('new Dx\\(').firstMatch(source)]) {
    var buffer = new StringBuffer();
    var cur = match.start + 7;
    while (runes[cur] == 0x27) {
      cur++;
    }
    while (true) {
      if (runes[cur] == 0x27 && runes[cur+1] == 0x27 && runes[cur+2] == 0x27) {
        break;
      }
      buffer.writeCharCode(runes[cur]);
      cur++;
    }
    cur += 2;
    print(buffer.toString());
    modified = source.replaceRange(match.start, cur+3, parser.parse(buffer.toString()));
  }
  
  final newFileName = fileName.replaceFirst('.dx.dart', '.dart');
  final result = new File(newFileName)..createSync();
  result.writeAsStringSync(modified);
}
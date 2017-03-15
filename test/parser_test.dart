import 'package:test/test.dart';
import '../tool/parser.dart';

@TestOn('vm')
void main() {
  group('Parser', () {
    Parser parser;
    setUp(() {
      parser = new Parser();
    });

    Ast parse(String source) => parser.parse(source);

    test('parses a single node', () {
      expect(
          parse(r'<div></div>'), const Node('div', true, const [], const []));
    });

    test('parses a node with an attribute, removing interpolation.', () {
      expect(
          parse(r'<div foo=${bar}></div>'),
          const Node(
              'div', true, const [const Argument('foo', 'bar')], const []));
    });

    test('parses a node with multiple attributes', () {
      expect(
          parse(r'<div foo=${bar} bazz=${22} fizz=${local}></div>'),
          const Node('div', true, const [
            const Argument('foo', 'bar'),
            const Argument('bazz', '22'),
            const Argument('fizz', 'local'),
          ], const []));
    });

    test('parses a node with a single child', () {
      expect(
          parse(r'<div><my-el></my-el></div>'),
          const Node('div', true, const [], const [
            const Node('my-el', true, const [], const []),
          ]));
    });

    test('parses a node with multiple children', () {
      expect(
          parse(r'''
        <div>
          "This is text"
          <Foo></Foo>
          ${variable}
        </div>
      '''),
          const Node('div', true, const [], const [
            const Text('"This is text"'),
            const Node('Foo', false, const [], const []),
            const Fragment('variable'),
          ]));
    });

    test('parses a void node', () {
      expect(parse(r'''
      <MyComponent/>
    '''), const Node('MyComponent', false, const [], const []));
    });
  });

  group('AST Desugaring', () {
    test('elements transpile to element() calls', () {
      expect(const Node('div', true, const [], const []).toSource(),
          'element(\'div\')()');
    });
  });
}

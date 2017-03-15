import 'dart:io';
import 'parser.dart';

/// TODO: Replace this with the analyzer API (unresovled types);
void main(List<String> args) {
  final parser = new Parser();
  final fileName = args.single;
  if (!fileName.endsWith('.dx.dart')) {
    throw new Exception('Not an annotated dx file');
  }
  final source = new File(fileName).readAsStringSync();
  String modified = source;

  while (true) {
    final match = new RegExp(" Dx\\('''[^']*'''\\)").firstMatch(modified);
    if (match == null) {
      break;
    }
    final code = modified.substring(match.start + 7, match.end - 4);
    modified = modified.replaceRange(
        match.start, match.end, ' ${parser.parse(code).toSource()};');
  }

  final newFileName = fileName.replaceFirst('.dx.dart', '.dart');
  final result = new File(newFileName)..createSync();
  result.writeAsStringSync(modified);
}

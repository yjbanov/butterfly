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

/// A tabel row.
class TableRow {
  final List<TableCell> cells;

  TableRow({this.cells = const []});

  int get length => cells.length;
}

/// A table cell.
class TableCell {
  final Node child;

  TableCell({this.child});
}

/// Create a table
class Table extends StatelessWidget {
  final List<TableRow> rows;

  const Table({
    this.rows = const [],
  });

  @override
  Node build() {
    assert(rows.map((row) => row.length).toSet().length == 1,
        'Each row much have the same number of cells');

    var children = <Node>[];
    for (var row in rows) {
      var rowChildren = <Node>[];
      for (var cell in row.cells) {
        var cellChild = new Element('td', children: [cell.child]);
        rowChildren.add(cellChild);
      }
      var rowWidget = new Element('tr', children: rowChildren);
      children.add(rowWidget);
    }

    return new Element(
      'table',
      children: children,
    );
  }
}

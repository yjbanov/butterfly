class Surface {
  Surface();

  String text;
  String padding;
  String border;
  String display;
  String justifyContent;
  String flexDirection;
  String flexWrap;
  String alignItems;
  String left;
  String top;
  String position;
  String order;
  String grow;
  String shrink;
  String basis;
  String alignSelf;

  final List<Surface> _children = <Surface>[];

  void append(Surface child) {
    _children.add(child);
  }

  void removeChild(Surface child) {
    _children.remove(child);
  }

  void insertBefore(Surface child, Surface ref) {
    final int index = _children.indexOf(ref);
    if (index == -1) {
      throw new SurfaceError('Child not found:\n'
          '  Child: $ref\n'
          '  Parent: $this');
    }
    _children.insert(index, child);
  }

  int get childCount => _children.length;

  String debugPrintToHtml() {
    final StringBuffer buffer = new StringBuffer();
    _debugHtmlInto(buffer);
    return buffer.toString();
  }

  void _debugHtmlInto(StringBuffer buffer) {
    buffer.write('<div>');
    if (text != null && text.isNotEmpty) {
      buffer.write(text);
    }
    for (Surface child in _children) {
      child._debugHtmlInto(buffer);
    }
    buffer.write('</div>');
  }
}

class SurfaceError extends Error {
  SurfaceError(this.description);

  final String description;
}

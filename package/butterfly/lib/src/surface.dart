part of butterfly;

abstract class Surface {
  String id;
}

class ContainerSurface extends Surface {
  void append(Surface child) { }
  Map<String, String> get style => null;
}

class TextSurface extends Surface {
  TextSurface(this.text);

  String text;
}

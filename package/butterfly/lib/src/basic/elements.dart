part of butterfly;

/// A text node.
/// 
/// TODO(jonahwilliams): can element updates render text directly without a 
/// tag?
class Text extends Node {
  final String value;

  const Text(this.value, {Key key}) : super(key: key);
  
  @override
  RenderNode instantiate(Tree tree) => new TextRenderNode(tree);
}

/// A render node for [Text].
class TextRenderNode extends RenderNode<Text> {
  TextRenderNode(Tree tree) : super(tree);

  @override
  bool canUpdateUsing(Node node) => node is Text;

  @override
  void dispatchEvent(_) {}

  @override
  void visitChildren(_) {}

  @override
  void update(Text newConfiguration, ElementUpdate update) {
    if (newConfiguration.value != configuration.value) {
      update.updateText(newConfiguration.value);
    }
    super.update(newConfiguration, update);
  }
}



/// An element with no children.
class VoidElement extends LeafElementBase {
  final Map<String, String> attributes;
  final Map<EventType, EventListener> eventListeners;
  final Style style;
  final List<Style> styles;
  final List<String> classNames;
  final String text;

  VoidElement(String tag, {
    Key key,
    this.attributes,
    this.eventListeners,
    this.style,
    this.styles,
    this.classNames,
    this.text,
  }) : super(tag);

  @override
  RenderNode instantiate(Tree t) => new VoidRenderElement(t);
}

//// A render node for a void element.
///
/// TODO(jonahwilliams): this is just copied from the element render node.
class VoidRenderElement extends RenderLeafElementBase<VoidElement> {
  VoidRenderElement(Tree tree) : super(tree);

  @override
  bool canUpdateUsing(Node node) {
    return node is VoidElement && node.tag == this._configuration.tag;
  }

  @override
  void update(VoidElement newConfiguration, ElementUpdate update) {
    if (_configuration != null) {
      if (_configuration.text != newConfiguration.text) {
        update.updateText(newConfiguration.text);
      }
      _updateEventListeners(newConfiguration.eventListeners, update);
      _updateAttributes(newConfiguration.attributes, update);
      _updateStyles(newConfiguration, update);
    } else {
      if (newConfiguration.eventListeners != null &&
          newConfiguration.eventListeners.isNotEmpty) {
        ensureButterflyId(update);
      }

      update.updateText(newConfiguration.text);

      if (newConfiguration.attributes != null &&
          newConfiguration.attributes.isNotEmpty) {
        newConfiguration.attributes.forEach((String name, String value) {
          update.updateAttribute(name, value);
        });
      }

      _setStyles(newConfiguration, update);
    }
    super.update(newConfiguration, update);
  }

  void _updateEventListeners(
      Map<EventType, EventListener> eventListeners, ElementUpdate update) {
    if (eventListeners != null && eventListeners.isNotEmpty) {
      ensureButterflyId(update);
    }
  }

  void _updateAttributes(Map<String, String> newAttrs, ElementUpdate update) {
    final oldAttrs = _configuration.attributes;
    if (newAttrs != oldAttrs) {
      // TODO(yjbanov): attribute updates are probaby sub-optimal.

      // Find updates
      for (final newName in newAttrs.keys) {
        final newValue = newAttrs[newName];
        if (oldAttrs[newName] != newValue) {
          update.updateAttribute(newName, newValue);
        }
      }

      // Find removes
      for (final oldName in oldAttrs.keys) {
        if (!newAttrs.containsKey(oldName)) {
          // TODO(yjbanov): this won't go far. Need explicit "remove attribute" op.
          update.updateAttribute(oldName, '');
        }
      }
    }
  }

  void _updateStyles(VoidElement newConfig, ElementUpdate update) {
    Style oldStyle = _configuration.style;
    Style newStyle = newConfig.style;
    List<Style> oldStyles = _configuration.styles;
    List<Style> newStyles = newConfig.styles;
    List<String> oldClassNames = _configuration.classNames;
    List<String> newClassNames = newConfig.classNames;

    if (newStyle != oldStyle ||
        newStyles == null && oldStyles != null ||
        newStyles != null && oldStyles == null ||
        newClassNames == null && oldClassNames != null ||
        newClassNames != null && oldClassNames == null ||
        newStyles != null && newStyles.length != oldStyles.length ||
        newClassNames != null && newClassNames.length != oldClassNames.length) {
      if (newStyle != null) {
        if (!newStyle._isRegistered) {
          _tree.registerStyle(newStyle);
        }
        update.addClassName(newStyle.identifierClass);
      }
      if (newStyles != null) {
        for (int i = 0; i < newStyles.length; i++) {
          final Style style = newStyles[i];
          if (!style._isRegistered) {
            _tree.registerStyle(style);
          }
          update.addClassName(style.identifierClass);
        }
      }
      if (newClassNames != null) {
        for (int i = 0; i < newClassNames.length; i++) {
          update.addClassName(newClassNames[i]);
        }
      }
    }
  }

  void _setStyles(VoidElement newConfig, ElementUpdate update) {
    Style newStyle = newConfig.style;
    List<Style> newStyles = newConfig.styles;
    List<String> newClassNames = newConfig.classNames;

    if (newStyle != null) {
      if (!newStyle._isRegistered) {
        _tree.registerStyle(newStyle);
      }
      update.addClassName(newStyle.identifierClass);
    }
    if (newStyles != null) {
      for (int i = 0; i < newStyles.length; i++) {
        final Style style = newStyles[i];
        if (!style._isRegistered) {
          _tree.registerStyle(style);
        }
        update.addClassName(style.identifierClass);
      }
    }
    if (newClassNames != null) {
      for (int i = 0; i < newClassNames.length; i++) {
        update.addClassName(newClassNames[i]);
      }
    }
  }

  @override
  void dispatchEvent(Event event) {
    if (this.butterflyId == event.targetBaristaId) {
      final listener = _configuration.eventListeners[event.type];
      if (listener != null) {
        listener(event);
      }
    }
  }
}
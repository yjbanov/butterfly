// Copyright 2017 Google Inc. All Rights Reserved.
//
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

class ElementUpdate {
  ElementUpdate(int index) : _index = index;

  // insert-before index if this is being inserted.
  // child index if this is being updated.
  final int _index;

  String _tag = "";
  String _key = "";
  String _bid = "";

  String _text = null;

  final List<int> _removes = <int>[];
  final List<Move> _moves = <Move>[];

  final List<ElementUpdate> _childElementInsertions = <ElementUpdate>[];
  final List<ElementUpdate> _childElementUpdates = <ElementUpdate>[];
  final List<AttributeUpdate> _attributes = <AttributeUpdate>[];
  final List<String> _classNames = <String>[];

  /// Appends the JSON representation of this update into [buffer].
  bool render(Map<String, Object> js) {
    bool wroteData = false;

    if (_tag != "") {
      js["tag"] = _tag;
      wroteData = true;
    }

    if (_bid != "") {
      js["bid"] = _bid;
      wroteData = true;
    }

    if (_text != null) {
      js["text"] = _text;
      wroteData = true;
    }

    if (_removes.isNotEmpty) {
      final jsRemoves = <int>[];
      for (int index in _removes) {
        jsRemoves.add(index);
      }
      js["remove"] = jsRemoves;
      wroteData = true;
    }

    if (_moves.isNotEmpty) {
      final jsMoves = <int>[];
      for (Move move in _moves) {
        jsMoves.add(move.insertionIndex);
        jsMoves.add(move.moveFromIndex);
      }
      js["move"] = jsMoves;
      wroteData = true;
    }

    if (_childElementInsertions.isNotEmpty) {
      final jsInsertions = <Map<String, Object>>[];
      for (ElementUpdate insertion in _childElementInsertions) {
        final jsInsertion = <String, Object>{};
        jsInsertion["index"] = insertion._index;
        final buf = new StringBuffer();
        insertion.printHtml(buf);
        jsInsertion["html"] = buf.toString();
        jsInsertions.add(jsInsertion);
      }
      js["insert"] = jsInsertions;
      wroteData = true;
    }

    if (_childElementUpdates.isNotEmpty) {
      final jsUpdates = <Map<String, Object>>[];
      for (ElementUpdate update in _childElementUpdates) {
        final childUpdate = <String, Object>{};
        if (update.render(childUpdate)) {
          jsUpdates.add(childUpdate);
        }
      }

      if (jsUpdates.isNotEmpty) {
        js["update-elements"] = jsUpdates;
        wroteData = true;
      }
    }

    if (_attributes.isNotEmpty) {
      final jsAttrUpdates = <String, Object>{};
      for (AttributeUpdate attrUpdate in _attributes) {
        jsAttrUpdates[attrUpdate.name] = attrUpdate.value;
      }
      js["attrs"] = jsAttrUpdates;
      wroteData = true;
    }

    if (_classNames.isNotEmpty) {
      final jsClassNames = <String>[];
      for (String className in _classNames) {
        jsClassNames.add(className);
      }
      js["classes"] = jsClassNames;
      wroteData = true;
    }

    if (wroteData) {
      js["index"] = _index;
    }

    return wroteData;
  }

  /// Assumes that this element update is exlusively made of insertions and
  /// renders it as a plain HTML into the given [buffer].
  void printHtml(StringBuffer buf) {
    if (_index != -1) {  // we don't print host tag.
      buf.write("<${_tag}");

      if (_key != "") {
        buf.write(' _bkey="${_key}"');
      }

      if (_attributes.isNotEmpty) {
        for (final AttributeUpdate attr in _attributes) {
          buf.write(' ${attr.name}="${attr.value}"');
        }
      }

      if (_classNames.isNotEmpty) {
        buf.write(' class="');
        for (int i = 0; i < _classNames.length; i++) {
          buf.write(_classNames[i]);
          if (i + 1 < _classNames.length) {
            buf.write(' ');
          }
        }
        buf.write('"');
      }

      if (_bid != '') {
        buf.write(' _bid="${_bid}"');
      }

      buf.write('>');
    }

    if (_text != null) {
      buf.write(_text);
    }

    for(final childElement in _childElementInsertions) {
      childElement.printHtml(buf);
    }

    if (_index != -1) {
      buf.write('</${_tag}>');
    }
  }

  void removeChild(int index) { _removes.add(index); }

  void moveChild(int insertionIndex, int moveFrom) {
    _moves.add(new Move(insertionIndex, moveFrom));
  }

  ElementUpdate insertChildElement(int insertionIndex) {
    _childElementInsertions.add(new ElementUpdate(insertionIndex));
    return _childElementInsertions.last;
  }

  ElementUpdate updateChildElement(int index) {
    _childElementUpdates.add(new ElementUpdate(index));
    return _childElementUpdates.last;
  }

  void set tag(String tag) {
    _tag = tag;
  }

  void set key(Key key) {
    _key = '${key}';
  }

  void updateText(String text) { _text = text; }

  void updateAttribute(String name, String value) {
    _attributes.add(new AttributeUpdate(name, value));
  }

  void updateBaristaId(String bid) {
    _bid = bid;
  }

  void addClassName(String name) {
    _classNames.add(name);
  }
}

class AttributeUpdate {
  final String name;
  final String value;

  AttributeUpdate(this.name, this.value);
}

class Move {
  Move(this.insertionIndex, this.moveFromIndex);

  final int insertionIndex;
  final int moveFromIndex;
}

class TreeUpdate {
  TreeUpdate();

  final ElementUpdate _rootUpdate = new ElementUpdate(0);

  bool _createMode = false;
  String _styleCss;

  ElementUpdate createRootElement() {
    _createMode = true;
    return _rootUpdate;
  }

  ElementUpdate updateRootElement() {
    _createMode = false;
    return _rootUpdate;
  }

  void installStyles(String styleCss) {
    this._styleCss = styleCss;
  }

  Map<String, Object> render({int indent = 0}) {
    final js = <String, Object>{};
    if (_createMode) {
      final html = new StringBuffer();
      _rootUpdate.printHtml(html);
      js['create'] = html.toString();
    } else {
      final jsRootUpdate = <String, Object>{};
      if (_rootUpdate.render(jsRootUpdate)) {
        js['update'] = jsRootUpdate;
      }
    }
    if (_styleCss != null) {
      js['styles'] = _styleCss;
    }

    return js;
  }
}

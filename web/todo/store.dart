// Copyright 2016 Google Inc. All Rights Reserved.
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

typedef void ChangeListener();

/// A simple observable model object.
///
/// Extend it to get concrete observable objects.
class Model {
  List<ChangeListener> _listeners;

  void addListener(ChangeListener listener) {
    _listeners ??= <ChangeListener>[];
    _listeners.add(listener);
  }

  void removeListener(ChangeListener listener) {
    if (_listeners == null) return;
    _listeners.removeWhere((l) => l == listener);
  }

  void objectDidChange() {
    if (_listeners == null) return;
    for (var listener in _listeners) {
      listener();
    }
  }
}

abstract class KeyModel extends Model {
  KeyModel(this.key);

  final num key;
}

class Todo extends KeyModel {
  Todo(num key, this._title, this._completed) : super(key);

  String _title;
  String get title => _title;
  set title(String newTitle) {
    if (newTitle != _title) {
      _title = newTitle;
      objectDidChange();
    }
  }

  bool _completed;
  bool get completed => _completed;
  set completed(bool newCompleted) {
    if (newCompleted != _completed) {
      _completed = newCompleted;
      objectDidChange();
    }
  }
}

class TodoFactory {
  int _uid = 0;

  int nextUid() => ++_uid;

  Todo create(String title, bool isCompleted) {
    return new Todo(this.nextUid(), title, isCompleted);
  }
}

class Store<T extends KeyModel> {
  List<T> list = <T>[];

  void add(T record) {
    list.add(record);
  }

  void remove(T record) {
    list.remove(record);
  }

  void removeBy(bool callback(T t)) {
    list.removeWhere(callback);
  }
}

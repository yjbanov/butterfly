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

import 'package:butterfly/butterfly.dart';

Store _store;
TodoFactory _todoFactory;

class TodoApp extends StatefulWidget {
  TodoApp() {
    _store = new Store();
    _todoFactory = new TodoFactory();
    _store.add(_todoFactory.create('Foo', false));
    _store.add(_todoFactory.create('Bar', false));
    _store.add(_todoFactory.create('Baz', false));
  }

  @override
  State createState() => new TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  Todo todoEdit = null;

  TodoAppState();

  Node build() {
    var listItems = _store.list.map((Todo todo) {
      return new Row(children: [
        new Column(classNames: [
          'view',
          '${todoEdit == todo ? 'hidden' : ''}',
        ], children: [
          new Checkbox(
            classNames: const ['toggle'],
            checked: todo.completed ? true : null,
            onClick: (_) {
              completeMe(todo);
            },
          ),
          new DoubleClickArena(
            onDoubleClick: (_) {
              editTodo(todo);
            },
            child: new Text(todo.title),
          ),
          new Button(
            classNames: const ['destroy'],
            onClick: (_) {
              deleteMe(todo);
            },
          ),
        ]),
        new Container(
          child: new Element(
            'input',
            classNames: ['edit', '${todoEdit == todo ? 'visible': ''}'],
            attributes: {
              'type': 'text',
              'value': todo.title,
            },
            eventListeners: {
              EventType.keyup: (Event event) {
                doneEditing(event, todo);
              }
            },
          ),
        )
      ]);
    }).toList();

    return new Container(
      decoration: const BoxDecoration(
        color: const Color.rgba(0xf, 0xf, 0xf, 1.0),
      ),
      margin: new EdgeInsets(
        top: 130.0,
        right: 0.0,
        bottom: 40.0,
        left: 0.0,
      ),
      child: new Column(
        children: [
          new Column(id: 'todoapp', children: [
            new Column(id: 'header', children: [
              new Text(
                'todos',
                style: const TextStyle(fontWeight: 16.0),
              ),
              new Element('input', attributes: {
                'id': 'new-todo',
                'placeholder': 'What needs to be done?',
                'autofocus': true,
                'type': 'text',
              }, eventListeners: {
                EventType.keyup: onKeyEnter((Event event) {
                  enterTodo(event['value']);
                })
              }),
            ]),
            new Column(id: 'main', children: [
              new Checkbox(
                id: 'toggle-all',
                onClick: toggleAll,
              ),
              new Text('Mark all as complete'),
              new Column(id: 'todo-list', children: listItems),
              new Column(id: 'footer', children: [
                new Container(id: 'todo-count'),
                new Container(classNames: ['hidden']),
                new Column(id: 'filters', children: [
                  new Anchor(
                      ref: '#/',
                      classNames: ['selected'],
                      child: new Text('All'),),
                  new Anchor(ref: '#/active', child: new Text('Active')),
                  new Anchor(ref: '#/completed', child: new Text('Completed')),
                ]),
                new Button(
                  id: 'clear-completed',
                  onClick: (_) {
                    clearCompleted();
                  },
                  child: new Text('Clear completed'),
                ),
              ]),
              new Column(id: 'info', children: [
                new Text('Double-click to edit a todo'),
                new Text('Created using '),
                new Anchor(
                    ref: 'https://github.com/yjbanov/butterfly',
                    child: const Text('Butterfly')),
              ]),
            ]),
          ])
        ],
      ),
    );
  }

  void enterTodo(String value) {
    setState(() {
      addTodo(value);
    });
  }

  void editTodo(Todo todo) {
    setState(() {
      this.todoEdit = todo;
    });
  }

  void doneEditing(Event event, Todo todo) {
    setState(() {
      int keyCode = event['keyCode'];
      if (keyCode == 13) {
        todo.title = event['value'];
        this.todoEdit = null;
      } else if (keyCode == 27) {
        this.todoEdit = null;
      }
    });
  }

  void addTodo(String newTitle) {
    setState(() {
      _store.add(_todoFactory.create(newTitle, false));
    });
  }

  void completeMe(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
  }

  void deleteMe(Todo todo) {
    setState(() {
      _store.remove(todo);
    });
  }

  void toggleAll(Event event) {
    setState(() {
      var isComplete = event['checked'];
      _store.list.forEach((Todo todo) {
        todo.completed = isComplete;
      });
    });
  }

  void clearCompleted() {
    setState(() {
      _store.removeWhere((Todo todo) => todo.completed);
    });
  }
}

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

  void removeWhere(bool predicate(T t)) {
    list.removeWhere(predicate);
  }
}

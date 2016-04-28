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

import 'dart:html' as html;

import 'package:butterfly/butterfly.dart';
import 'store.dart';

// TODO(yjbanov): maket these injectable
Store store = new Store();
TodoFactory todoFactory = new TodoFactory();

void main() {
  store.add(todoFactory.create('Foo', false));
  store.add(todoFactory.create('Bar', false));
  store.add(todoFactory.create('Baz', false));
  runApp(new TodoApp(), html.document.querySelector('#app-host'));
}

class TodoApp extends StatefulWidget {
  @override
  State createState() => new TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  Todo todoEdit = null;

  TodoAppState();

  Node build() {
    var listItems = store.list.map((Todo todo) {
      return li()([
        div(attrs: { 'class': 'view ${todoEdit == todo ? 'hidden' : ''}' })([
          input(
            'checkbox',
            attrs: const { 'class': 'toggle' },
            props: (Props props) {
              props.checked = todo.completed;
            },
            eventListeners: {
              EventType.click: (_) { completeMe(todo); }
            })(),
          label(eventListeners: {
            EventType.dblclick: (_) { editTodo(todo); }
          })([text(todo.title)]),
          button(
            attrs: const { 'class': 'destroy' },
            eventListeners: {
              EventType.click: (_) { deleteMe(todo); }
            }
          )(),
        ]),
        div()([
          input(
            'text',
            attrs: { 'class': 'edit ${todoEdit == todo ? 'visible': ''}' },
            props: (Props props) {
              props.value = todo.title;
            },
            eventListeners: {
              EventType.keyup: (Event event) { doneEditing(event, todo); }
            }
          )()
        ]),
      ]);
    }).toList();

    return div()([
      section(attrs: const { 'id': 'todoapp' })([
        header(attrs: const { 'id': 'header' })([
          h1()([
            text('todos')
          ]),
          input('text', attrs: const {
            'id': 'new-todo',
            'placeholder': 'What needs to be done?',
            'autofocus': '',
          }, eventListeners: {
            EventType.keyup: onKeyEnter((Event event) {
              enterTodo(event.nativeEvent.target as html.InputElement);
            })
          })(),
        ]),
        section(attrs: const { 'id': 'main' })([
          input('checkbox', attrs: const { 'id': 'toggle-all' }, eventListeners: {
            EventType.click: toggleAll
          })(),
          label(attrs: const { 'for': 'toggle-all' })([
            text('Mark all as complete')
          ]),
          ul(attrs: const { 'id': 'todo-list' })(listItems),
        ]),
        footer(attrs: const { 'id': 'footer' })([
          span(attrs: const { 'id': 'todo-count' })(),
          // Dunno what this does, but it's in the angular2 version
          div(attrs: const { 'class': 'hidden' })(),
          ul(attrs: const { 'id': 'filters' })([
            li()([
              a(attrs: const { 'href': '#/', 'class': 'selected' })([
                text('All')
              ]),
            ]),
            li()([
              a(attrs: const { 'href': '#/active' })([
                text('Active')
              ]),
            ]),
            li()([
              a(attrs: const { 'href': '#/completed' })([
                text('Completed')
              ]),
            ]),
          ]),
          button(
            attrs: const { 'id': 'clear-completed' },
            eventListeners: {
              EventType.click: (_) { clearCompleted(); }
            }
          )([
            text('Clear completed')
          ]),
        ]),
      ]),
      footer(attrs: const { 'id': 'info' })([
        p()([text('Double-click to edit a todo')]),
        p()([
          text('Created using '),
          a(attrs: const { 'href': 'https://github.com/yjbanov/butterfly' })([
            text('Butterfly')
          ]),
        ]),
      ]),
    ]);
  }

  void enterTodo(html.InputElement inputElement) {
    addTodo(inputElement.value);
    inputElement.value = '';
    scheduleUpdate();
  }

  void editTodo(Todo todo) {
    this.todoEdit = todo;
    scheduleUpdate();
  }

  void doneEditing(Event event, Todo todo) {
    html.KeyEvent keyEvent = event.nativeEvent;
    var keyCode = keyEvent.keyCode;
    var target = keyEvent.target;
    if (keyCode == 13) {
      todo.title = target.value;
      this.todoEdit = null;
    } else if (keyCode == 27) {
      this.todoEdit = null;
      target.value = todo.title;
    }
    scheduleUpdate();
  }

  void addTodo(String newTitle) {
    store.add(todoFactory.create(newTitle, false));
    scheduleUpdate();
  }

  void completeMe(Todo todo) {
    todo.completed = !todo.completed;
    scheduleUpdate();
  }

  void deleteMe(Todo todo) {
    store.remove(todo);
    scheduleUpdate();
  }

  void toggleAll(Event event) {
    var isComplete = (event.nativeEvent.target as html.InputElement).checked;
    store.list.forEach((Todo todo) {
      todo.completed = isComplete;
    });
    scheduleUpdate();
  }

  void clearCompleted() {
    store.removeBy((Todo todo) => todo.completed);
    scheduleUpdate();
  }
}

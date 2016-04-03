# Butterfly

A web framework for Dart based on Flutter's widget model. The goal of the
project is conceptual and data model compatibility with Flutter. An explicit
non-goal is "write once, run anywhere".

## What is Butterfly?

- Object-oriented
- Widget-based (i.e. component-based)
- Reactive
- Web framework
- For Dart
- Inspired by Flutter (transitively by ReactJS)

## Why Butterfly?

- **One language**: traditionally web-frameworks make developers work in a
  number of languages that are glued together by toolchains and runtimes.
  The common combination is JavaScript, HTML templates and CSS (or SASS, or
  LESS). This complicates tooling and usually the integration between the
  languages is very weak. Butterfly gives you one modern battle-tested language -
  Dart - that proved to scale from small apps to large enterprise projects, has
  great tools and is a pleasure to write code in every day. Code navigation
  works seamlessly, typos in the code are identified immediately, and you get
  powerful refactoring features, such as renaming variables and methods. In
  addition Dart gives you minification, dead code elimination and performance
  optimizing compiler. Having one powerful language lets you write your code
  using the normal OOP practices and patterns:
  - Encapsulation: private fields, methods and classes
  - Lexical scoping: static and top-level variables, constants and
    functions
  - Control of API surface: make your components private
  - Control of initialization and lifecycle: components can be cached, injected,
    shared, and provided via factories
  - Debugging: breakpoints work everywhere and show correct stack information.
- **Familiar**: if you have prior Flutter/ReactJS experience you will feel right
  at home.
- **Reusable**: while not API compatible with Flutter (on purpose), the
  component system is identical, which means you can reuse most of your app's
  business logic, data model and utilities across mobile and web. More
  importantly, you will be using the same Dart tools both for your mobile and
  web projects. You cannot reuse the widgets though, as they are targeting
  different rendering systems (Flutter Engine vs HTML DOM).
- **Simple**: Butterfly introduces only a handful of concepts popularized by
  ReactJS and it works like a plain library that you can drop into an existing
  project; it shares all the same Dart libraries so the incremental cost of
  adding it to your project is minimal.
- **Small**: starting application size is <40kb (minified + gzipped)
- **Fast**: while it's hard to compare frameworks in terms of raw speed, this
  framework does aim to give you great levels of control for efficient
  incremental UI updates. Butterfly minimizes the number of DOM nodes. Butterfly
  widgets are virtual. Most other frameworks create a DOM element for each
  component.
- **Layered**: made of layers (widgets, tree, DOM) - you choose how low-level to
  go.
- **Hackable**: defining new widgets is at the core of the development
  experience. However, you can also extend the virtual tree model when you need
  to perform advanced rendering tricks directly on top of the DOM API.

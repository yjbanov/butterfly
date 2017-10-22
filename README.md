# Butterfly

**WARNING: This is highly experimental**

**DISCLAIMER: This is a personal project. This is not an official Google product.**

## What is Butterfly?

A web framework _heavily_ inspired by Flutter.

The goal of the project is conceptual and language compatibility with
Flutter. An explicit non-goal is "write once, run anywhere". Butterfly
_intentionally_ shares no code with Flutter. However, because of the same
language and framework architecture, many of the skills, tools, libraries
and platform-independent code can be shared with Flutter apps.

## What's included?

- A widget system almost identical to that of Flutter
- Flutter-like development mode:
  - Debug code inside your IDE
  - Hot-reload!

## Who is Butterfly for?

- For app developers who build mobile apps using Flutter, and who also need
  to build web apps. Butterfly gives you a single conceptual model for writing
  your apps for both web and mobile, and allows the reuse of big chunks of code.
- For Flutter developers who need to run parts of their app within a WebView.
- For Dart developers who prefer functional-reactive programming style.

## Plays nice with

- [Flutter](http://flutter.io) - source of inspiration
- [Greencat](https://github.com/alexeieleusis/greencat) - Redux for Dart
- [RxDart](https://github.com/ReactiveX/rxdart) - reactive extensions for Dart
- TODO: [Custom elements](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Custom_Elements) -
  Butterfly does not include `dart:html`. If you need to drop down below the
  framework and access the DOM API directly, consider using custom elements.

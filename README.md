Flutter ported to HTML DOM, which makes it a:

- Object-oriented
- Widget-based (i.e. component-based)
- Reactive
- Web framework
- For Dart
- Inspired by Flutter (transitively by ReactJS)

Some reasons why you might like it:

- **One language**: traditionally web-frameworks make developers work in a
  number of languages that are glued together by toolchains and runtimes.
  The common combination is JavaScript, HTML templates and CSS (or SASS, or
  LESS). Not only does it complicate tooling, but it also creates friction in
  development. There is no common set of guidelines between the languages as
  they are developed independently of each other. Code completion and code
  analysis tends to be brittle and is usually only available in big IDEs. The
  languages are in a perpetual state of incompatibility with each other. For
  example, you may have to leak implementation details by exposing private fields
  to bind them to your template code, or deal with variables scoping issues.
  Your component objects tend to be in inconsistent state throughout the
  lifecycle because of how the template system initializes and binds the data.
  Custom extensions, such as JSX/TSX, solve some of the problems, but they still
  remain half-developed and generally you still end up in a multi-lingual
  situation, combining JSX with plain JS. Flutter offers you one modern language
  (Dart) that scales from small apps to large enterprise projects, has great
  tools and is a pleasure to write code in every day. Code navigation
  works seamlessly, typos in the code are identified immediately, and you get
  powerful refactoring features, such as renaming variables and methods. In
  addition Dart gives you minification, dead code elimination and performance
  optimizing compiler.
- **Familiar**: if you have prior Flutter/ReactJS experience you will feel right
  at home.
- **Reusable**: while not API compatible with Flutter (on purpose), the
  component system is identical, which means you can reuse most of your app's
  business logic, data model and utilities across mobile and web. More
  importantly, you will be using the same Dart tools both for your mobile and
  web projects.
- **Simple**: Flutter introduces only a handful of concepts popularized by
  ReactJS and it works like a plain library that you can drop into an existing
  project.
- **Small**: starting application size is <40kb (minified + gzipped)
- **Fast**: while it's hard to compare frameworks in terms of raw speed, this
  framework does aim to give you great levels of control for efficient
  incremental UI updates.
- **Composable**: works like a library - drop it into an existing app; it shares
  all the same Dart libraries so the incremental cost of adding it to your
  project is minimal.
- **Layered**: made of layers (widgets, tree, DOM) - you choose how low-level to
  go.
- **Hackable**: defining new widgets is at the core of the development
  experience. However, you can also extend the virtual tree model when you need
  to perform advanced rendering tricks directly on top of the DOM API.

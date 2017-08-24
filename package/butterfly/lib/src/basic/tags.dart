part of butterfly;

/// Content sectioning.

/// An address tag `<address>`.
///
/// [MDN <address>](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/address)
class Address extends Element {
  const Address({
    Map<String, String> attributes,
    List<Node> children,
    Map<EventType, EventListener> eventListeners,
    List<String> classNames,
    Style style,
    List<Style> styles,
  })
      : super(
          'address',
          attributes: attributes,
          children: children,
          eventListeners: eventListeners,
          classNames: classNames,
          style: style,
          styles: styles,
        );
}

/// An article tag `<article>`.
class Article extends Element {
  const Article({
    Map<String, String> attributes,
    List<Node> children,
    Map<EventType, EventListener> eventListeners,
    List<String> classNames,
    Style style,
    List<Style> styles,
  })
      : super(
          'article',
          attributes: attributes,
          children: children,
          eventListeners: eventListeners,
          classNames: classNames,
          style: style,
          styles: styles,
        );
}

/// An aside tag `<aside>`.
class Aside extends Element {
  const Aside() : super('aside');
}

/// A footer tag `<footer>`.
class Footer extends Element {
  const Footer() : super('aside');
}

/// A heading tag `<h1>`.
class Heading extends Element {
  const Heading([int level = 1]) : super('h$level');
}

/// A header tag `<header>`.
class Header extends Element {
  const Header() : super('header');
}

/// A navigation tag `<nav>`.
class Nav extends Element {
  const Nav() : super('nav');
}

/// A section tag `<section>`.
class Section extends Element {
  const Section() : super('section');
}

/// Text content

/// A blockquote element `<blockquote>`.
class Blockquote extends Element {
  const Blockquote() : super('blockquote');
}

/// A description term `<dd>`.
class DescriptionValue extends Element {
  const DescriptionValue() : super('dd');
}

//// A div tag `<div>`.
class Div extends Element {
  Div() : super('div');
}

/// A description list tag `<dl>`.
class DescriptionList extends Element {
  const DescriptionList() : super('dl');
}

/// A description term tag `<dt>`.
class DescriptionTerm extends Element {
  const DescriptionTerm() : super('dt');
}

/// A figure caption tag `<figcaption>`.
class FigureCaption extends Element {
  const FigureCaption() : super('figcaption');
}

/// A figure tag `<figure>`.
class Figure extends Element {
  const Figure() : super('figure');
}

/// A horizontal rule tag `<hr>`.
class HorizontalRule extends Element {
  const HorizontalRule() : super('hr');
}

/// A list item tag `<li>`.
class ListItem extends Element {
  const ListItem() : super('li');
}

/// A main tag `<main`.
class Main extends Element {
  const Main() : super('main');
}

/// An ordered list tag `<ol>`.
class OrderedList extends Element {
  const OrderedList() : super('ol');
}

/// A paragraph tag `<p>`.
class Paragraph extends Element {
  const Paragraph() : super('p');
}

/// A preformatted text tag `<pre>`.
class Preformatted extends Element {
  const Preformatted() : super('pre');
}

/// An unordered list tag `<ul`>.
class UnorderedList extends Element {
  const UnorderedList() : super('ol');
}

/// Inline text

/// Image and multimedia.

/// An anchor tag `<a>`.
class Anchor extends Element {
  Anchor() : super('a');
}

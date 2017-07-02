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

/// A base class for all HTML input types.
///
/// This does not include form specific inputs, because the native form tag is
/// not used in butterfly.
abstract class Input extends StatelessWidget {
  final bool autoFocus;
  final bool disabled;
  final int maxLength;
  final String name;
  final String id;
  final String placeholder;
  final List<String> classNames;
  final Key key;
  final String type;
  final EventListener onClick;
  final EventListener onChange;
  final Widget child;
  final bool checked;

  const Input({
    @required this.type,
    this.autoFocus,
    this.disabled,
    this.maxLength,
    this.name,
    this.key,
    this.onClick,
    this.onChange,
    this.child,
    this.id,
    this.classNames,
    this.placeholder,
    this.checked,
  });

  @override
  Node build() {
    /// Bind attributes.
    var attributes = <String, String>{};
    attributes['type'] = type;
    if (autoFocus != null) {
      attributes['autofocus'] = autoFocus ? 'true' : 'false';
    }
    if (disabled != null) {
      attributes['disabled'] = disabled ? 'true' : 'false';
    }
    if (maxLength != null) {
      attributes['maxlength'] = maxLength.toString();
    }
    if (name != null) {
      attributes['name'] = name;
    }
    if (id != null) {
      attributes['id'] = id;
    }
    if (placeholder != null) {
      attributes['placeholder'] = placeholder;
    }
    if (checked != null) {
      attributes['checked'] = checked.toString();
    }

    /// Bind event types.
    var eventListeners = <EventType, EventListener>{};
    if (onClick != null) {
      eventListeners[EventType.click] = onClick;
    }
    if (onChange != null) {
      eventListeners[EventType.change] = onChange;
    }
    return new Element(
      'input',
      classNames: classNames ?? const [],
      attributes: attributes,
      eventListeners: eventListeners,
      children: child == null ? const [] : [child],
    );
  }
}

/// A button.
class Button extends Input {
  const Button({
    Key key,
    String name,
    bool autoFocus,
    bool disabled,
    EventListener onClick,
    Widget child,
    String id,
    List<String> classNames,
  })
      : super(
          key: key,
          type: 'button',
          onClick: onClick,
          disabled: disabled,
          autoFocus: autoFocus,
          name: name,
          child: child,
          id: id,
          classNames: classNames,
        );
}

/// A text input
class TextInput extends Input {
  const TextInput({
    Key key,
    String name,
    bool autoFocus,
    bool disabled,
    EventListener onChange,
    String id,
    List<String> classNames,
    String placeholder,
  })
      : super(
          key: key,
          type: 'text',
          onChange: onChange,
          disabled: disabled,
          autoFocus: autoFocus,
          name: name,
          id: id,
          classNames: classNames,
          placeholder: placeholder,
        );
}

/// A checkbox.
class Checkbox extends Input {
  const Checkbox({
    Key key,
    String name,
    bool autoFocus,
    bool disabled,
    bool checked,
    EventListener onClick,
    String id,
    List<String> classNames,
  })
      : super(
          key: key,
          type: 'checkbox',
          disabled: disabled,
          autoFocus: autoFocus,
          name: name,
          id: id,
          classNames: classNames,
          checked: checked,
        );
}

// abstract class ColorInput extends Input {}

// abstract class DateInput extends Input {}

// abstract class DateTimeInput extends Input {}

// abstract class EmailInput extends Input {}

// abstract class FileInput extends Input {}

// abstract class ImageInput extends Input {}

// abstract class MonthInput extends Input {}

// abstract class NumberInput extends Input {}

// abstract class PasswordInput extends Input {}

// abstract class RadioInput extends Input {}

// abstract class RangeInput extends Input {}

// abstract class TelephoneInput extends Input {}

// abstract class TimeInput extends Input {}

// abstract class UrlInput extends Input {}

// abstract class WeekInput extends Input {}

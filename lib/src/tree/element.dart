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

part of flutter_ftw.tree;

class ElementNode extends MultiChildNode<VirtualElement> {
  ElementNode(VirtualElement configuration)
    : _nativeElement = new html.Element.tag(configuration.tag),
      super(configuration);

  final html.Element _nativeElement;

  @override
  void detach() {
    _nativeElement.remove();
    super.detach();
  }

  @override
  void update(VirtualElement newConfiguration) {
    _updateAttributes(newConfiguration);
    super.update(newConfiguration);
  }

  void _updateAttributes(VirtualElement newConfiguration) {
    Attributes oldAttrs = configuration.attributes;
    Attributes newAttrs = newConfiguration.attributes;

    if (identical(oldAttrs, newAttrs)) {
      return;
    }

    for (String attributeName in newAttrs) {
      String oldValue = oldAttrs[attributeName];
      String newValue = newAttrs[attributeName];
      assert(!(oldValue == null && newValue == null));
      if (oldValue == null && newValue != null) {
        _nativeElement.setAttribute(attributeName, newValue);
      } else if (oldValue != null && newValue == null) {
        // TODO(yjbanov): is there a more efficient way to do this?
        _nativeElement.attributes.remove(attributeName);
      } else if (!looseIdentical(oldValue, newValue)) {
        _nativeElement.setAttribute(attributeName, newValue);
      }
    }
  }
}

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

import 'framework.dart';

Attributes attrs(Map<String, String> data) => new Attributes(data);

VirtualElement div([dynamic attributesOrChildren1, dynamic attributesOrChildren2]) {
  assert(_validateAttributesOrChildren(attributesOrChildren1));
  assert(_validateAttributesOrChildren(attributesOrChildren2));

  Map<String, String> attributeMap;
  List<VirtualNode> children;

  if (attributesOrChildren1 is Map) {
    attributeMap = attributesOrChildren1;
  } else if (attributesOrChildren1 is List) {
    children = attributesOrChildren1;
  }

  if (attributesOrChildren2 is Map) {
    attributeMap = attributesOrChildren2;
  } else if (attributesOrChildren2 is List) {
    children = attributesOrChildren2;
  }

  Attributes attributes = new Attributes(attributeMap);
  return new VirtualElement('div', attributes: attributes, children: children);
}

Text text(String value) => new Text(value);

bool _validateAttributesOrChildren(dynamic attributesOrChildren) {
  assert(
    attributesOrChildren == null ||
    attributesOrChildren is Map ||
    attributesOrChildren is List
  );
  return true;
}

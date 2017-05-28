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

const displayFlex = const {
  'display': const [
    '-webkit-flex',
    'flex', // Spec
  ],
};

const displayInlineFlex = const {
  'display': const [
    '-webkit-inline-flex',
    'inline-flex', // Spec
  ],
};

Map flexDirection(String direction) => {
      '-webkit-flex-direction': direction,
      'flex-direction': direction,
    };

Map alignItems(String direction) => {
      '-webkit-align-items': direction,
      'align-items': direction,
    };

Map alignSelf(String direction) => {
      '-webkit-align-self': direction,
      'align-self': direction,
    };

Map alignContent(String direction) => {
      '-webkit-align-content': direction,
      'align-content': direction,
    };

Map justifyContent(String direction) => {
      '-webkit-justify-content': direction,
      'justify-content': direction,
    };

Map flexWrap(String wrap) => {
      '-webkit-flex-wrap': wrap,
      'flex-wrap': wrap,
    };

Map flexBasis(String amount) => {
      '-webkit-flex-basis': amount,
      'flex-basis': amount,
    };

Map flexGrow(String amount) => {
      '-webkit-flex-grow': amount,
      'flex-grow': amount,
    };

Map flexShrink(String amount) => {
      '-webkit-flex-shrink': amount,
      'flex-shrink': amount,
    };

Map flex(String values) => {
      '-webkit-flex': values,
      'flex': values,
    };

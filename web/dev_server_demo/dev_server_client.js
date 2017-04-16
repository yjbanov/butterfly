// Copyright 2017 Google Inc. All Rights Reserved.
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

// TODO(yjbanov): this should be moved served by the dev server and not included in the application code.

/// WARNING: this is indended to be used for development only.
///
/// Synchronously (i.e. blocks the UI thread) sends [data] to [path]
/// and returns the response.
function developmentOnlySyncSend(path, data) {
  var xhr = new XMLHttpRequest();
  xhr.open('POST', path, false);
  //                     ^
  //                     |
  //                     synchronous
  xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
  xhr.send(data);
  return xhr.responseText;
}

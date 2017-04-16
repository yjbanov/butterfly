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

class Butterfly {
    constructor() {}

    /// Synchronously (i.e. blocks the UI thread) invokes a platform channel [method] and returns the result.
    ///
    /// [args] are encoded as JSON. The result is decoded as JSON.
    invokePlatformChannelMethod(method, args) {
      var xhr = new XMLHttpRequest();
      xhr.open('POST', `/__butterfly_dev_channel__/${method}`, false /* synchronous */);
      xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
      xhr.send(JSON.stringify(args));
      return JSON.parse(xhr.responseText);
    }

}

butterfly = new Butterfly();

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

import * as sync from './sync.js';

export class ButterflyModule extends sync.ButterflyModuleBase {
    constructor(moduleName, hostElement) {
      super();
      this.moduleName = moduleName;
      this.hostElement = hostElement;
    }

    run() {
        let eventTypes = ["click", "keyup"];
        eventTypes.forEach((type) => {
            this.hostElement.addEventListener(type, (event) => {
                this.handleEvent(type, event);
            });
        });
        this.invokePlatformChannelMethod('initialize', '');
        this.renderFrame();
    }

    /// Synchronously (i.e. blocks the UI thread) invokes a platform channel [method] and returns the result.
    ///
    /// [args] are encoded as JSON. The result is decoded as JSON.
    invokePlatformChannelMethod(method, args) {
      let xhr = new XMLHttpRequest();
      xhr.open('POST', `/_butterfly/${this.moduleName}/${method}`, false /* synchronous */);
      xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
      xhr.send(JSON.stringify(args));
      console.log(xhr.responseText);
      let result = JSON.parse(xhr.responseText);
      if (result != null && result.hasOwnProperty('error')) {
        throw result['error'];
      }
      return result;
    }
}

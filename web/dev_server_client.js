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

function printStats() {
    console.log(document.querySelectorAll('*').length, 'elements');
}

class ButterflyModule {
    constructor(moduleName, hostElement) {
      this.moduleName = moduleName;
      this.hostElement = hostElement;
    }

    run() {
        let eventTypes = ["click", "keyup"];
        eventTypes.forEach((type) => {
            this.hostElement.addEventListener(type, (event) => {
                this._handleEvent(type, event);
            });
        });
        this._initialize();
        this._renderFrame();
    }

    /// Synchronously (i.e. blocks the UI thread) invokes a platform channel [method] and returns the result.
    ///
    /// [args] are encoded as JSON. The result is decoded as JSON.
    _invokePlatformChannelMethod(method, args) {
      var xhr = new XMLHttpRequest();
      xhr.open('POST', `/__butterfly_dev_channel__/${this.moduleName}/${method}`, false /* synchronous */);
      xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
      xhr.send(JSON.stringify(args));
      return JSON.parse(xhr.responseText);
    }

    _initialize() {
        let diff = this._invokePlatformChannelMethod('initialize', '');
    }

    _renderFrame() {
        let diff = this._invokePlatformChannelMethod('render-frame', '');
        if (!diff) {
            return;
        }
        let jsonParseEnd = performance.now();

        if (diff.hasOwnProperty("create")) {
            let createStart = performance.now();
            this.hostElement.innerHTML = diff["create"];
            let createEnd = performance.now();
            printPerf('create', createStart, createEnd);
        } else if (diff.hasOwnProperty("update")) {
            let updateStart = performance.now();
            this._applyElementUpdate(this.hostElement.firstElementChild, diff["update"]);
            let updateEnd = performance.now();
            printPerf('update', updateStart, updateEnd);
        }
        console.timeStamp('End apply diff');
    }

    _handleEvent(type, event) {
        // Look for the nearest parent with a _bid, then dispatch to it.
        let bid = null;
        let parent = event.target;
        while(bid == null && parent && parent != document) {
            bid = parent.getAttribute("_bid");
            parent = parent.parentNode;
        }
        if (bid) {
            dispatchEvent(type, bid, serializeEvent(type, event));
            this._renderFrame();
        } else {
            console.log(">>> caught event on target with no _bid:", event.target);
        }
    }

    _applyElementUpdate(element, update) {
        if (update.hasOwnProperty("update-elements")) {
            let childUpdates = update["update-elements"];
            for (let i = 0; i < childUpdates.length; i++) {
                let childUpdate = childUpdates[i];
                let index = childUpdate["index"];
                let child = element.childNodes.item(index);
                if (child == null) {
                    console.log('Element child', index, 'not found in:');
                    console.log(element);
                    let parent = element.parentNode;
                    while(parent.id != 'host') {
                        console.log(parent);
                        parent = parent.parentNode;
                    }
                }
                _applyElementUpdate(child, childUpdate);
            }
        }
        let removes = null;
        if (update.hasOwnProperty("remove")) {
            removes = [];
            let removeIndices = update["remove"];
            for (let i = 0; i < removeIndices.length; i++) {
                removes.push(element.childNodes.item(removeIndices[i]));
            }
        }
        let moves = null;
        if (update.hasOwnProperty("move")) {
            moves = [];
            let moveIndices = update["move"];
            for (let i = 0; i < moveIndices.length; i++) {
                moves.push(element.childNodes.item(moveIndices[i]));
            }
        }
        let insertions = null;
        let insertionPoints = null;
        if (update.hasOwnProperty("insert")) {
            insertions = [];
            insertionPoints = [];
            let descriptors = update["insert"];
            for (let i = 0; i < descriptors.length; i++) {
                let html = descriptors[i]["html"];
                let insertionIndex = descriptors[i]["index"];
                insertions.push(html);
                insertionPoints.push(element.childNodes.item(insertionIndex));
            }
        }

        if (update.hasOwnProperty("classes")) {
            // TODO(yjbanov): properly diff the class list.
            let classes = update['classes'];
            if (classes.length > 0) {
                element.className = "";
                for (let i = 0; i < classes.length; i++) {
                    let className = classes[i];
                    if (className != '__clear__') {
                        element.classList.add(className);
                    }
                }
            }
        }

        if (removes != null) {
            for (let i = 0; i < removes.length; i++) {
                removes[i].remove();
            }
        }

        if (moves != null) {
            for (let i = 0; i < moves.length; i += 2) {
                element.insertBefore(moves[i + 1], moves[i]);
            }
        }

        if (insertions != null) {
            for (let i = 0; i < insertions.length; i++) {
                let template = document.createElement("template");
                template.innerHTML = insertions[i];
                element.insertBefore(template.content.firstChild, insertionPoints[i]);
            }
        }

        if (update.hasOwnProperty("bid")) {
            element.setAttribute("_bid", update["bid"]);
        }

        if (update.hasOwnProperty("text")) {
            element.innerText = update["text"];
        }

        if (update.hasOwnProperty("attrs")) {
            let attrs = update["attrs"];
            for (let name in attrs) {
                if (attrs.hasOwnProperty(name)) {
                    if (name == "value") {
                        element.value = attrs[name];
                    }
                    element.setAttribute(name, attrs[name]);
                }
            }
        }
    }
}

butterfly = {
    createModule: function(name, hostElement) {
      return new ButterflyModule(name, hostElement);
    }
};

function printPerf(category, start, end) {
    console.log('>>>', category, ':', end - start, 'ms');
}

function serializeEvent(type, event) {
    let data = {};
    if (type == 'keyup') {
        data['keyCode'] = event.keyCode;
    }
    if (event.target && event.target.value) {
        data['value'] = event.target.value;
    }
    return JSON.stringify(data);
}

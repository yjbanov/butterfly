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

function testLatency() {
    let recvByteCount = 0;
    let benchStart = performance.now();
    let iterations = 100;
    for (let i = 0; i < iterations; i++) {
        let response = butterfly.invokePlatformChannelMethod('latency-benchmark', 'please measure latency');
        recvByteCount += response.length;
    }
    let benchEnd = performance.now();
    let time = benchEnd - benchStart;

    console.log(`-----------------------------------------------------`);
    console.log(`>>> Iterations: ${iterations}`);
    console.log(`>>> Total time: ${time} ms`);
    console.log(`>>> Average latency: ${time / iterations} ms`);
    console.log(`>>> Data received: ${recvByteCount} bytes`);
}

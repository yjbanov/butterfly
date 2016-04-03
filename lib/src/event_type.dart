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

part of flutter_ftw.framework;

/*
To regenerate this list:

1. go to https://developer.mozilla.org/en-US/docs/Web/Events

2. run the following JS in the dev console:

var s = '';
for (var i = 0; i < eventNames.length; i++) {
  var name = eventNames[i].innerHTML;
  if (name == name.toLowerCase()) {s += name; s += '\n';}
}
console.log(s);

3. Save the output to event_type.txt

4. Get event numbers by running `cat -n event_type.txt`

5. Then substitute s/\s*(\d+)\s+(\w+)\n/  static const $2 = const EventType($1, '$2');\n/g
*/

class EventType {
  static const abort = const EventType(1, 'abort');
  static const afterprint = const EventType(2, 'afterprint');
  static const animationend = const EventType(3, 'animationend');
  static const animationiteration = const EventType(4, 'animationiteration');
  static const animationstart = const EventType(5, 'animationstart');
  static const audioprocess = const EventType(6, 'audioprocess');
  static const audioend = const EventType(7, 'audioend');
  static const audiostart = const EventType(8, 'audiostart');
  static const beforeprint = const EventType(9, 'beforeprint');
  static const beforeunload = const EventType(10, 'beforeunload');
  static const blocked = const EventType(11, 'blocked');
  static const blur = const EventType(12, 'blur');
  static const boundary = const EventType(13, 'boundary');
  static const cached = const EventType(14, 'cached');
  static const canplay = const EventType(15, 'canplay');
  static const canplaythrough = const EventType(16, 'canplaythrough');
  static const change = const EventType(17, 'change');
  static const chargingchange = const EventType(18, 'chargingchange');
  static const chargingtimechange = const EventType(19, 'chargingtimechange');
  static const checking = const EventType(20, 'checking');
  static const click = const EventType(21, 'click');
  static const close = const EventType(22, 'close');
  static const complete = const EventType(23, 'complete');
  static const compositionend = const EventType(24, 'compositionend');
  static const compositionstart = const EventType(25, 'compositionstart');
  static const compositionupdate = const EventType(26, 'compositionupdate');
  static const contextmenu = const EventType(27, 'contextmenu');
  static const copy = const EventType(28, 'copy');
  static const cut = const EventType(29, 'cut');
  static const dblclick = const EventType(30, 'dblclick');
  static const devicelight = const EventType(31, 'devicelight');
  static const devicemotion = const EventType(32, 'devicemotion');
  static const deviceorientation = const EventType(33, 'deviceorientation');
  static const deviceproximity = const EventType(34, 'deviceproximity');
  static const dischargingtimechange = const EventType(35, 'dischargingtimechange');
  static const focus = const EventType(36, 'focus');
  static const focusin = const EventType(37, 'focusin');
  static const focusout = const EventType(38, 'focusout');
  static const downloading = const EventType(39, 'downloading');
  static const drag = const EventType(40, 'drag');
  static const dragend = const EventType(41, 'dragend');
  static const dragenter = const EventType(42, 'dragenter');
  static const dragleave = const EventType(43, 'dragleave');
  static const dragover = const EventType(44, 'dragover');
  static const dragstart = const EventType(45, 'dragstart');
  static const drop = const EventType(46, 'drop');
  static const durationchange = const EventType(47, 'durationchange');
  static const emptied = const EventType(48, 'emptied');
  static const end = const EventType(49, 'end');
  static const ended = const EventType(50, 'ended');
  static const error = const EventType(51, 'error');
  static const fullscreenchange = const EventType(52, 'fullscreenchange');
  static const fullscreenerror = const EventType(53, 'fullscreenerror');
  static const gamepadconnected = const EventType(54, 'gamepadconnected');
  static const gamepaddisconnected = const EventType(55, 'gamepaddisconnected');
  static const gotpointercapture = const EventType(56, 'gotpointercapture');
  static const hashchange = const EventType(57, 'hashchange');
  static const lostpointercapture = const EventType(58, 'lostpointercapture');
  static const input = const EventType(59, 'input');
  static const invalid = const EventType(60, 'invalid');
  static const keydown = const EventType(61, 'keydown');
  static const keypress = const EventType(62, 'keypress');
  static const keyup = const EventType(63, 'keyup');
  static const languagechange = const EventType(64, 'languagechange');
  static const levelchange = const EventType(65, 'levelchange');
  static const load = const EventType(66, 'load');
  static const loadeddata = const EventType(67, 'loadeddata');
  static const loadedmetadata = const EventType(68, 'loadedmetadata');
  static const loadend = const EventType(69, 'loadend');
  static const loadstart = const EventType(70, 'loadstart');
  static const mark = const EventType(71, 'mark');
  static const message = const EventType(72, 'message');
  static const mousedown = const EventType(74, 'mousedown');
  static const mouseenter = const EventType(75, 'mouseenter');
  static const mouseleave = const EventType(76, 'mouseleave');
  static const mousemove = const EventType(77, 'mousemove');
  static const mouseout = const EventType(78, 'mouseout');
  static const mouseover = const EventType(79, 'mouseover');
  static const mouseup = const EventType(80, 'mouseup');
  static const nomatch = const EventType(81, 'nomatch');
  static const notificationclick = const EventType(82, 'notificationclick');
  static const noupdate = const EventType(83, 'noupdate');
  static const obsolete = const EventType(84, 'obsolete');
  static const offline = const EventType(85, 'offline');
  static const online = const EventType(86, 'online');
  static const open = const EventType(87, 'open');
  static const orientationchange = const EventType(88, 'orientationchange');
  static const pagehide = const EventType(89, 'pagehide');
  static const pageshow = const EventType(90, 'pageshow');
  static const paste = const EventType(91, 'paste');
  static const pause = const EventType(92, 'pause');
  static const pointercancel = const EventType(93, 'pointercancel');
  static const pointerdown = const EventType(94, 'pointerdown');
  static const pointerenter = const EventType(95, 'pointerenter');
  static const pointerleave = const EventType(96, 'pointerleave');
  static const pointerlockchange = const EventType(97, 'pointerlockchange');
  static const pointerlockerror = const EventType(98, 'pointerlockerror');
  static const pointermove = const EventType(99, 'pointermove');
  static const pointerout = const EventType(100, 'pointerout');
  static const pointerover = const EventType(101, 'pointerover');
  static const pointerup = const EventType(102, 'pointerup');
  static const play = const EventType(103, 'play');
  static const playing = const EventType(104, 'playing');
  static const popstate = const EventType(105, 'popstate');
  static const progress = const EventType(106, 'progress');
  static const push = const EventType(107, 'push');
  static const pushsubscriptionchange = const EventType(108, 'pushsubscriptionchange');
  static const ratechange = const EventType(109, 'ratechange');
  static const readystatechange = const EventType(110, 'readystatechange');
  static const reset = const EventType(111, 'reset');
  static const resize = const EventType(112, 'resize');
  static const resourcetimingbufferfull = const EventType(113, 'resourcetimingbufferfull');
  static const result = const EventType(114, 'result');
  static const resume = const EventType(115, 'resume');
  static const scroll = const EventType(116, 'scroll');
  static const seeked = const EventType(117, 'seeked');
  static const seeking = const EventType(118, 'seeking');
  static const select = const EventType(119, 'select');
  static const selectstart = const EventType(120, 'selectstart');
  static const selectionchange = const EventType(121, 'selectionchange');
  static const show = const EventType(122, 'show');
  static const soundend = const EventType(123, 'soundend');
  static const soundstart = const EventType(124, 'soundstart');
  static const speechend = const EventType(125, 'speechend');
  static const speechstart = const EventType(126, 'speechstart');
  static const stalled = const EventType(127, 'stalled');
  static const start = const EventType(128, 'start');
  static const storage = const EventType(129, 'storage');
  static const submit = const EventType(130, 'submit');
  static const success = const EventType(131, 'success');
  static const suspend = const EventType(132, 'suspend');
  static const timeout = const EventType(133, 'timeout');
  static const timeupdate = const EventType(134, 'timeupdate');
  static const touchcancel = const EventType(135, 'touchcancel');
  static const touchend = const EventType(136, 'touchend');
  static const touchenter = const EventType(137, 'touchenter');
  static const touchleave = const EventType(138, 'touchleave');
  static const touchmove = const EventType(139, 'touchmove');
  static const touchstart = const EventType(140, 'touchstart');
  static const transitionend = const EventType(141, 'transitionend');
  static const unload = const EventType(142, 'unload');
  static const updateready = const EventType(143, 'updateready');
  static const upgradeneeded = const EventType(144, 'upgradeneeded');
  static const userproximity = const EventType(145, 'userproximity');
  static const voiceschanged = const EventType(146, 'voiceschanged');
  static const versionchange = const EventType(147, 'versionchange');
  static const visibilitychange = const EventType(148, 'visibilitychange');
  static const volumechange = const EventType(149, 'volumechange');
  static const waiting = const EventType(150, 'waiting');
  static const wheel = const EventType(151, 'wheel');

  const EventType(this.index, this.typeName);

  final int index;
  final String typeName;
}

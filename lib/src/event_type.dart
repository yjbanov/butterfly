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

part of butterfly;

class EventType {
  // Source of constants: https://developer.mozilla.org/en-US/docs/Web/Events
  static const abort = const EventType('abort');
  static const afterprint = const EventType('afterprint');
  static const animationend = const EventType('animationend');
  static const animationiteration = const EventType('animationiteration');
  static const animationstart = const EventType('animationstart');
  static const audioprocess = const EventType('audioprocess');
  static const audioend = const EventType('audioend');
  static const audiostart = const EventType('audiostart');
  static const beforeprint = const EventType('beforeprint');
  static const beforeunload = const EventType('beforeunload');
  static const blocked = const EventType('blocked');
  static const blur = const EventType('blur');
  static const boundary = const EventType('boundary');
  static const cached = const EventType('cached');
  static const canplay = const EventType('canplay');
  static const canplaythrough = const EventType('canplaythrough');
  static const change = const EventType('change');
  static const chargingchange = const EventType('chargingchange');
  static const chargingtimechange = const EventType('chargingtimechange');
  static const checking = const EventType('checking');
  static const click = const EventType('click');
  static const close = const EventType('close');
  static const complete = const EventType('complete');
  static const compositionend = const EventType('compositionend');
  static const compositionstart = const EventType('compositionstart');
  static const compositionupdate = const EventType('compositionupdate');
  static const contextmenu = const EventType('contextmenu');
  static const copy = const EventType('copy');
  static const cut = const EventType('cut');
  static const dblclick = const EventType('dblclick');
  static const devicelight = const EventType('devicelight');
  static const devicemotion = const EventType('devicemotion');
  static const deviceorientation = const EventType('deviceorientation');
  static const deviceproximity = const EventType('deviceproximity');
  static const dischargingtimechange = const EventType('dischargingtimechange');
  static const focus = const EventType('focus');
  static const focusin = const EventType('focusin');
  static const focusout = const EventType('focusout');
  static const downloading = const EventType('downloading');
  static const drag = const EventType('drag');
  static const dragend = const EventType('dragend');
  static const dragenter = const EventType('dragenter');
  static const dragleave = const EventType('dragleave');
  static const dragover = const EventType('dragover');
  static const dragstart = const EventType('dragstart');
  static const drop = const EventType('drop');
  static const durationchange = const EventType('durationchange');
  static const emptied = const EventType('emptied');
  static const end = const EventType('end');
  static const ended = const EventType('ended');
  static const error = const EventType('error');
  static const fullscreenchange = const EventType('fullscreenchange');
  static const fullscreenerror = const EventType('fullscreenerror');
  static const gamepadconnected = const EventType('gamepadconnected');
  static const gamepaddisconnected = const EventType('gamepaddisconnected');
  static const gotpointercapture = const EventType('gotpointercapture');
  static const hashchange = const EventType('hashchange');
  static const lostpointercapture = const EventType('lostpointercapture');
  static const input = const EventType('input');
  static const invalid = const EventType('invalid');
  static const keydown = const EventType('keydown');
  static const keypress = const EventType('keypress');
  static const keyup = const EventType('keyup');
  static const languagechange = const EventType('languagechange');
  static const levelchange = const EventType('levelchange');
  static const load = const EventType('load');
  static const loadeddata = const EventType('loadeddata');
  static const loadedmetadata = const EventType('loadedmetadata');
  static const loadend = const EventType('loadend');
  static const loadstart = const EventType('loadstart');
  static const mark = const EventType('mark');
  static const message = const EventType('message');
  static const mousedown = const EventType('mousedown');
  static const mouseenter = const EventType('mouseenter');
  static const mouseleave = const EventType('mouseleave');
  static const mousemove = const EventType('mousemove');
  static const mouseout = const EventType('mouseout');
  static const mouseover = const EventType('mouseover');
  static const mouseup = const EventType('mouseup');
  static const nomatch = const EventType('nomatch');
  static const notificationclick = const EventType('notificationclick');
  static const noupdate = const EventType('noupdate');
  static const obsolete = const EventType('obsolete');
  static const offline = const EventType('offline');
  static const online = const EventType('online');
  static const open = const EventType('open');
  static const orientationchange = const EventType('orientationchange');
  static const pagehide = const EventType('pagehide');
  static const pageshow = const EventType('pageshow');
  static const paste = const EventType('paste');
  static const pause = const EventType('pause');
  static const pointercancel = const EventType('pointercancel');
  static const pointerdown = const EventType('pointerdown');
  static const pointerenter = const EventType('pointerenter');
  static const pointerleave = const EventType('pointerleave');
  static const pointerlockchange = const EventType('pointerlockchange');
  static const pointerlockerror = const EventType('pointerlockerror');
  static const pointermove = const EventType('pointermove');
  static const pointerout = const EventType('pointerout');
  static const pointerover = const EventType('pointerover');
  static const pointerup = const EventType('pointerup');
  static const play = const EventType('play');
  static const playing = const EventType('playing');
  static const popstate = const EventType('popstate');
  static const progress = const EventType('progress');
  static const push = const EventType('push');
  static const pushsubscriptionchange = const EventType('pushsubscriptionchange');
  static const ratechange = const EventType('ratechange');
  static const readystatechange = const EventType('readystatechange');
  static const reset = const EventType('reset');
  static const resize = const EventType('resize');
  static const resourcetimingbufferfull = const EventType('resourcetimingbufferfull');
  static const result = const EventType('result');
  static const resume = const EventType('resume');
  static const scroll = const EventType('scroll');
  static const seeked = const EventType('seeked');
  static const seeking = const EventType('seeking');
  static const select = const EventType('select');
  static const selectstart = const EventType('selectstart');
  static const selectionchange = const EventType('selectionchange');
  static const show = const EventType('show');
  static const soundend = const EventType('soundend');
  static const soundstart = const EventType('soundstart');
  static const speechend = const EventType('speechend');
  static const speechstart = const EventType('speechstart');
  static const stalled = const EventType('stalled');
  static const start = const EventType('start');
  static const storage = const EventType('storage');
  static const submit = const EventType('submit');
  static const success = const EventType('success');
  static const suspend = const EventType('suspend');
  static const timeout = const EventType('timeout');
  static const timeupdate = const EventType('timeupdate');
  static const touchcancel = const EventType('touchcancel');
  static const touchend = const EventType('touchend');
  static const touchenter = const EventType('touchenter');
  static const touchleave = const EventType('touchleave');
  static const touchmove = const EventType('touchmove');
  static const touchstart = const EventType('touchstart');
  static const transitionend = const EventType('transitionend');
  static const unload = const EventType('unload');
  static const updateready = const EventType('updateready');
  static const upgradeneeded = const EventType('upgradeneeded');
  static const userproximity = const EventType('userproximity');
  static const voiceschanged = const EventType('voiceschanged');
  static const versionchange = const EventType('versionchange');
  static const visibilitychange = const EventType('visibilitychange');
  static const volumechange = const EventType('volumechange');
  static const waiting = const EventType('waiting');
  static const wheel = const EventType('wheel');

  const EventType(this.name);

  final String name;

  @override
  int get hashCode => name.hashCode;

  @override
  operator==(Object other) => other.runtimeType == EventType &&
      (other as EventType).name == name;

  @override
  String toString() => '$EventType($name)';
}

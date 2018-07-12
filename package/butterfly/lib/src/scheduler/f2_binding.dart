// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart'
    show PriorityQueue, HeapPriorityQueue;

import 'package:meta/meta.dart';

import 'package:butterfly/src/f2.dart';

/// Slows down animations by this factor to help in development.
double get timeDilation => _timeDilation;
double _timeDilation = 1.0;

/// Setting the time dilation automatically calls [SchedulerBinding.resetEpoch]
/// to ensure that time stamps seen by consumers of the scheduler binding are
/// always increasing.
set timeDilation(double value) {
  assert(value > 0.0);
  if (_timeDilation == value) return;
  // We need to resetEpoch first so that we capture start of the epoch with the
  // current time dilation.
  SchedulerBinding.instance?.resetEpoch();
  _timeDilation = value;
}

/// Signature for frame-related callbacks from the scheduler.
///
/// The `timeStamp` is the number of milliseconds since the beginning of the
/// scheduler's epoch. Use timeStamp to determine how far to advance animation
/// timelines so that all the animations in the system are synchronized to a
/// common time base.
typedef void FrameCallback(Duration timeStamp);

/// Signature for [Scheduler.scheduleTask] callbacks.
///
/// The type argument `T` is the task's return value. Consider [void] if the
/// task does not return a value.
typedef T TaskCallback<T>();

/// Signature for the [SchedulerBinding.schedulingStrategy] callback. Called
/// whenever the system needs to decide whether a task at a given
/// priority needs to be run.
///
/// Return true if a task with the given priority should be executed
/// at this time, false otherwise.
///
/// See also [defaultSchedulingStrategy].
typedef bool SchedulingStrategy({int priority, SchedulerBinding scheduler});

class _TaskEntry<T> {
  _TaskEntry(this.task, this.priority, this.debugLabel) {
    // ignore: prefer_asserts_in_initializer_lists
    assert(() {
      debugStack = StackTrace.current;
      return true;
    }());
    completer = new Completer<T>();
  }
  final TaskCallback<T> task;
  final int priority;
  final String debugLabel;

  StackTrace debugStack;
  Completer<T> completer;

  void run() {
    completer.complete(task());
  }
}

class _FrameCallbackEntry {
  _FrameCallbackEntry(this.callback, {bool rescheduling: false}) {
    assert(() {
      if (rescheduling) {
        assert(() {
          if (debugCurrentCallbackStack == null) {
            throw new FlutterError(
                'scheduleFrameCallback called with rescheduling true, but no '
                'callback is in scope.\n'
                'The "rescheduling" argument should only be set to true if the '
                'callback is being reregistered from within the callback '
                'itself, and only then if the callback itself is entirely '
                'synchronous. If this is the initial registration of the '
                'callback, or if the callback is asynchronous, then do not '
                'use the "rescheduling" argument.');
          }
          return true;
        }());
        debugStack = debugCurrentCallbackStack;
      } else {
        // TODO(ianh): trim the frames from this library, so that the call to
        // scheduleFrameCallback is the top one
        debugStack = StackTrace.current;
      }
      return true;
    }());
  }

  final FrameCallback callback;

  static StackTrace debugCurrentCallbackStack;
  StackTrace debugStack;
}

/// The various phases that a [SchedulerBinding] goes through during
/// [SchedulerBinding.handleBeginFrame].
///
/// This is exposed by [SchedulerBinding.schedulerPhase].
///
/// The values of this enum are ordered in the same order as the phases occur,
/// so their relative index values can be compared to each other.
///
/// See also the discussion at [WidgetsBinding.drawFrame].
enum SchedulerPhase {
  /// No frame is being processed. Tasks (scheduled by
  /// [WidgetsBinding.scheduleTask]), microtasks (scheduled by
  /// [scheduleMicrotask]), [Timer] callbacks, event handlers (e.g. from user
  /// input), and other callbacks (e.g. from [Future]s, [Stream]s, and the like)
  /// may be executing.
  idle,

  /// The transient callbacks (scheduled by
  /// [WidgetsBinding.scheduleFrameCallback]) are currently executing.
  ///
  /// Typically, these callbacks handle updating objects to new animation
  /// states.
  ///
  /// See [SchedulerBinding.handleBeginFrame].
  transientCallbacks,

  /// Microtasks scheduled during the processing of transient callbacks are
  /// current executing.
  ///
  /// This may include, for instance, callbacks from futures resulted during the
  /// [transientCallbacks] phase.
  midFrameMicrotasks,

  /// The persistent callbacks (scheduled by
  /// [WidgetsBinding.addPersistentFrameCallback]) are currently executing.
  ///
  /// Typically, this is the build/layout/paint pipeline. See
  /// [WidgetsBinding.drawFrame] and [SchedulerBinding.handleDrawFrame].
  persistentCallbacks,

  /// The post-frame callbacks (scheduled by
  /// [WidgetsBinding.addPostFrameCallback]) are currently executing.
  ///
  /// Typically, these callbacks handle cleanup and scheduling of work for the
  /// next frame.
  ///
  /// See [SchedulerBinding.handleDrawFrame].
  postFrameCallbacks,
}

/// A task priority, as passed to [SchedulerBinding.scheduleTask].
@immutable
class Priority {
  const Priority._(this._value);

  /// The integer that describes this Priority value.
  int get value => _value;
  final int _value;

  /// A task to run after all other tasks, when no animations are running.
  static const Priority idle = const Priority._(0);

  /// A task to run even when animations are running.
  static const Priority animation = const Priority._(100000);

  /// A task to run even when the user is interacting with the device.
  static const Priority touch = const Priority._(200000);

  /// Maximum offset by which to clamp relative priorities.
  ///
  /// It is still possible to have priorities that are offset by more
  /// than this amount by repeatedly taking relative offsets, but that
  /// is generally discouraged.
  static const int kMaxOffset = 10000;

  /// Returns a priority relative to this priority.
  ///
  /// A positive [offset] indicates a higher priority.
  ///
  /// The parameter [offset] is clamped to ±[kMaxOffset].
  Priority operator +(int offset) {
    if (offset.abs() > kMaxOffset) {
      // Clamp the input offset.
      offset = kMaxOffset * offset.sign;
    }
    return new Priority._(_value + offset);
  }

  /// Returns a priority relative to this priority.
  ///
  /// A positive offset indicates a lower priority.
  ///
  /// The parameter [offset] is clamped to ±[kMaxOffset].
  Priority operator -(int offset) => this + (-offset);
}

typedef void FrameSchedulingCallback(FrameCallback frameHandler);

/// Scheduler for running the following:
///
/// * _Transient callbacks_, triggered by the system's [Window.onBeginFrame]
///   callback, for synchronizing the application's behavior to the system's
///   display. For example, [Ticker]s and [AnimationController]s trigger from
///   these.
///
/// * _Persistent callbacks_, triggered by the system's [Window.onDrawFrame]
///   callback, for updating the system's display after transient callbacks have
///   executed. For example, the rendering layer uses this to drive its
///   rendering pipeline.
///
/// * _Post-frame callbacks_, which are run after persistent callbacks, just
///   before returning from the [Window.onDrawFrame] callback.
///
/// * Non-rendering tasks, to be run between frames. These are given a
///   priority and are executed in priority order according to a
///   [schedulingStrategy].
class SchedulerBinding {
  SchedulerBinding._(this._frameSchedulingCallback);

  static void initialize(FrameSchedulingCallback frameSchedulingCallback) {
    _instance = SchedulerBinding._(frameSchedulingCallback);
  }

  final FrameSchedulingCallback _frameSchedulingCallback;

  /// The current [SchedulerBinding], if one has been created.
  static SchedulerBinding get instance => _instance;
  static SchedulerBinding _instance;

  /// The strategy to use when deciding whether to run a task or not.
  ///
  /// Defaults to [defaultSchedulingStrategy].
  SchedulingStrategy schedulingStrategy = defaultSchedulingStrategy;

  static int _taskSorter(_TaskEntry<dynamic> e1, _TaskEntry<dynamic> e2) {
    return -e1.priority.compareTo(e2.priority);
  }

  final PriorityQueue<_TaskEntry<dynamic>> _taskQueue =
      new HeapPriorityQueue<_TaskEntry<dynamic>>(_taskSorter);

  // Whether this scheduler already requested to be called from the event loop.
  bool _hasRequestedAnEventLoopCallback = false;

  // Ensures that the scheduler services a task scheduled by [scheduleTask].
  void _ensureEventLoopCallback() {
    assert(_taskQueue.isNotEmpty);
    if (_hasRequestedAnEventLoopCallback) return;
    _hasRequestedAnEventLoopCallback = true;
    Timer.run(_runTasks);
  }

  // Scheduled by _ensureEventLoopCallback.
  void _runTasks() {
    _hasRequestedAnEventLoopCallback = false;
    if (handleEventLoopCallback())
      _ensureEventLoopCallback(); // runs next task when there's time
  }

  /// Execute the highest-priority task, if it is of a high enough priority.
  ///
  /// Returns true if a task was executed and there are other tasks remaining
  /// (even if they are not high-enough priority).
  ///
  /// Returns false if no task was executed, which can occur if there are no
  /// tasks scheduled, if the scheduler is [locked], or if the highest-priority
  /// task is of too low a priority given the current [schedulingStrategy].
  ///
  /// Also returns false if there are no tasks remaining.
  @visibleForTesting
  bool handleEventLoopCallback() {
    if (_taskQueue.isEmpty) return false;
    final _TaskEntry<dynamic> entry = _taskQueue.first;
    if (schedulingStrategy(priority: entry.priority, scheduler: this)) {
      _taskQueue.removeFirst();
      entry.run();
      return _taskQueue.isNotEmpty;
    }
    return false;
  }

  int _nextFrameCallbackId = 0; // positive
  Map<int, _FrameCallbackEntry> _transientCallbacks =
      <int, _FrameCallbackEntry>{};
  final Set<int> _removedIds = new HashSet<int>();

  /// The current number of transient frame callbacks scheduled.
  ///
  /// This is reset to zero just before all the currently scheduled
  /// transient callbacks are called, at the start of a frame.
  ///
  /// This number is primarily exposed so that tests can verify that
  /// there are no unexpected transient callbacks still registered
  /// after a test's resources have been gracefully disposed.
  int get transientCallbackCount => _transientCallbacks.length;

  /// Schedules the given transient frame callback.
  ///
  /// Adds the given callback to the list of frame callbacks and ensures that a
  /// frame is scheduled.
  ///
  /// If this is a one-off registration, ignore the `rescheduling` argument.
  ///
  /// If this is a callback that will be reregistered each time it fires, then
  /// when you reregister the callback, set the `rescheduling` argument to true.
  /// This has no effect in release builds, but in debug builds, it ensures that
  /// the stack trace that is stored for this callback is the original stack
  /// trace for when the callback was _first_ registered, rather than the stack
  /// trace for when the callback is reregistered. This makes it easier to track
  /// down the original reason that a particular callback was called. If
  /// `rescheduling` is true, the call must be in the context of a frame
  /// callback.
  ///
  /// Callbacks registered with this method can be canceled using
  /// [cancelFrameCallbackWithId].
  int scheduleFrameCallback(FrameCallback callback,
      {bool rescheduling: false}) {
    scheduleFrame();
    _nextFrameCallbackId += 1;
    _transientCallbacks[_nextFrameCallbackId] =
        new _FrameCallbackEntry(callback, rescheduling: rescheduling);
    return _nextFrameCallbackId;
  }

  /// Cancels the transient frame callback with the given [id].
  ///
  /// Removes the given callback from the list of frame callbacks. If a frame
  /// has been requested, this does not also cancel that request.
  ///
  /// Transient frame callbacks are those registered using
  /// [scheduleFrameCallback].
  void cancelFrameCallbackWithId(int id) {
    assert(id > 0);
    _transientCallbacks.remove(id);
    _removedIds.add(id);
  }

  final List<FrameCallback> _persistentCallbacks = <FrameCallback>[];

  /// Adds a persistent frame callback.
  ///
  /// Persistent callbacks are called after transient
  /// (non-persistent) frame callbacks.
  ///
  /// Does *not* request a new frame. Conceptually, persistent frame
  /// callbacks are observers of "begin frame" events. Since they are
  /// executed after the transient frame callbacks they can drive the
  /// rendering pipeline.
  ///
  /// Persistent frame callbacks cannot be unregistered. Once registered, they
  /// are called for every frame for the lifetime of the application.
  void addPersistentFrameCallback(FrameCallback callback) {
    _persistentCallbacks.add(callback);
  }

  final List<FrameCallback> _postFrameCallbacks = <FrameCallback>[];

  /// Schedule a callback for the end of this frame.
  ///
  /// Does *not* request a new frame.
  ///
  /// This callback is run during a frame, just after the persistent
  /// frame callbacks (which is when the main rendering pipeline has
  /// been flushed). If a frame is in progress and post-frame
  /// callbacks haven't been executed yet, then the registered
  /// callback is still executed during the frame. Otherwise, the
  /// registered callback is executed during the next frame.
  ///
  /// The callbacks are executed in the order in which they have been
  /// added.
  ///
  /// Post-frame callbacks cannot be unregistered. They are called exactly once.
  ///
  /// See also:
  ///
  ///  * [scheduleFrameCallback], which registers a callback for the start of
  ///    the next frame.
  void addPostFrameCallback(FrameCallback callback) {
    _postFrameCallbacks.add(callback);
  }

  Completer<Null> _nextFrameCompleter;

  /// Returns a Future that completes after the frame completes.
  ///
  /// If this is called between frames, a frame is immediately scheduled if
  /// necessary. If this is called during a frame, the Future completes after
  /// the current frame.
  ///
  /// If the device's screen is currently turned off, this may wait a very long
  /// time, since frames are not scheduled while the device's screen is turned
  /// off.
  Future<Null> get endOfFrame {
    if (_nextFrameCompleter == null) {
      if (schedulerPhase == SchedulerPhase.idle) scheduleFrame();
      _nextFrameCompleter = new Completer<Null>();
      addPostFrameCallback((Duration timeStamp) {
        _nextFrameCompleter.complete();
        _nextFrameCompleter = null;
      });
    }
    return _nextFrameCompleter.future;
  }

  /// Whether this scheduler has requested that [handleBeginFrame] be called
  /// soon.
  bool get hasScheduledFrame => _hasScheduledFrame;
  bool _hasScheduledFrame = false;

  /// The phase that the scheduler is currently operating under.
  SchedulerPhase get schedulerPhase => _schedulerPhase;
  SchedulerPhase _schedulerPhase = SchedulerPhase.idle;

  /// If necessary, schedules a new frame by calling
  /// [Window.scheduleFrame].
  ///
  /// After this is called, the engine will (eventually) call
  /// [handleBeginFrame]. (This call might be delayed, e.g. if the device's
  /// screen is turned off it will typically be delayed until the screen is on
  /// and the application is visible.) Calling this during a frame forces
  /// another frame to be scheduled, even if the current frame has not yet
  /// completed.
  ///
  /// Scheduled frames are serviced when triggered by a "Vsync" signal provided
  /// by the operating system. The "Vsync" signal, or vertical synchronization
  /// signal, was historically related to the display refresh, at a time when
  /// hardware physically moved a beam of electrons vertically between updates
  /// of the display. The operation of contemporary hardware is somewhat more
  /// subtle and complicated, but the conceptual "Vsync" refresh signal continue
  /// to be used to indicate when applications should update their rendering.
  ///
  /// To have a stack trace printed to the console any time this function
  /// schedules a frame, set [debugPrintScheduleFrameStacks] to true.
  ///
  /// See also:
  ///
  ///  * [scheduleForcedFrame], which ignores the [lifecycleState] when
  ///    scheduling a frame.
  ///  * [scheduleWarmUpFrame], which ignores the "Vsync" signal entirely and
  ///    triggers a frame immediately.
  void scheduleFrame() {
    // TODO(yjbanov): in Flutter this also uses _framesEnabled, which is what
    // makes it different from scheduleForcedFrame().
    if (_hasScheduledFrame) {
      return;
    }
    _frameSchedulingCallback((Duration rawTimestamp) {
      handleBeginFrame(rawTimestamp);
      handleDrawFrame();
    });
    _hasScheduledFrame = true;
  }

  /// Schedules a new frame by calling [Window.scheduleFrame].
  ///
  /// After this is called, the engine will call [handleBeginFrame], even if
  /// frames would normally not be scheduled by [scheduleFrame] (e.g. even if
  /// the device's screen is turned off).
  ///
  /// The framework uses this to force a frame to be rendered at the correct
  /// size when the phone is rotated, so that a correctly-sized rendering is
  /// available when the screen is turned back on.
  ///
  /// To have a stack trace printed to the console any time this function
  /// schedules a frame, set [debugPrintScheduleFrameStacks] to true.
  ///
  /// Prefer using [scheduleFrame] unless it is imperative that a frame be
  /// scheduled immediately, since using [scheduleForceFrame] will cause
  /// significantly higher battery usage when the device should be idle.
  ///
  /// Consider using [scheduleWarmUpFrame] instead if the goal is to update the
  /// rendering as soon as possible (e.g. at application startup).
  void scheduleForcedFrame() {
    if (_hasScheduledFrame) {
      return;
    }
    _frameSchedulingCallback((Duration rawTimestamp) {
      handleBeginFrame(rawTimestamp);
      handleDrawFrame();
    });
    _hasScheduledFrame = true;
  }

  Duration _firstRawTimeStampInEpoch;
  Duration _epochStart = Duration.zero;
  Duration _lastRawTimeStamp = Duration.zero;

  /// Prepares the scheduler for a non-monotonic change to how time stamps are
  /// calculated.
  ///
  /// Callbacks received from the scheduler assume that their time stamps are
  /// monotonically increasing. The raw time stamp passed to [handleBeginFrame]
  /// is monotonic, but the scheduler might adjust those time stamps to provide
  /// [timeDilation]. Without careful handling, these adjusts could cause time
  /// to appear to run backwards.
  ///
  /// The [resetEpoch] function ensures that the time stamps are monotonic by
  /// resetting the base time stamp used for future time stamp adjustments to
  /// the current value. For example, if the [timeDilation] decreases, rather
  /// than scaling down the [Duration] since the beginning of time, [resetEpoch]
  /// will ensure that we only scale down the duration since [resetEpoch] was
  /// called.
  ///
  /// Setting [timeDilation] calls [resetEpoch] automatically. You don't need to
  /// call [resetEpoch] yourself.
  void resetEpoch() {
    _epochStart = _adjustForEpoch(_lastRawTimeStamp);
    _firstRawTimeStampInEpoch = null;
  }

  /// Adjusts the given time stamp into the current epoch.
  ///
  /// This both offsets the time stamp to account for when the epoch started
  /// (both in raw time and in the epoch's own time line) and scales the time
  /// stamp to reflect the time dilation in the current epoch.
  ///
  /// These mechanisms together combine to ensure that the durations we give
  /// during frame callbacks are monotonically increasing.
  Duration _adjustForEpoch(Duration rawTimeStamp) {
    final Duration rawDurationSinceEpoch = _firstRawTimeStampInEpoch == null
        ? Duration.zero
        : rawTimeStamp - _firstRawTimeStampInEpoch;
    return new Duration(
        microseconds:
            (rawDurationSinceEpoch.inMicroseconds / timeDilation).round() +
                _epochStart.inMicroseconds);
  }

  /// The time stamp for the frame currently being processed.
  ///
  /// This is only valid while [handleBeginFrame] is running, i.e. while a frame
  /// is being produced.
  Duration get currentFrameTimeStamp {
    assert(_currentFrameTimeStamp != null);
    return _currentFrameTimeStamp;
  }

  Duration _currentFrameTimeStamp;

  /// Called by the engine to prepare the framework to produce a new frame.
  ///
  /// This function calls all the transient frame callbacks registered by
  /// [scheduleFrameCallback]. It then returns, any scheduled microtasks are run
  /// (e.g. handlers for any [Future]s resolved by transient frame callbacks),
  /// and [handleDrawFrame] is called to continue the frame.
  ///
  /// If the given time stamp is null, the time stamp from the last frame is
  /// reused.
  ///
  /// To have a banner shown at the start of every frame in debug mode, set
  /// [debugPrintBeginFrameBanner] to true. The banner will be printed to the
  /// console using [debugPrint] and will contain the frame number (which
  /// increments by one for each frame), and the time stamp of the frame. If the
  /// given time stamp was null, then the string "warm-up frame" is shown
  /// instead of the time stamp. This allows frames eagerly pushed by the
  /// framework to be distinguished from those requested by the engine in
  /// response to the "Vsync" signal from the operating system.
  ///
  /// You can also show a banner at the end of every frame by setting
  /// [debugPrintEndFrameBanner] to true. This allows you to distinguish log
  /// statements printed during a frame from those printed between frames (e.g.
  /// in response to events or timers).
  void handleBeginFrame(Duration rawTimeStamp) {
    _firstRawTimeStampInEpoch ??= rawTimeStamp;
    _currentFrameTimeStamp = _adjustForEpoch(rawTimeStamp ?? _lastRawTimeStamp);
    if (rawTimeStamp != null) _lastRawTimeStamp = rawTimeStamp;

    _hasScheduledFrame = false;
    try {
      // TRANSIENT FRAME CALLBACKS
      _schedulerPhase = SchedulerPhase.transientCallbacks;
      final Map<int, _FrameCallbackEntry> callbacks = _transientCallbacks;
      _transientCallbacks = <int, _FrameCallbackEntry>{};
      callbacks.forEach((int id, _FrameCallbackEntry callbackEntry) {
        if (!_removedIds.contains(id)) {
          _invokeFrameCallback(callbackEntry.callback, _currentFrameTimeStamp,
              callbackEntry.debugStack);
        }
      });
      _removedIds.clear();
    } finally {
      _schedulerPhase = SchedulerPhase.midFrameMicrotasks;
    }
  }

  /// Called by the engine to produce a new frame.
  ///
  /// This method is called immediately after [handleBeginFrame]. It calls all
  /// the callbacks registered by [addPersistentFrameCallback], which typically
  /// drive the rendering pipeline, and then calls the callbacks registered by
  /// [addPostFrameCallback].
  ///
  /// See [handleBeginFrame] for a discussion about debugging hooks that may be
  /// useful when working with frame callbacks.
  void handleDrawFrame() {
    assert(_schedulerPhase == SchedulerPhase.midFrameMicrotasks);
    try {
      // PERSISTENT FRAME CALLBACKS
      _schedulerPhase = SchedulerPhase.persistentCallbacks;
      for (FrameCallback callback in _persistentCallbacks)
        _invokeFrameCallback(callback, _currentFrameTimeStamp);

      // POST-FRAME CALLBACKS
      _schedulerPhase = SchedulerPhase.postFrameCallbacks;
      final List<FrameCallback> localPostFrameCallbacks =
          new List<FrameCallback>.from(_postFrameCallbacks);
      _postFrameCallbacks.clear();
      for (FrameCallback callback in localPostFrameCallbacks)
        _invokeFrameCallback(callback, _currentFrameTimeStamp);
    } finally {
      _schedulerPhase = SchedulerPhase.idle;
      _currentFrameTimeStamp = null;
    }
  }

  // Calls the given [callback] with [timestamp] as argument.
  //
  // Wraps the callback in a try/catch and forwards any error to
  // [debugSchedulerExceptionHandler], if set. If not set, then simply prints
  // the error.
  void _invokeFrameCallback(FrameCallback callback, Duration timeStamp,
      [StackTrace callbackStack]) {
    assert(callback != null);
    assert(_FrameCallbackEntry.debugCurrentCallbackStack == null);
    assert(() {
      _FrameCallbackEntry.debugCurrentCallbackStack = callbackStack;
      return true;
    }());
    callback(timeStamp);
    assert(() {
      _FrameCallbackEntry.debugCurrentCallbackStack = null;
      return true;
    }());
  }

  /// Schedules a new frame using [scheduleFrame] if this object is not
  /// currently producing a frame.
  ///
  /// Calling this method ensures that [handleDrawFrame] will eventually be
  /// called, unless it's already in progress.
  ///
  /// This has no effect if [schedulerPhase] is
  /// [SchedulerPhase.transientCallbacks] or [SchedulerPhase.midFrameMicrotasks]
  /// (because a frame is already being prepared in that case), or
  /// [SchedulerPhase.persistentCallbacks] (because a frame is actively being
  /// rendered in that case). It will schedule a frame if the [schedulerPhase]
  /// is [SchedulerPhase.idle] (in between frames) or
  /// [SchedulerPhase.postFrameCallbacks] (after a frame).
  void ensureVisualUpdate() {
    switch (schedulerPhase) {
      case SchedulerPhase.idle:
      case SchedulerPhase.postFrameCallbacks:
        scheduleFrame();
        return;
      case SchedulerPhase.transientCallbacks:
      case SchedulerPhase.midFrameMicrotasks:
      case SchedulerPhase.persistentCallbacks:
        return;
    }
  }
}

/// The default [SchedulingStrategy] for [SchedulerBinding.schedulingStrategy].
///
/// If there are any frame callbacks registered, only runs tasks with
/// a [Priority] of [Priority.animation] or higher. Otherwise, runs
/// all tasks.
bool defaultSchedulingStrategy({int priority, SchedulerBinding scheduler}) {
  if (scheduler.transientCallbackCount > 0)
    return priority >= Priority.animation.value;
  return true;
}

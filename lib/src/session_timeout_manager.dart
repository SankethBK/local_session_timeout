import 'dart:async';

import 'package:flutter/material.dart';
import 'session_config.dart';

class SessionTimeoutManager extends StatefulWidget {
  final SessionConfig _sessionConfig;
  final Widget child;

  /// Since updating [Timer] fir all user interactions could be expensive, user activity are recorded
  /// only after [updateUserActivityWindow] interval, by default its 1 minute
  final Duration updateUserActivityWindow;
  const SessionTimeoutManager({
    Key? key,
    required sessionConfig,
    required this.child,
    this.updateUserActivityWindow = const Duration(minutes: 1),
  })  : _sessionConfig = sessionConfig,
        super(key: key);

  @override
  _SessionTimeoutManagerState createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager>
    with WidgetsBindingObserver {
  Timer? _appLostFocusTimer;
  Timer? _userInactivityTimer;

  bool _userTapActivityRecordEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (widget._sessionConfig.invalidateSessionForAppLostFocus != null) {
        _appLostFocusTimer ??= _setTimeout(
          () => widget._sessionConfig.pushSessionInvalidEvent(),
          duration: widget._sessionConfig.invalidateSessionForAppLostFocus!,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_appLostFocusTimer != null) {
        _clearTimeout(_appLostFocusTimer!);
        _appLostFocusTimer = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attach Listener only if user wants to invalidate session on user inactivity
    if (widget._sessionConfig.invalidateSessionForUserInactiviity != null) {
      return Listener(
        onPointerDown: (_) {
          if (_userTapActivityRecordEnabled) {
            _userInactivityTimer?.cancel();
            _userInactivityTimer = _setTimeout(
              () => widget._sessionConfig.pushSessionInvalidEvent(),
              duration:
                  widget._sessionConfig.invalidateSessionForUserInactiviity!,
            );

            /// lock the button for next [updateUserActivityWindow] duration

            setState(() {
              _userTapActivityRecordEnabled = false;
            });

            // Enable it after [updateUserActivityWindow] duration

            Timer(
              widget.updateUserActivityWindow,
              () => setState(() => _userTapActivityRecordEnabled = true),
            );
          }
        },
        child: widget.child,
      );
    }

    return widget.child;
  }

  Timer _setTimeout(callback, {required Duration duration}) {
    return Timer(duration, callback);
  }

  void _clearTimeout(Timer t) {
    t.cancel();
  }
}

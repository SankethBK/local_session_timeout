import 'dart:async';

enum SessionTimeoutState { appFocusTimeout, userInactivityTimeout }

class SessionConfig {
  /// Immediately invalidates the sesion after [invalidateSessionForUserInactivity] duration of user inactivity
  ///
  /// If null, never invalidates the session for user inactivity
  final Duration? invalidateSessionForUserInactivity;

  ///  mmediately invalidates the sesion after [invalidateSessionForAppLostFocus] duration of app losing focus
  ///
  /// If null, never invalidates the session for app losing focus
  final Duration? invalidateSessionForAppLostFocus;

  SessionConfig({
    this.invalidateSessionForUserInactivity,
    this.invalidateSessionForAppLostFocus,
  });

  final _controller = StreamController<SessionTimeoutState>();

  /// Stream yields Map if session is valid, else null
  Stream<SessionTimeoutState> get stream => _controller.stream;

  /// invalidate session and pass [SessionTimeoutState.appFocusTimeout] through stream
  void pushAppFocusTimeout() {
    _controller.sink.add(SessionTimeoutState.appFocusTimeout);
  }

  /// invalidate session and pass [SessionTimeoutState.userInactivityTimeout] through stream
  void pushUserInactivityTimeout() {
    _controller.sink.add(SessionTimeoutState.userInactivityTimeout);
  }

  /// call dispose method to close the stream
  /// usually SessionConfig.stream should keep running until the app is terminated.
  /// But if your usecase requires closing the stream, call the dispose method
  void dispose() {
    _controller.close();
  }
}

import 'package:flutter/material.dart';
import 'package:local_session_timeout/local_session_timeout.dart';

void main() {
  runApp(MyApp());
}

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MyHomePage()));
          },
          child: const Text("Login"),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
        invalidateSessionForAppLostFocus: const Duration(seconds: 15),
        invalidateSessionForUserInactiviity: const Duration(seconds: 60));
    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        // handle user  inactive timeout
        _navigator.push(MaterialPageRoute(builder: (_) => AuthPage()));
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        // handle user  app lost focus timeout
        _navigator.push(MaterialPageRoute(builder: (_) => AuthPage()));
      }
    });
    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthPage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Home page"),
      ),
    );
  }
}

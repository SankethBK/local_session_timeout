import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_session_timeout/local_session_timeout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  /// Make this stream available throughout the widget tree with with any state management library
  /// like bloc, provider, GetX, ..
  final sessionStateStream = StreamController<SessionState>();

  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(seconds: 3),
      invalidateSessionForUserInactiviity: const Duration(seconds: 5),
    );
    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      print("timeoutEvent = $timeoutEvent");
      // stop listening, as user will already be in auth page
      sessionStateStream.add(SessionState.stopListening);
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        // handle user  inactive timeout
        _navigator.push(MaterialPageRoute(
          builder: (_) => AuthPage(
              sessionStateStream: sessionStateStream,
              loggedOutReason: "Logged out because of user inactivity"),
        ));
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        // handle user  app lost focus timeout
        _navigator.push(MaterialPageRoute(
          builder: (_) => AuthPage(
              sessionStateStream: sessionStateStream,
              loggedOutReason: "Logged out because app lost focus"),
        ));
      }
    });
    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      sessionStateStream: sessionStateStream.stream,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthPage(
          sessionStateStream: sessionStateStream,
        ),
      ),
    );
  }
}

class AuthPage extends StatelessWidget {
  StreamController<SessionState> sessionStateStream;

  String loggedOutReason;

  AuthPage(
      {Key? key, required this.sessionStateStream, this.loggedOutReason = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loggedOutReason != "")
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Text(loggedOutReason),
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // start listening only after user logs in
                  sessionStateStream.add(SessionState.startListening);
                  loggedOutReason = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MyHomePage(
                        sessionStateStream: sessionStateStream,
                      ),
                    ),
                  );
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  StreamController<SessionState> sessionStateStream;

  MyHomePage({Key? key, required this.sessionStateStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Home page"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // stop listening only after user goes to this page

                //! Its better to handle listening logic in state management
                //! libraries rather than writing them at random places in your app

                sessionStateStream.add(SessionState.stopListening);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReadingPage(),
                  ),
                );

                //! after user returns from that page start listening again
                sessionStateStream.add(SessionState.startListening);
              },
              child: const Text("Reading page"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WritingPage(
                      sessionStream: sessionStateStream,
                    ),
                  ),
                );
              },
              child: const Text("Writing Page"),
            ),
          ],
        ),
      ),
    );
  }
}

// This [age can text content, which user might be reading without any user activity
// If you want to disable the session timeout listeners when user enters such pages
// follow the below code
class ReadingPage extends StatefulWidget {
  const ReadingPage({Key? key}) : super(key: key);

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              "This page can have lot of extent content, and user might be reading this without performing any user activity. So you might want to disable sesison timeout listeners only for this page"),
        ),
      ),
    );
  }
}

// If the user is typing into the textbox, you may want to disable the session
// timeout listeners because typing events aren't captured by session timeout
// manager and it may conclude that user is inactive
class WritingPage extends StatefulWidget {
  final StreamController<SessionState> sessionStream;
  const WritingPage({Key? key, required this.sessionStream}) : super(key: key);

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      // softkeyboard is open
      widget.sessionStream.add(SessionState.stopListening);
    } else {
      // keyboard is closed
      widget.sessionStream.add(SessionState.startListening);
    }
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
                "If the user is typing into the textbox, you may want to disable the session timeout listeners because typing events aren't captured by session timeout manager and it may conclude that user is inactive"),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 16, 17, 17))),
                hintText: 'Start typing here',
                helperText: 'when keyboard is open, session won"t expire',
                prefixText: ' ',
                suffixText: 'USD',
                suffixStyle: TextStyle(
                  color: Color.fromARGB(255, 14, 14, 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

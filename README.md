<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->


* With local_session_tomeout you can redirect user to authentication page, if the application hasn't recieved any user interaction, or been running in the background for "x" duration.
* Works locally, does not require internet connection.
* Useful for apps with confidential information. If the user leaves the app running, or pushes it to the background to use later and forgets to close it.
* Works on android, ios, web and desktop.

## Getting started

```dart
import 'package:local_timeout_session/local_session_timeout.dart';
```
#### Create SessionConfig object

An object responsible for specifying durations for different types of timeouts. 

It exposes a stream which can be listened for timeout events

```dart
final sessionConfig = SessionConfig(
    invalidateSessionForAppLostFocus: const Duration(seconds: 15),
    invalidateSessionForUserInactiviity: const Duration(seconds: 30));
```

```dart
sessionConfig.listen((SessionTimeoutState timeoutEvent) {
    if (timeout == SessionTimeoutState.userInactivityTimeout) {
        // handle user  inactive timeout
        // Navigator.of(context).pushNamed("/auth");
    } else if (imeout == SessionTimeoutState.appFocusTimeout) {
        // handle user  app lost focus timeout
        // Navigator.of(context).pushNamed("/auth");
    }
});
```

##### Parameters

* __invalidateSessionForAppLostFocus (Duration? duration):__ *appFocusTimeout* event will be emitted through the stream, if the app loses focus and running in background for specified duration. If duration passed is *null*, app will not emit timeout events for losing focus / pushed into background.

* __invalidateSessionForUserInactiviity (Duration? duration):__ *userInactivityTimeout* evebt will be emitted through the stream, if the app doesn't recieve any user activity for specified duration. If duration passed is *null*, app will not emit timeout events for user inactivity.

#### Create SessionTimeoutManager object

```dart
SessionTimeoutManager(
    sessionConfig: sessionConfig,
    child: MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
        primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
    )
);
```


##### Parameters

* __sessionConfig (SessionConfig sessionConfig):__ *sessionConfig* object that was created previously.
* __child (Widget widget):__ child widget in widget tree.
* __updateUserActivityWindow (Duration duration) (optional):__ Since creating a timer object for each user interaction can be CPU intensive, a new timer will be started only in the intervals of *updateUserActivityWindow* duration, has default value of 1 minute.  

Note: `Make sure to keep SessionTimeoutManager as top level widget of your widget tree, so that it records user activity in all screens`



#### Complete Usage

```dart

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
        invalidateSessionForAppLostFocus: const Duration(seconds: 15),
        invalidateSessionForUserInactiviity: const Duration(seconds: 30));

    sessionConfig.listen((SessionTimeoutState timeoutEvent) {
    if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        // handle user  inactive timeout
        // Navigator.of(context).pushNamed("/auth");
    } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        // handle user  app lost focus timeout
        // Navigator.of(context).pushNamed("/auth");
    }
});

    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
```
## Additional information

This package can be used for both online and offline applications. Even if the application has session / token based auth with webserver, invalidating the session may require require communication with web server, which is not possibe if the user turns off internet connection and pushes the app to the background.


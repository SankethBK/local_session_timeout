import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('app lost focus tests', () {
    testWidgets('redirected from home page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the login screen.
      expect(find.text('Login'), findsOneWidget);

      // Finds the login  button to tap on.
      final Finder loginButton = find.text('Login');

      // Emulate a tap on the floating action button.
      await tester.tap(loginButton);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // verify we are on the home page
      expect(find.text('Home page'), findsOneWidget);

      // minimize the app
      FlutterForegroundTask.minimizeApp();

      // wait for 6 seconds and see if we are redirected to login page
      await Future<void>.delayed(const Duration(seconds: 4));

      // launch the app
      FlutterForegroundTask.launchApp();

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('user shouldn\'t be redirected from home page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the login screen.
      expect(find.text('Login'), findsOneWidget);

      // Finds the floating action button to tap on.
      final Finder loginButton = find.text('Login');

      // Emulate a tap on the floating action button.
      await tester.tap(loginButton);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // verify we are on the home page
      expect(find.text('Home page'), findsOneWidget);

      // go to read page
      final Finder readingPageButton = find.text('Reading page');
      await tester.tap(readingPageButton);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // verify that we are on the reading page
      expect(
          find.text(
            "This page can have lot of extent content, and user might be reading this without performing any user activity. So you might want to disable sesison timeout listeners only for this page",
          ),
          findsOneWidget);

      // minimize the app
      FlutterForegroundTask.minimizeApp();

      // wait for 6 seconds and see if we are redirected to login page
      await Future<void>.delayed(const Duration(seconds: 4));

      // launch the app
      FlutterForegroundTask.launchApp();

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));

      // verify that we are still on the reading page
      expect(
          find.text(
            "This page can have lot of extent content, and user might be reading this without performing any user activity. So you might want to disable sesison timeout listeners only for this page",
          ),
          findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_dev_formative_assignment2/screens/welcome.dart';

void main() {
  testWidgets('welcome screen presents the main actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        routes: {
          '/signUp': (_) => const Scaffold(body: Text('Create account')),
        },
      ),
    );

    expect(find.text('CampusCare'), findsOneWidget);
    expect(find.text('A better campus.\nStarts with you.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('get started navigates to sign up', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        routes: {
          '/signUp': (_) => const Scaffold(body: Text('Create account')),
        },
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
  });
}

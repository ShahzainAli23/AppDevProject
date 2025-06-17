import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darb_food_app/views/login_screen.dart';

void main() {
  testWidgets('LoginScreen UI renders essential elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text("Enter Email*"), findsOneWidget);
    expect(find.text("Enter Password*"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text("SIGN UP"), findsOneWidget);
  });

  testWidgets('Obscure password toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final visibilityButton = find.byIcon(Icons.visibility_off);
    expect(visibilityButton, findsOneWidget);

    await tester.tap(visibilityButton);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('Email and password fields accept input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);

    await tester.enterText(emailField, 'user@darbs.com');
    await tester.enterText(passwordField, '123456');

    expect(find.text('user@darbs.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
  });
}

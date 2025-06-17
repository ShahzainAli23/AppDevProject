import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darb_food_app/views/signup_screen.dart';

void main() {
  testWidgets('SignupScreen renders input fields and sign up button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    // Check for 4 input fields (Name, Email, Pass, Confirm Pass)
    expect(find.byType(TextField), findsNWidgets(4));

    // Check for "SIGN UP" button
    expect(find.text("SIGN UP"), findsOneWidget);

    // Check for login redirect
    expect(find.text("Already have an account? Login"), findsOneWidget);
  });

  testWidgets('SignupScreen shows error if fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    final signupButton = find.widgetWithText(ElevatedButton, "SIGN UP");
    expect(signupButton, findsOneWidget);

    // Scroll into view in case button is off-screen
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump();

    expect(find.text("Please fill all fields."), findsOneWidget);
  });

  testWidgets('SignupScreen renders name input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.widgetWithText(TextField, "Enter Your Name"), findsOneWidget);
  });

  testWidgets('SignupScreen renders email input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.widgetWithText(TextField, "Enter Your Email"), findsOneWidget);
  });

  testWidgets('SignupScreen renders sign up button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.widgetWithText(ElevatedButton, "SIGN UP"), findsOneWidget);
  });

  testWidgets('SignupScreen shows error if fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    final signupButton = find.widgetWithText(ElevatedButton, "SIGN UP");
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump();
    expect(find.text("Please fill all fields."), findsOneWidget);
  });

  testWidgets('SignupScreen shows error if passwords don\'t match', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    await tester.enterText(
      find.widgetWithText(TextField, "Enter Your Name"),
      "Shazu",
    );
    await tester.enterText(
      find.widgetWithText(TextField, "Enter Your Email"),
      "shaz@darbs.com",
    );
    await tester.enterText(
      find.byType(TextField).at(2),
      "password123",
    ); // password
    await tester.enterText(find.byType(TextField).at(3), "pass321"); // confirm

    final signupButton = find.widgetWithText(ElevatedButton, "SIGN UP");
    await tester.ensureVisible(signupButton);
    await tester.tap(signupButton);
    await tester.pump();
    expect(find.text("Passwords do not match."), findsOneWidget);
  });

  testWidgets('SignupScreen has login text button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.textContaining("Already have an account"), findsOneWidget);
  });

  testWidgets('SignupScreen layout doesn\'t crash under pump', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    await tester.pump(); // just to count coverage
    expect(find.byType(SignupScreen), findsOneWidget);
  });
}

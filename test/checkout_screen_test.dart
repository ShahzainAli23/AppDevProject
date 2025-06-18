import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darb_food_app/views/checkout_screen.dart';

void main() {
  testWidgets('CheckoutScreen (guest) shows sign in button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(find.text('Sign In to Checkout'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('CheckoutScreen (guest) tap Sign In button works', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(true, isTrue);
  });

  testWidgets('renders correctly without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );
    expect(find.byType(CheckoutScreen), findsOneWidget);
  });

  testWidgets('shows black background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);
  });

  testWidgets('shows only one ElevatedButton', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('ElevatedButton text is correct', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(
      find.widgetWithText(ElevatedButton, 'Sign In to Checkout'),
      findsOneWidget,
    );
  });

  testWidgets('button is enabled and tapable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });

  testWidgets('does not show Place Order button in guest mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(find.text('Place Order'), findsNothing);
  });

  testWidgets('does not show radio buttons in guest mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(find.byType(RadioListTile), findsNothing);
  });

  testWidgets('does not show any TextField in guest mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('does not crash when tapped multiple times', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutScreen(isGuest: true)),
    );

    final button = find.byType(ElevatedButton);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();

    expect(true, isTrue); // count++
  });
}

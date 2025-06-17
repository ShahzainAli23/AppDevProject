import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:darb_food_app/views/options_screen.dart';

void main() {
  group('OptionsScreen', () {
    testWidgets('renders all tiles for guest user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: OptionsScreen(isGuest: true)));

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders logout tile for non-guest user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: OptionsScreen(isGuest: false)));

      expect(find.text('Logout'), findsOneWidget);
    });
  });
}

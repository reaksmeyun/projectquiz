import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projectquiz/pages/onboarding.dart';

void main() {
  testWidgets('Onboarding screen displays welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    // Verify welcome text exists
    expect(find.text('Welcome to Quiz App!'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap the Get Started button
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Since it navigates, you could check if LoginScreen is pushed
    // (Optional, if LoginScreen is imported)
  });
}

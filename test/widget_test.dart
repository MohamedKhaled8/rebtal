import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebtal/feature/welcome/ui/travel_onboarding_screen.dart';

void main() {
  testWidgets('Travel onboarding builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TravelOnboardingScreen()),
    );
    expect(find.byType(TravelOnboardingScreen), findsOneWidget);
  });
}

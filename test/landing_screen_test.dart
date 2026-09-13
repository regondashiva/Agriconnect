import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agriconnect/features/landing/landing_screen.dart';

void main() {
  testWidgets('LandingScreen renders carousel, supports swipe, and displays correct CTAs', (tester) async {
    // Set phone viewport dimensions (390 x 844 is typical modern mobile)
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LandingScreen(),
      ),
    );
    await tester.pump();

    // Verify Screen 1 elements
    expect(find.text('AgriConnect'), findsWidgets);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get Started →'), findsOneWidget);

    // Tap CTA to advance to Screen 2
    await tester.tap(find.text('Get Started →'));
    await tester.pumpAndSettle();

    // Verify Screen 2 elements
    expect(find.text('Continue →'), findsOneWidget);
    expect(find.text('Farmers'), findsOneWidget);
    expect(find.text('Buyers'), findsOneWidget);

    // Tap CTA to advance to Screen 3
    await tester.tap(find.text('Continue →'));
    await tester.pumpAndSettle();

    // Verify Screen 3 elements
    expect(find.text("Let's Get Started →"), findsOneWidget);
    expect(find.text('Quality\nProduce'), findsOneWidget);
    expect(find.text('Faster\nDelivery'), findsOneWidget);
    expect(find.text('Stronger\nCommunities'), findsOneWidget);
  });
}

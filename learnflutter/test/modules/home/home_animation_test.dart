
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/modules/home/home_aniamtion.dart';
import 'package:learnflutter/modules/indicator/indicator_example_screen.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/profile/pages/profile_screen.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';

void main() {
  testWidgets('HomeAnimationPage should show TestScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeAnimationPage()));

    expect(find.byType(TestScreen), findsOneWidget);
    expect(find.byType(MaterialScreen), findsNothing);
    expect(find.byType(IndicatorExampleScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsNothing);
  });

  testWidgets('HomeAnimationPage should switch pages when bottom nav items are tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeAnimationPage()));

    // Initial screen
    expect(find.byType(TestScreen), findsOneWidget);

    // Tap on the second item (MaterialScreen)
    await tester.tap(find.byIcon(Icons.home_outlined).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(TestScreen), findsNothing);
    expect(find.byType(MaterialScreen), findsOneWidget);

    // Tap on the third item (IndicatorExampleScreen)
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialScreen), findsNothing);
    expect(find.byType(IndicatorExampleScreen), findsOneWidget);

    // Tap on the fourth item (ProfileScreen)
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.byType(IndicatorExampleScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap on the first item again (TestScreen)
    await tester.tap(find.byIcon(Icons.home_outlined).at(0));
    await tester.pumpAndSettle();
    
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(TestScreen), findsOneWidget);
  });

  testWidgets('CustomBottomNav calls onChanged when an item is tapped', (WidgetTester tester) async {
    int? tappedIndex;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNav(
            currentIndex: 0,
            onChanged: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.home_outlined).at(1));
    await tester.pumpAndSettle();

    expect(tappedIndex, 1);
  });

   testWidgets('_AnimatedItem has correct appearance when selected', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
            body: Center(
          child: Builder(builder: (context) {
            return const HomeAnimationPage();
          }),
        )),
      ),
    );

    // Find the first icon and check its initial state (selected)
    final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.home_outlined).first);
    expect(selectedIcon.color, const Color(0xFFD0024F));

    final scale = tester.widget<ScaleTransition>(find.byType(ScaleTransition).first);
    expect(scale.scale.value, 1.25);
    
    // Find the second icon and check its initial state (unselected)
    final unselectedIcon = tester.widget<Icon>(find.byIcon(Icons.home_outlined).last);
    expect(unselectedIcon.color, Colors.grey);
    
    final unselectedScale = tester.widget<ScaleTransition>(find.byType(ScaleTransition).last);
    expect(unselectedScale.scale.value, 1.0);
  });
}

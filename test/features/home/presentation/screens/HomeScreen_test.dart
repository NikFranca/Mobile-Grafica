import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/home/presentation/screens/HomeScreen.dart';

void main() {
  testWidgets('HomeScreen é renderizada', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:zacode/app.dart';

void main() {
  testWidgets('App should build without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}

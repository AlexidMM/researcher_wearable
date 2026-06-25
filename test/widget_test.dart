import 'package:flutter_test/flutter_test.dart';

import 'package:researcher_wearable/ui/wearable/wearable_app.dart';

void main() {
  testWidgets('Wearable app root renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WearableApp());
    expect(find.byType(WearableApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:researcher_wearable/main.dart';

void main() {
  testWidgets('App root renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MiracleFlutterApp());
    expect(find.byType(MiracleFlutterApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:cy_citizenship/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CyCitizenshipApp());
    expect(find.text('Home'), findsWidgets);
  });
}

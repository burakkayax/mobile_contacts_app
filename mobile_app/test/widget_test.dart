import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Uygulama açılış testi', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonManagementApp());
    expect(find.text('Rehber / Kişi Listesi'), findsOneWidget);
  });
}

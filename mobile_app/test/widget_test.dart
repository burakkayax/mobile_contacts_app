import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/person.dart';
import 'package:mobile_app/screens/person_form_screen.dart';

void main() {
  test('Person.fromJson ve toJson veri şeması doğrulaması', () {
    final sampleJson = {
      'id': 104,
      'fullName': 'Ahmet Yılmaz',
      'department': 'Yazılım Geliştirme',
      'photoUrl': 'https://cdn.site/p/104.png',
      'birthPlace': 'Adana',
      'birthDate': '1994-04-12',
      'email': 'ahmet.yilmaz@sirket.com',
      'phone': '+905550123456',
    };

    final person = Person.fromJson(sampleJson);
    expect(person.id, 104);
    expect(person.fullName, 'Ahmet Yılmaz');
    expect(person.department, 'Yazılım Geliştirme');
    expect(person.formattedBirthDate, '12.04.1994');
    expect(person.toJson(), sampleJson);
  });

  testWidgets('Ana sayfa wireframe başlığı ve FAB (+) butonu görüntülenir',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PersonManagementApp());
    expect(find.text('Rehber / Kişi Listesi'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Kişi kayıt formu zorunlu alan doğrulaması çalışır',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonFormScreen(),
      ),
    );

    expect(find.text('Yeni Kişi Kaydı'), findsOneWidget);
    await tester.tap(find.text('KİŞİYİ KAYDET'));
    await tester.pump();

    expect(find.text('Ad Soyad zorunludur'), findsOneWidget);
    expect(find.text('Departman zorunludur'), findsOneWidget);
  });
}

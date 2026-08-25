import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mta_app/screens/login_screen.dart';
import 'package:mta_app/widgets/auth_inputs.dart';

void main() {
  testWidgets('Login screen renders required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('ليس لديك حساب؟'), findsOneWidget);
    expect(find.text('إنشاء حساب جديد'), findsWidgets);
  });

  testWidgets('Login shows validation error for invalid email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextField).first, 'invalid-email');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.ensureVisible(find.byType(PrimaryGradientButton));
    await tester.tap(find.byType(PrimaryGradientButton));
    await tester.pump();

    expect(find.text('يرجى إدخال بريد إلكتروني صالح'), findsOneWidget);
  });
}



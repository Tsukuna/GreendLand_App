import 'package:assignment_hml/Assignment/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Sign Up button and Email,Username,Password InputFields are present',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterField()));

    // Verify if the Sign Up button is present
    expect(find.widgetWithText(FormButton, 'Sign Up'), findsOneWidget);

    // Verify if the Email input field is present
    expect(find.widgetWithText(InputField, 'Email'), findsOneWidget);

    // Verify if the Username input field is present
    expect(find.widgetWithText(InputField, 'Username'), findsOneWidget);

    // Verify if the Password input field is present
    expect(find.widgetWithText(InputField, 'Password'), findsOneWidget);
  });
}

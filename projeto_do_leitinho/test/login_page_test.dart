import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_do_leitinho/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projeto_do_leitinho/features/auth/presentation/pages/login_page.dart';
import 'package:projeto_do_leitinho/core/theme/app_theme.dart';

void main() {
  group('LoginPage Widget Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    Widget createWidgetUnderTest() {
      return BlocProvider<AuthBloc>(
        create: (_) => authBloc,
        child: MaterialApp(theme: AppTheme.lightTheme, home: const LoginPage()),
      );
    }

    testWidgets('displays app name and subtitle', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('PuroLácteo'), findsOneWidget);
      expect(find.text('Sistema de Gestão de Leite'), findsOneWidget);
    });

    testWidgets('displays login form fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('CPF ou CNPJ'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Senha'),
      );

      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility);
      expect(visibilityToggle, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('validates empty document field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap login without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Campo obrigatório'), findsWidgets);
    });

    testWidgets('validates invalid CPF', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid CPF
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou CNPJ'),
        '11111111111',
      );

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('CPF inválido'), findsOneWidget);
    });

    testWidgets('formats CPF input correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final documentField = find.widgetWithText(TextFormField, 'CPF ou CNPJ');

      // Enter CPF digits
      await tester.enterText(documentField, '12345678909');
      await tester.pump();

      // Should be formatted as CPF
      final textField = tester.widget<TextFormField>(documentField);
      expect(textField.controller?.text, contains('.'));
      expect(textField.controller?.text, contains('-'));
    });

    testWidgets('shows loading indicator on login', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou CNPJ'),
        '12345678909',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to collector dashboard on CPF login', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid CPF
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou CNPJ'),
        '12345678909',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to collector dashboard
      expect(find.text('Dashboard Coletor'), findsOneWidget);
    });

    testWidgets('shows error snackbar on invalid credentials', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid CPF (all same digits)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'CPF ou CNPJ'),
        '11111111111',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('CPF inválido'), findsWidgets);
    });
  });
}

extension on TextFormField {
  get obscureText => null;
}

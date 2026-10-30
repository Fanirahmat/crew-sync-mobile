import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders brand mark, inputs, and submit button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Wait for AsyncNotifier build() to resolve to AsyncData(null)
    await tester.pumpAndSettle();

    // Verify brand mark
    expect(find.text('CrewSync - Field Ops'), findsOneWidget);
    expect(find.text('Masuk ke Akun Kru'), findsOneWidget);
    expect(find.text('Gunakan nomor HP atau email yang didaftarkan vendor'), findsOneWidget);

    // Verify form inputs
    expect(find.text('Nomor WhatsApp / Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);

    // Verify button and link
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Lupa kata sandi? Hubungi Koordinator'), findsOneWidget);

    // Tap submit button with empty form to trigger validation
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    // Verify validation error messages
    expect(find.text('Nomor WhatsApp atau Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
  });
}

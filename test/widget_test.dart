import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crewsync_mobile/app.dart';

void main() {
  testWidgets('CrewSync app boots to LoginScreen when unauthenticated', (WidgetTester tester) async {
    // Build app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: CrewSyncApp(),
      ),
    );

    // Wait for auth initialization
    await tester.pumpAndSettle();

    // Verify Login Screen elements appear
    expect(find.text('CrewSync - Field Ops'), findsOneWidget);
    expect(find.text('Masuk ke Akun Kru'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}

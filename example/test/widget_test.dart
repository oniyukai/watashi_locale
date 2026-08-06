import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watashi_locale_example/main.dart';

void main() {
  testWidgets('App starts and shows default text', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MyAppProvider(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Current Locale'), findsOneWidget);
    expect(find.text('showLicensePage'), findsOneWidget);
  });
}

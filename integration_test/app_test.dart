import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:acme_tasks/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and shows Tasks title', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsOneWidget);
  });
}

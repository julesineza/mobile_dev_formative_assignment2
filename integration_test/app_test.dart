import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_dev_formative_assignment2/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app opens on the CampusCare welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('CampusCare'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi2_pemmob/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test initializes CuacaApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CuacaApp());
    // Memastikan judul aplikasi 'Cuaca' tampil di AppBar
    expect(find.text('Cuaca'), findsOneWidget);
  });
}

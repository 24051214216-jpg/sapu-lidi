import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapu_lidi/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Aplikasi SapuLidi menampilkan halaman onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SapuLidiApp());

    expect(find.text('Mulai Sekarang'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uspace_app/main.dart';

void main() {
  testWidgets('shows an honest demo foundation state', (tester) async {
    await tester.pumpWidget(const USpaceApp());
    expect(find.text('USpace'), findsOneWidget);
    expect(find.textContaining('Środowisko demonstracyjne'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:primeview/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PrimeViewApp());
    await tester.pump();
    expect(find.text('PrimeView'), findsOneWidget);
  });
}

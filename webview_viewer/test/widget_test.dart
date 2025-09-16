import 'package:flutter_test/flutter_test.dart';
import 'package:webview_viewer/main.dart';

void main() {
  testWidgets('shows default url in the text field', (WidgetTester tester) async {
    await tester.pumpWidget(const WebViewViewerApp());

    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.text('URL оруулна уу'), findsOneWidget);
  });
}

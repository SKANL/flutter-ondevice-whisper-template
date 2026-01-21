// Ignore for testing purposes

import 'package:flutter_test/flutter_test.dart';
import 'package:w_zentyar_app/app/app.dart';
import 'package:w_zentyar_app/model_download/model_download.dart';

void main() {
  group('App', () {
    testWidgets('renders ModelDownloadPage', (tester) async {
      await tester.pumpWidget(const App());
      // App should render ModelDownloadPage as the home page
      expect(find.byType(ModelDownloadPage), findsOneWidget);
    });
  });
}

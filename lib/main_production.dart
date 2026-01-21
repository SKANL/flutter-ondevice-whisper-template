import 'package:w_zentyar_app/app/app.dart';
import 'package:w_zentyar_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}

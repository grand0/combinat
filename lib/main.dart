import 'package:flutter/material.dart';

import 'utils/prefs.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();

  runApp(const App());
}

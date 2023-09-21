import 'package:combinat/app.dart';
import 'package:combinat/prefs.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  await initPrefs();

  runApp(const App());
}

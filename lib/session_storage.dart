import 'dart:ui';

import 'math/fraction.dart';

class HistoryStorage {
  static final List<String> history = <String>[];

  static final List<VoidCallback> listeners = <VoidCallback>[];

  static addListener(VoidCallback listener) => listeners.add(listener);

  static _notifyListeners() {
    for (final l in listeners) {
      l.call();
    }
  }

  static bool get isEmpty => history.isEmpty;

  static void add(String tex) {
    history.insert(0, tex);
    _notifyListeners();
  }

  static void clear() {
    history.clear();
    _notifyListeners();
  }

  static void addWithBigInt(String tex, BigInt result) {
    add("$tex=$result");
  }

  static void addWithFraction(String tex, Fraction result) {
    result = result.shortForm;
    add("$tex=\\frac{${result.numerator}}{${result.denominator}}");
  }
}

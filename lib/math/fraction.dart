class Fraction {
  final BigInt numerator;
  final BigInt denominator;

  Fraction({
    required this.numerator,
    required this.denominator,
  }) {
    if (denominator == 0.big) {
      throw UnsupportedError("Denominator can't be 0.");
    }
  }

  bool get isShortForm => numerator.gcd(denominator) == 1.big;

  Fraction get shortForm {
    final gcd = numerator.gcd(denominator);
    return Fraction(numerator: numerator ~/ gcd, denominator: denominator ~/ gcd);
  }

  double get doubleValue => numerator / denominator;

  @override
  String toString() => "$numerator/$denominator";
}

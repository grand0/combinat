class Fraction {
  late final BigInt numerator;
  late final BigInt denominator;

  Fraction({
    required BigInt numerator,
    required BigInt denominator,
  }) {
    if (denominator == BigInt.zero) {
      throw UnsupportedError("Denominator can't be 0.");
    }

    final gcd = numerator.gcd(denominator);
    this.numerator = numerator ~/ gcd;
    this.denominator = denominator ~/ gcd;
  }

  double doubleValue() => numerator / denominator;

  @override
  String toString() => "$numerator/$denominator";
}

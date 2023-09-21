extension IntExt on int {
  int fact() {
    if (this < 0) {
      throw StateError("Can't calculate factorial of a negative number.");
    } else if (this <= 1) {
      return 1;
    }

    return this * (this - 1).fact();
  }
}

extension BigIntExt on BigInt {
  BigInt fact() {
    if (this < BigInt.zero) {
      throw StateError("Can't calculate factorial of a negative number.");
    } else if (this <= BigInt.one) {
      return BigInt.one;
    }

    return this * (this - BigInt.one).fact();
  }
}

extension DoubleExt on double {
  BigInt toBigInt() {
    return BigInt.parse(toStringAsFixed(0));
  }
}

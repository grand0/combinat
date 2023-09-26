extension IntExt on int {
  static int get intMaxValue =>
      9007199254740991; // 2^53 - 1: max value for dart web

  BigInt get big {
    return switch (this) {
      0 => BigInt.zero,
      1 => BigInt.one,
      2 => BigInt.two,
      _ => BigInt.from(this),
    };
  }
}

extension BigIntExt on BigInt {
  BigInt fact() {
    if (this < 0.big) {
      throw StateError("Can't calculate factorial of a negative number.");
    } else if (this <= 1.big) {
      return 1.big;
    }

    return partFact(1.big);
  }

  BigInt partFact(BigInt from) {
    if (from < 1.big) {
      throw StateError(
          "Can't calculate product starting from non-positive number.");
    } else if (this < 0.big) {
      throw StateError("Can't calculate product for a negative number.");
    } else if (this < from) {
      throw StateError(
          "Can't calculate product starting from a number greater than this number.");
    } else if (this <= 1.big) {
      return 1.big;
    }

    BigInt result = 1.big;
    for (var i = from; i <= this; i += 1.big) {
      result *= i;
    }
    return result;
  }

  static BigInt max(BigInt a, BigInt b) {
    if (a > b) {
      return a;
    } else {
      return b;
    }
  }
}

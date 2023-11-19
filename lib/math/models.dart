import 'formulas.dart';
import 'fraction.dart';

enum Model {
  allMarked(
    name: "All marked",
    description:
        "n items, m of them are marked. k random items are taken (k <= m). What is probability that all taken items are marked?",
    tex: r"P(A)=\frac{C^{k}_{m}}{C^{k}_{n}}",
    variables: ["n", "m", "k"],
  ),
  rMarked(
    name: "r marked",
    description:
        "n items, m of them are marked. k random items are taken (k <= m). What is probability that r of the taken items are marked?",
    tex: r"P(A)=\frac{C^{r}_{m}C^{k-r}_{n-m}}{C^{k}_{n}}",
    variables: ["n", "m", "k", "r"],
  );

  final String name;
  final String description;
  final String tex;
  final List<String> variables;
  final List<String> multiVariables;

  const Model({
    required this.name,
    required this.description,
    required this.tex,
    required this.variables,
    this.multiVariables = const <String>[],
  });

  Fraction? calculate(List<BigInt> vars) {
    switch (this) {
      case allMarked:
        if (vars.length != 3) {
          throw ArgumentError("This model requires 3 variables.");
        }
        final n = vars[0];
        final m = vars[1];
        final k = vars[2];
        if (k > m) {
          throw const ModelException("k can't be greater than m.");
        } else if (k > n) {
          throw const ModelException("k can't be greater than n.");
        } else if (m > n) {
          throw const ModelException("m can't be greater than n.");
        }
        final numer = Formula.combinationsNoRep.calculate([m, k]);
        final denom = Formula.combinationsNoRep.calculate([n, k]);
        return Fraction(numerator: numer, denominator: denom);
      case rMarked:
        if (vars.length != 4) {
          throw ArgumentError("This model requires 4 variables.");
        }
        final n = vars[0];
        final m = vars[1];
        final k = vars[2];
        final r = vars[3];
        if (k > m) {
          throw const ModelException("k can't be greater than m.");
        } else if (k > n) {
          throw const ModelException("k can't be greater than n.");
        } else if (m > n) {
          throw const ModelException("m can't be greater than n.");
        } else if (r > k) {
          throw const ModelException("r can't be greater than k.");
        } else if (r > n) {
          throw const ModelException("r can't be greater than n.");
        } else if (r > m) {
          throw const ModelException("r can't be greater than m.");
        }
        final cmr = Formula.combinationsNoRep.calculate([m, r]);
        final cnk = Formula.combinationsNoRep.calculate([n - m, k - r]);
        final denom = Formula.combinationsNoRep.calculate([n, k]);
        final numer = cmr * cnk;
        return Fraction(numerator: numer, denominator: denom);
    }
  }

  String texWithGivenVariables(List<BigInt> vars) {
    switch (this) {
      case allMarked:
        if (vars.length != 3) {
          throw ArgumentError("This model requires 3 variables.");
        }
        final n = vars[0];
        final m = vars[1];
        final k = vars[2];
        return tex
            .replaceAll("n", "$n")
            .replaceAll("m", "$m")
            .replaceAll("k", "$k");
      case rMarked:
        if (vars.length != 4) {
          throw ArgumentError("This model requires 4 variables.");
        }
        final n = vars[0];
        final m = vars[1];
        final k = vars[2];
        final r = vars[3];
        return "P(A)=\\frac{C^{$r}_{$m}C^{${k-r}}_{${n-m}}}{C^{$k}_{$n}}";
    }
  }
}

class ModelException implements Exception {
  const ModelException([this.message]);

  final String? message;

  @override
  String toString() {
    return "ModelException${message == null ? "" : ": $message"}";
  }
}

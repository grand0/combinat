import 'package:combinat/extensions.dart';

enum Formula {
  placementsNoRep(
    name: "Placements (no repetitions)",
    tex: r"A^{k}_{n}=\frac{n!}{(n-k)!}",
    variables: ["n", "k"],
  ),
  placementsWithRep(
    name: "Placements (with repetitions)",
    tex: r"\overline{A}^{k}_{n}=n^{k}",
    variables: ["n", "k"],
  ),
  permutationsNoRep(
    name: "Permutations (no repetitions)",
    tex: r"P_{n}=n!",
    variables: ["n"],
  ),
  permutationsWithRep(
    name: "Permutations (with repetitions)",
    tex: r"P_{n}(n_1,n_2,...,n_{k})=\frac{n!}{n_1!n_2!...n_{k}!}",
    variables: ["n"],
    multiVariables: ["n"],
  ),
  combinationsNoRep(
    name: "Combinations (no repetitions)",
    tex: r"C^{k}_{n}=\frac{n!}{k!(n-k)!}",
    variables: ["n", "k"],
  ),
  combinationsWithRep(
    name: "Combinations (with repetitions)",
    tex: r"\overline{C}^{k}_{n}=C^{k}_{n+k-1}",
    variables: ["n", "k"],
  );

  const Formula({
    required this.name,
    required this.tex,
    required this.variables,
    this.multiVariables = const <String>[],
  });

  final String name;
  final String tex;
  final List<String> variables;
  final List<String> multiVariables;

  BigInt calculate(List<BigInt> vars) {
    switch (this) {
      case placementsNoRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        if (n < k) {
          throw const FormulaException("k can't be greater than n.");
        }
        return n.fact() ~/ (n - k).fact();
      case placementsWithRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        if (n < k) {
          throw const FormulaException("k can't be greater than n.");
        }
        return n.pow(k.toInt());
      case permutationsNoRep:
        if (vars.length != 1) {
          throw ArgumentError("This enum element needs 1 variable in the list.");
        }
        final n = vars[0];
        return n.fact();
      case permutationsWithRep:
        if (vars.length < 2) {
          throw ArgumentError("This enum element needs at least 2 variables in the list.");
        }
        final n = vars[0];
        final niSum = vars.skip(1).reduce((value, element) => value + element);
        if (n != niSum) {
          throw const FormulaException("The sum of the n_i variables must equal to n.");
        }
        final denom = vars.skip(1).fold(BigInt.one, (previousValue, element) => previousValue * element.fact());
        return n.fact() ~/ denom;
      case combinationsNoRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        if (n < k) {
          throw const FormulaException("k can't be greater than n.");
        }
        return n.fact() ~/ (k.fact() * (n - k).fact());
      case combinationsWithRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        if (n < k) {
          throw const FormulaException("k can't be greater than n.");
        }
        return (n + k - BigInt.one).fact() ~/ (k.fact() * (n - BigInt.one).fact());
    }
  }

  String texWithGivenVariables(List<BigInt> vars) {
    switch (this) {
      case placementsNoRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        return tex.replaceAll("n", "$n").replaceAll("k", "$k");
      case placementsWithRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        return "\\overline{A}^{$k}_{$n}=$n^{$k}";
      case permutationsNoRep:
        if (vars.length != 1) {
          throw ArgumentError("This enum element needs 1 variable in the list.");
        }
        final n = vars[0];
        return tex.replaceAll("n", "$n");
      case permutationsWithRep:
        if (vars.length < 2) {
          throw ArgumentError("This enum element needs at least 2 variables in the list.");
        }
        final n = vars[0];
        final niCommaSep = vars.skip(1).join(",");
        final niFactMult = "${vars.skip(1).join("!")}!";
        return "P_{$n}($niCommaSep)=\\frac{$n!}{$niFactMult}";
      case combinationsNoRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        return tex.replaceAll("n", "$n").replaceAll("k", "$k");
      case combinationsWithRep:
        if (vars.length != 2) {
          throw ArgumentError("This enum element needs 2 variables in the list.");
        }
        final n = vars[0];
        final k = vars[1];
        return "\\overline{C}^{$k}_{$n}=C^{$k}_{${n+k-BigInt.one}}";
    }
  }
}

class FormulaException implements Exception {
  const FormulaException([this.message]);

  final String? message;

  @override
  String toString() {
    return "FormulaException${message == null ? "" : ": $message"}";
  }
}

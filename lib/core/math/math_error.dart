enum MathErrorKind {
  empty,
  syntax,
  parentheses,
  divideByZero,
  domain,
  overflow,
  tooLarge,
  unknownFunction,
}

class MathException implements Exception {
  const MathException(this.kind, this.message);

  final MathErrorKind kind;
  final String message;

  @override
  String toString() => message;
}

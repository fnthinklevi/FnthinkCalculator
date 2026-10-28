enum TokenType {
  number,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  power,
  factorial,
  percent,
  leftParen,
  rightParen,
  end,
}

class Token {
  const Token(this.type, this.lexeme, this.start, this.end);

  final TokenType type;
  final String lexeme;
  final int start;
  final int end;

  @override
  String toString() => '$type($lexeme)';
}

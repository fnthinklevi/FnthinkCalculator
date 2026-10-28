import 'math_error.dart';
import 'token.dart';

class Lexer {
  Lexer(this.source);

  final String source;
  int _index = 0;

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_index < source.length) {
      final char = source[_index];
      if (_isWhitespace(char)) {
        _index++;
        continue;
      }
      if (_isDigit(char) || (char == '.' && _isDigit(_peek(1)))) {
        tokens.add(_readNumber());
        continue;
      }
      if (char == 'π') {
        final start = _index;
        _index++;
        tokens.add(Token(TokenType.identifier, 'pi', start, _index));
        continue;
      }
      if (_isLetter(char)) {
        tokens.add(_readIdentifier());
        continue;
      }
      final start = _index;
      _index++;
      final type = switch (char) {
        '+' => TokenType.plus,
        '-' || '−' => TokenType.minus,
        '*' || '×' => TokenType.multiply,
        '/' || '÷' => TokenType.divide,
        '^' => TokenType.power,
        '!' => TokenType.factorial,
        '%' => TokenType.percent,
        '(' => TokenType.leftParen,
        ')' => TokenType.rightParen,
        _ => null,
      };
      if (type == null) {
        throw MathException(MathErrorKind.syntax, '无法识别字符「$char」');
      }
      tokens.add(Token(type, char, start, _index));
    }
    tokens.add(Token(TokenType.end, '', _index, _index));
    return tokens;
  }

  Token _readNumber() {
    final start = _index;
    while (_isDigit(_peek())) {
      _index++;
    }
    if (_peek() == '.') {
      _index++;
      while (_isDigit(_peek())) {
        _index++;
      }
    }
    if (_peek() == 'e' || _peek() == 'E') {
      final next = _peek(1);
      final afterSign = _peek(2);
      final hasExponent =
          _isDigit(next) ||
          ((next == '+' || next == '-') && _isDigit(afterSign));
      if (hasExponent) {
        _index++;
        if (_peek() == '+' || _peek() == '-') {
          _index++;
        }
        while (_isDigit(_peek())) {
          _index++;
        }
      }
    }
    return Token(
      TokenType.number,
      source.substring(start, _index),
      start,
      _index,
    );
  }

  Token _readIdentifier() {
    final start = _index;
    while (_isLetter(_peek())) {
      _index++;
    }
    return Token(
      TokenType.identifier,
      source.substring(start, _index).toLowerCase(),
      start,
      _index,
    );
  }

  String _peek([int offset = 0]) {
    final position = _index + offset;
    return position < source.length ? source[position] : '';
  }

  bool _isDigit(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isLetter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }
}

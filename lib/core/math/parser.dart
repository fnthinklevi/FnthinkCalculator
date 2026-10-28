import 'ast.dart';
import 'math_error.dart';
import 'rational.dart';
import 'token.dart';

class Parser {
  Parser(this.tokens);

  final List<Token> tokens;
  int _index = 0;

  static const _functions = {
    'sin',
    'cos',
    'tan',
    'asin',
    'acos',
    'atan',
    'ln',
    'log',
    'sqrt',
    'cbrt',
    'abs',
    'exp',
  };

  Expr parse() {
    if (_check(TokenType.end)) {
      throw const MathException(MathErrorKind.empty, '请输入算式');
    }
    final expression = _additive();
    if (!_check(TokenType.end)) {
      if (_check(TokenType.rightParen)) {
        throw const MathException(MathErrorKind.parentheses, '括号不匹配');
      }
      throw const MathException(MathErrorKind.syntax, '算式格式不正确');
    }
    return expression;
  }

  Expr _additive() {
    var expression = _multiplicative();
    while (_match(TokenType.plus) || _match(TokenType.minus)) {
      final op = _previous.type == TokenType.plus
          ? BinaryOp.add
          : BinaryOp.subtract;
      final right = _multiplicative();
      expression = BinaryExpr(op, expression, right);
    }
    return expression;
  }

  Expr _multiplicative() {
    var expression = _unary();
    while (_match(TokenType.multiply) || _match(TokenType.divide)) {
      final op = _previous.type == TokenType.multiply
          ? BinaryOp.multiply
          : BinaryOp.divide;
      final right = _unary();
      expression = BinaryExpr(op, expression, right);
    }
    return expression;
  }

  Expr _unary() {
    if (_match(TokenType.plus)) {
      return UnaryExpr(UnaryOp.plus, _unary());
    }
    if (_match(TokenType.minus)) {
      return UnaryExpr(UnaryOp.minus, _unary());
    }
    return _power();
  }

  Expr _power() {
    final left = _postfix();
    if (_match(TokenType.power)) {
      final right = _unary();
      return BinaryExpr(BinaryOp.power, left, right);
    }
    return left;
  }

  Expr _postfix() {
    var expression = _primary();
    while (_match(TokenType.factorial) || _match(TokenType.percent)) {
      final op = _previous.type == TokenType.factorial
          ? PostfixOp.factorial
          : PostfixOp.percent;
      expression = PostfixExpr(op, expression);
    }
    return expression;
  }

  Expr _primary() {
    if (_match(TokenType.number)) {
      final value = BigRational.parse(_previous.lexeme);
      return NumberExpr(value);
    }
    if (_match(TokenType.identifier)) {
      final name = _previous.lexeme;
      if (name == 'pi' || name == 'e') {
        return ConstantExpr(name);
      }
      if (_functions.contains(name)) {
        if (!_match(TokenType.leftParen)) {
          throw const MathException(MathErrorKind.syntax, '函数缺少括号');
        }
        final argument = _additive();
        if (!_match(TokenType.rightParen)) {
          throw const MathException(MathErrorKind.parentheses, '括号不匹配');
        }
        return FunctionExpr(name, argument);
      }
      throw MathException(MathErrorKind.unknownFunction, '未知函数「$name」');
    }
    if (_match(TokenType.leftParen)) {
      final expression = _additive();
      if (!_match(TokenType.rightParen)) {
        throw const MathException(MathErrorKind.parentheses, '括号不匹配');
      }
      return expression;
    }
    if (_check(TokenType.rightParen)) {
      throw const MathException(MathErrorKind.parentheses, '括号不匹配');
    }
    throw const MathException(MathErrorKind.syntax, '算式格式不正确');
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _check(TokenType type) => _current.type == type;

  Token _advance() {
    final token = _current;
    if (!_check(TokenType.end)) {
      _index++;
    }
    return token;
  }

  Token get _current => tokens[_index];

  Token get _previous => tokens[_index - 1];
}

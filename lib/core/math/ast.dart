import 'rational.dart';

sealed class Expr {
  const Expr();
}

class NumberExpr extends Expr {
  const NumberExpr(this.value);

  final BigRational value;
}

class ConstantExpr extends Expr {
  const ConstantExpr(this.name);

  final String name;
}

enum UnaryOp { plus, minus }

class UnaryExpr extends Expr {
  const UnaryExpr(this.op, this.operand);

  final UnaryOp op;
  final Expr operand;
}

enum BinaryOp { add, subtract, multiply, divide, power }

class BinaryExpr extends Expr {
  const BinaryExpr(this.op, this.left, this.right);

  final BinaryOp op;
  final Expr left;
  final Expr right;
}

enum PostfixOp { factorial, percent }

class PostfixExpr extends Expr {
  const PostfixExpr(this.op, this.operand);

  final PostfixOp op;
  final Expr operand;
}

class FunctionExpr extends Expr {
  const FunctionExpr(this.name, this.argument);

  final String name;
  final Expr argument;
}

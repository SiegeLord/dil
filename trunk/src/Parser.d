/++
  Author: Aziz Köksal
  License: GPL2
+/
module Parser;
import Lexer;
import Token;
import Messages;
import Information;
import Expressions;

enum STC
{
  Abstract,
  Auto,
  Const,
  Deprecated,
  Extern,
  Final,
  Invariant,
  Override,
  Scope,
  Static,
  Synchronized
}

private alias TOK T;

class Parser
{
  Lexer lx;
  TOK delegate() nT;

  Information[] errors;

  this(char[] srcText, string fileName)
  {
    lx = new Lexer(srcText, fileName);
    nT = &lx.nextToken;
  }

  Expression parseExpression()
  {
    auto e = parseAssignExpression();
    while (lx.token.type == TOK.Comma)
      e = new CommaExpression(e, parseExpression());
    return e;
  }

  Expression parseAssignExpression()
  {
    auto e = parseCondExpression();
    while (1)
    {
      switch (lx.token.type)
      {
      case T.Assign:
        nT(); e = new AssignExpression(e, parseAssignExpression());
        break;
      case T.LShiftAssign:
        nT(); e = new LShiftAssignExpression(e, parseAssignExpression());
        break;
      case T.RShiftAssign:
        nT(); e = new RShiftAssignExpression(e, parseAssignExpression());
        break;
      case T.URShiftAssign:
        nT(); e = new URShiftAssignExpression(e, parseAssignExpression());
        break;
      case T.OrAssign:
        nT(); e = new OrAssignExpression(e, parseAssignExpression());
        break;
      case T.AndAssign:
        nT(); e = new AndAssignExpression(e, parseAssignExpression());
        break;
      case T.PlusAssign:
        nT(); e = new PlusAssignExpression(e, parseAssignExpression());
        break;
      case T.MinusAssign:
        nT(); e = new MinusAssignExpression(e, parseAssignExpression());
        break;
      case T.DivAssign:
        nT(); e = new DivAssignExpression(e, parseAssignExpression());
        break;
      case T.MulAssign:
        nT(); e = new MulAssignExpression(e, parseAssignExpression());
        break;
      case T.ModAssign:
        nT(); e = new ModAssignExpression(e, parseAssignExpression());
        break;
      case T.XorAssign:
        nT(); e = new XorAssignExpression(e, parseAssignExpression());
        break;
      case T.CatAssign:
        nT(); e = new CatAssignExpression(e, parseAssignExpression());
        break;
      default:
        break;
      }
      break;
    }
    return e;
  }

  Expression parseCondExpression()
  {
    auto e = parseOrOrExpression();
    if (lx.token.type == TOK.Question)
    {
      nT();
      auto iftrue = parseExpression();
//       if (lx.toke.type != TOK.Colon)
//         error();
      auto iffalse = parseCondExpression();
      e = new CondExpression(e, iftrue, iffalse);
    }
    return e;
  }

  Expression parseOrOrExpression()
  {
    return new Expression();
  }

  void error(MID id, ...)
  {
    errors ~= new Information(Information.Type.Parser, id, lx.loc, arguments(_arguments, _argptr));
  }
}

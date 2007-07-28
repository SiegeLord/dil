/++
  Author: Aziz Köksal
  License: GPL2
+/
module Statements;
import Expressions;
import Declarations;
import Types;
import Token;

class Statement
{

}

class Statements : Statement
{
  Statement[] ss;
  void opCatAssign(Statement s)
  {
    this.ss ~= s;
  }
}

class IllegalStatement : Statement
{
  TOK tok;
  this(TOK tok)
  {
    this.tok = tok;
  }
}

class EmptyStatement : Statement
{
  this()
  {
  }
}

class FunctionBody
{
  Statement funcBody, inBody, outBody;
  string outIdent;
}

class ScopeStatement : Statement
{
  Statement s;
  this(Statement s)
  {
    this.s = s;
  }
}

class LabeledStatement : Statement
{
  string label;
  Statement s;
  this(string label, Statement s)
  {
    this.label = label;
    this.s = s;
  }
}

class ExpressionStatement : Statement
{
  Expression expression;
  this(Expression expression)
  {
    this.expression = expression;
  }
}

class DeclarationStatement : Statement
{
  Declaration declaration;
  this(Declaration declaration)
  {
    this.declaration = declaration;
  }
}

class IfStatement : Statement
{
  Type type;
  string ident;
  Expression condition;
  Statement ifBody;
  Statement elseBody;
  this(Type type, string ident, Expression condition, Statement ifBody, Statement elseBody)
  {
    this.type = type;
    this.ident = ident;
    this.condition = condition;
    this.ifBody = ifBody;
    this.elseBody = elseBody;
  }
}

class ConditionalStatement : Statement
{

}

class WhileStatement : Statement
{
  Expression condition;
  Statement whileBody;
  this(Expression condition, Statement whileBody)
  {
    this.condition = condition;
    this.whileBody = whileBody;
  }
}

class DoWhileStatement : Statement
{
  Expression condition;
  Statement doBody;
  this(Expression condition, Statement doBody)
  {
    this.condition = condition;
    this.doBody = doBody;
  }
}

class ForStatement : Statement
{
  Statement init;
  Expression condition, increment;
  Statement forBody;

  this(Statement init, Expression condition, Expression increment, Statement forBody)
  {
    this.init = init;
    this.condition = condition;
    this.increment = increment;
    this.forBody = forBody;
  }
}

class ForeachStatement : Statement
{
  TOK tok;
  Parameters params;
  Expression aggregate;
  Statement forBody;

  this(TOK tok, Parameters params, Expression aggregate, Statement forBody)
  {
    this.tok = tok;
    this.params = params;
    this.aggregate = aggregate;
    this.forBody = forBody;
  }
}

class SwitchStatement : Statement
{
  Expression condition;
  Statement switchBody;

  this(Expression condition, Statement switchBody)
  {
    this.condition = condition;
    this.switchBody = switchBody;
  }
}

class CaseStatement : Statement
{
  Expression[] values;
  Statement caseBody;

  this(Expression[] values, Statement caseBody)
  {
    this.values = values;
    this.caseBody = caseBody;
  }
}

class DefaultStatement : Statement
{
  Statement defaultBody;
  this(Statement defaultBody)
  {
    this.defaultBody = defaultBody;
  }
}

class ContinueStatement : Statement
{
  string ident;
  this(string ident)
  {
    this.ident = ident;
  }
}

class BreakStatement : Statement
{
  string ident;
  this(string ident)
  {
    this.ident = ident;
  }
}

class ReturnStatement : Statement
{
  Expression expr;
  this(Expression expr)
  {
    this.expr = expr;
  }
}

class GotoStatement : Statement
{
  string ident;
  Expression caseExpr;
  this(string ident, Expression caseExpr)
  {
    this.ident = ident;
    this.caseExpr = caseExpr;
  }
}

class WithStatement : Statement
{
  Expression expr;
  Statement withBody;
  this(Expression expr, Statement withBody)
  {
    this.expr = expr;
    this.withBody = withBody;
  }
}

class SynchronizedStatement : Statement
{
  Expression expr;
  Statement syncBody;
  this(Expression expr, Statement withBody)
  {
    this.expr = expr;
    this.syncBody = syncBody;
  }
}

class TryStatement : Statement
{
  Statement tryBody;
  CatchBody[] catchBodies;
  FinallyBody finallyBody;
  this(Statement tryBody, CatchBody[] catchBodies, FinallyBody finallyBody)
  {
    this.tryBody = tryBody;
    this.catchBodies = catchBodies;
    this.finallyBody = finallyBody;
  }
}

class CatchBody : Statement
{
  Parameter param;
  Statement catchBody;
  this(Parameter param, Statement catchBody)
  {
    this.param = param;
    this.catchBody = catchBody;
  }
}

class FinallyBody : Statement
{
  Statement finallyBody;
  this(Statement finallyBody)
  {
    this.finallyBody = finallyBody;
  }
}

class ScopeGuardStatement : Statement
{
  string condition;
  Statement scopeBody;
  this(string condition, Statement scopeBody)
  {
    this.condition = condition;
    this.scopeBody = scopeBody;
  }
}

class ThrowStatement : Statement
{
  Expression expr;
  this(Expression expr)
  {
    this.expr = expr;
  }
}

class VolatileStatement : Statement
{
  Statement volatileBody;
  this(Statement volatileBody)
  {
    this.volatileBody = volatileBody;
  }
}

class AsmStatement : Statement
{

}

class PragmaStatement : Statement
{
  string ident;
  Expression[] args;
  Statement pragmaBody;
  this(string ident, Expression[] args, Statement pragmaBody)
  {
    this.ident = ident;
    this.args = args;
    this.pragmaBody = pragmaBody;
  }
}

class MixinStatement : Statement
{
  Declaration decl;
  this(Declaration decl)
  {
    this.decl = decl;
  }
}

class StaticIfStatement : Statement
{
  Expression condition;
  Statement ifBody, elseBody;
  this(Expression condition, Statement ifBody, Statement elseBody)
  {
    this.condition = condition;
    this.ifBody = ifBody;
    this.elseBody = elseBody;
  }
}

class StaticAssertStatement : Statement
{
  Expression condition, message;
  this(Expression condition, Expression message)
  {
    this.condition = condition;
    this.message = message;
  }
}

class DebugStatement : Statement
{
  int levelCond;
  string identCond;
  Statement debugBody, elseBody;
  this(int levelCond, string identCond, Statement debugBody, Statement elseBody)
  {
    this.levelCond = levelCond;
    this.identCond = identCond;
    this.debugBody = debugBody;
    this.elseBody = elseBody;
  }
}

class VersionStatement : Statement
{
  int levelCond;
  string identCond;
  Statement versionBody, elseBody;
  this(int levelCond, string identCond, Statement versionBody, Statement elseBody)
  {
    this.levelCond = levelCond;
    this.identCond = identCond;
    this.versionBody = versionBody;
    this.elseBody = elseBody;
  }
}

class AttributeStatement : Statement
{
  TOK tok;
  Statement statement;
  this(TOK tok, Statement statement)
  {
    this.tok = tok;
    this.statement = statement;
  }
}

class ExternStatement : AttributeStatement
{
  Linkage linkage;
  this(Linkage linkage, Statement statement)
  {
    super(TOK.Extern, statement);
    this.linkage = linkage;
  }
}

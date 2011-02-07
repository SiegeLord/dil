/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity low)
module dil.code.Methods;

import dil.ast.Node,
       dil.ast.Expressions;
import dil.semantic.Types;
import dil.code.NotAResult;
import dil.Float,
       dil.Complex,
       dil.Diagnostics,
       dil.Messages;
import common;

/// A collection of methods that operate on Expression nodes.
class EMethods
{
  Diagnostics diag; /// For error messages.

  alias NodeKind NK;

  /// Constructs an EMethods object.
  this(Diagnostics diag = null)
  {
    this.diag = diag;
  }

  /// Issues an error.
  void error(Node n, string msg, ...)
  {
    auto location = n.begin.getErrorLocation(/+filePath+/""); // FIXME
    msg = Format(_arguments, _argptr, msg);
    auto error = new SemanticError(location, msg);
    if (diag !is null)
      diag ~= error;
  }

  /// Converts the expression to an integer. Reports an error if impossible.
  long toInt(Expression e)
  {
    long i;
    switch (e.kind)
    {
    // TODO:
    case NK.IntExpression:
      break;
    default:
      //error("expected integer constant, not ‘{}’", e.toText());
    }
    return i;
  }

  /// ditto
  ulong toUInt(Expression e)
  {
    return cast(ulong)toInt(e);
  }

  /// Reports an error.
  void errorExpectedIntOrFloat(Expression e)
  {
    error(e, "expected integer or float constant, not ‘{}’", e.toText());
  }

  /// Returns Im(e).
  Float toImag(Expression e)
  {
    Float r;
    switch (e.kind)
    {
    case NK.ComplexExpression:
      r = e.to!(ComplexExpression).number.im; break;
    case NK.FloatExpression:
      auto fe = e.to!(FloatExpression);
      if (fe.type.flagsOf().isImaginary())
        r = fe.number;
      else
        r = Float();
      break;
    case NK.IntExpression:
      r = Float();
      break;
    default:
      errorExpectedIntOrFloat(e);
    }
    return r;
  }

  /// Returns Re(e).
  Float toReal(Expression e)
  {
    Float r;
    switch (e.kind)
    {
    case NK.ComplexExpression:
      r = e.to!(ComplexExpression).number.re; break;
    case NK.FloatExpression:
      auto fe = e.to!(FloatExpression);
      if (fe.type.flagsOf().isReal())
        r = fe.number;
      else
        r = Float();
      break;
    case NK.IntExpression:
      auto ie = e.to!(IntExpression);
      if (ie.type.flagsOf().isSigned())
        r = Float(cast(long)ie.number);
      else
        r = Float(ie.number);
      break;
    default:
      errorExpectedIntOrFloat(e);
    }
    return r;
  }

  /// Returns Re(e) + Im(e).
  Complex toComplex(Expression e)
  {
    Complex z;
    switch (e.kind)
    {
    case NK.ComplexExpression:
      z = e.to!(ComplexExpression).number; break;
    case NK.FloatExpression:
      auto fe = e.to!(FloatExpression);
      Float re, im;
      if (fe.type.flagsOf().isReal())
        re = fe.number;
      else
        im = fe.number;
      z = Complex(re, im);
      break;
    case NK.IntExpression:
      z = Complex(toReal(e)); break;
    default:
      errorExpectedIntOrFloat(e);
    }
    return z;
  }

  /// Checks if e has a boolean value.
  /// Returns: -1 if not a bool, 0 if the value is false and 1 if true.
  static int isBool(Expression e)
  {
    int r = void;
  Lagain:
    switch (e.kind)
    {
    case NK.IntExpression:
      auto num = e.to!(IntExpression).number;
      r = num != 0; break;
    case NK.FloatExpression:
      auto num = e.to!(FloatExpression).number;
      r = num != 0; break;
    case NK.ComplexExpression:
      auto num = e.to!(ComplexExpression).number;
      r = num != 0L; break;
    case NK.CharExpression:
      auto num = e.to!(CharExpression).value.number;
      r = num != 0; break;
    case NK.BoolExpression:
      auto num = e.to!(BoolExpression).value.number;
      r = num != 0; break;
    case NK.CommaExpression:
      e = e.to!(CommaExpression).rhs; goto Lagain;
    case NK.ArrayLiteralExpression:
      r = e.to!(ArrayLiteralExpression).values.length != 0; break;
    case NK.AArrayLiteralExpression:
      r = e.to!(AArrayLiteralExpression).values.length != 0; break;
    case NK.StringExpression:
      r = 1; break;
    case NK.NullExpression:
      r = 0; break;
    default:
      r = -1; // It has no boolean value.
    }
    return r;
  }

  /// Returns true if e has a boolean value and if it is true.
  static bool isTrue(Expression e)
  {
    return isBool(e) == 1;
  }

  /// Returns true if e has a boolean value and if it is false.
  static bool isFalse(Expression e)
  {
    return isBool(e) == 0;
  }

  /// Returns a boolean IntExpression if e has a boolean value, otherwise NAR.
  static Expression toBool(Expression e)
  {
    auto boolval = isBool(e);
    Expression r = NAR;
    if (boolval != -1)
    {
      r = new IntExpression(boolval, Types.Bool);
      r.setLoc(e);
    }
    return r;
  }

  /// Returns the Float value of e.
  Float toRealOrImag(Expression e)
  {
    return e.type.flagsOf().isReal() ? toReal(e) : toImag(e);
  }

  /// Returns the length of a string/array/assocarray.
  static Expression arrayLength(Expression e)
  {
    size_t len;
    if (auto se = e.Is!(StringExpression))
      len = se.length();
    else if (auto ae = e.Is!(ArrayLiteralExpression))
      len = ae.values.length;
    else if (auto aae = e.Is!(AArrayLiteralExpression))
      len = aae.keys.length;
    else
      return NAR;
    auto r = new IntExpression(len, e.type);
    r.setLoc(e);
    return r;
  }
}

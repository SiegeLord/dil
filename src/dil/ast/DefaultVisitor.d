/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity very high)
module dil.ast.DefaultVisitor;

import dil.ast.Visitor,
       dil.ast.NodeMembers,
       dil.ast.Node,
       dil.ast.Declarations,
       dil.ast.Expressions,
       dil.ast.Statements,
       dil.ast.Types,
       dil.ast.Parameters;
import common;

/// Generates the actual code for visiting a node's members.
private char[] createCode(NodeKind nodeKind)
{
  // Look up members for this kind of node in the table.
  auto members = NodeMembersTable[nodeKind];
  // members = e.g.: ["condition", "ifDecls", "elseDecls?"]
  if (members.length == 0)
    return null;

  string[2][] list = parseMembers(members);
  char[] code;
  foreach (m; list)
  {
    auto name = m[0], type = m[1];
    switch (type)
    {
    case "": // Visit node.
      code ~= "visitN(n."~name~");\n"; // visitN(n.member);
      break;
    case "?": // Visit node, may be null.
      // n.member && visitN(n.member);
      code ~= "n."~name~" && visitN(n."~name~");\n";
      break;
    case "[]": // Visit nodes in the array.
      code ~= "foreach (x; n."~name~")\n" // foreach (x; n.member)
              "  visitN(x);\n";           //   visitN(x);
      break;
    case "[?]": // Visit nodes in the array, items may be null.
      code ~= "foreach (x; n."~name~")\n" // foreach (x; n.member)
              "  x && visitN(x);\n";      //   x && visitN(x);
      break;
    case "%": // Copy code verbatim.
      code ~= name ~ "\n";
      break;
    default:
      assert(0, "unknown member type.");
    }
  }
  return code;
}

/// Generates the default visit methods.
///
/// E.g.:
/// ---
/// override returnType!(ClassDecl) visit(ClassDecl n)
/// { /* Code that visits the subnodes... */ return n; }
/// ---
char[] generateDefaultVisitMethods()
{
  char[] code;
  foreach (i, className; NodeClassNames)
    code ~= "override returnType!("~className~") visit("~className~" n)"
            "{"
            "  "~createCode(cast(NodeKind)i)~
            "  return n;"
            "}\n";
  return code;
}
// pragma(msg, generateDefaultVisitMethods());

/// Same as above but returns void.
char[] generateDefaultVisitMethods2()
{
  char[] code;
  foreach (i, className; NodeClassNames)
    code ~= "override void visit("~className~" n)"
            "{"
            "  "~createCode(cast(NodeKind)i)~
            "}\n";
  return code;
}


/// This class provides default methods for
/// traversing nodes and their subnodes.
class DefaultVisitor : Visitor
{
  // Comment out if too many errors are shown.
  mixin(generateDefaultVisitMethods());
}

/// This class provides default methods for
/// traversing nodes and their subnodes.
class DefaultVisitor2 : Visitor2
{
  // Comment out if too many errors are shown.
  mixin(generateDefaultVisitMethods2());
}

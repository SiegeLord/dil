/++
  Author: Aziz Köksal
  License: GPL3
+/
module dil.lexer.IdentsGenerator;

/// Table of predefined identifiers.
///
/// The format ('#' start comments):
///<pre>
///  PredefinedIdentifier := SourceCodeName (":" IdText)?
///  SourceCodeName := Identifier # The name to be used in the source code.
///  IdText := "" | Identifier # The actual text of the identifier.
///  Identifier := see module dil.lexer.Identifier
///</pre>
/// If IdText is not defined SourceCodeName will be used.
private static const char[][] predefIdents = [
  // Special empty identifier:
  "Empty:",
  // Predefined version identifiers:
  "DigitalMars", "X86", "X86_64",
  /*"Windows", */"Win32", "Win64",
  "Linux:linux", "LittleEndian", "BigEndian",
  "D_Coverage", "D_InlineAsm_X86", "D_Version2",
  "none", "all",
  // Variadic parameters:
  "Arguments:_arguments", "Argptr:_argptr",
  // scope(Identifier):
  "exit", "success", "failure",
  // pragma:
  "msg", "lib", "startaddress",
  // Linkage:
  "C", "D", "Windows", "Pascal", "System",
  // Con-/Destructor:
  "Ctor:__ctor", "Dtor:__dtor",
  // new() and delete() methods.
  "New:__new", "Delete:__delete",
  // Unittest and invariant.
  "Unittest:__unittest", "Invariant:__invariant",
  // Operator methods:
  "opNeg",
  "opPos",
  "opComp",
  "opAddAssign",
  "opSubAssign",
  "opPostInc",
  "opPostDec",
  "opCall",
  "opCast",
  "opIndex",
  "opSlice",
  "opStar", // D2
  // Entry function:
  "main",
  // ASM identifiers:
  "near", "far", "word", "dword", "qword",
  "ptr", "offset", "seg", "__LOCAL_SIZE",
  "FS", "ST",
  "AL", "AH", "AX", "EAX",
  "BL", "BH", "BX", "EBX",
  "CL", "CH", "CX", "ECX",
  "DL", "DH", "DX", "EDX",
  "BP", "EBP", "SP", "ESP",
  "DI", "EDI", "SI", "ESI",
  "ES", "CS", "SS", "DS", "GS",
  "CR0", "CR2", "CR3", "CR4",
  "DR0", "DR1", "DR2", "DR3", "DR6", "DR7",
  "TR3", "TR4", "TR5", "TR6", "TR7",
  "MM0", "MM1", "MM2", "MM3",
  "MM4", "MM5", "MM6", "MM7",
  "XMM0", "XMM1", "XMM2", "XMM3",
  "XMM4", "XMM5", "XMM6", "XMM7",
];

char[][] getPair(char[] idText)
{
  foreach (i, c; idText)
    if (c == ':')
      return [idText[0..i], idText[i+1..idText.length]];
  return [idText, idText];
}

unittest
{
  static assert(
    getPair("test") == ["test", "test"] &&
    getPair("test:tset") == ["test", "tset"] &&
    getPair("empty:") == ["empty", ""]
  );
}

/++
 CTF for generating the members of the struct Ident.

 The resulting string looks similar to this:
 ---
  private struct Ids {static const:
    Identifier _name1 = {"name1", TOK.Identifier, IDK.name1};
    Identifier _name2 = {"name2", TOK.Identifier, IDK.name2};
    // etc.
  }
  Identifier* name1 = &Ids._name1;
  Identifier* name2 = &Ids._name2;
  // etc.
  private Identifier*[] __allIds = [
    name1,
    name2,
    // etc.
  ]
 ---
+/
char[] generateIdentMembers()
{
  char[] private_members = "private struct Ids {static const:";
  char[] public_members = "";
  char[] array = "private Identifier*[] __allIds = [";

  foreach (ident; predefIdents)
  {
    char[][] pair = getPair(ident);
    // Identifier _name = {"name", TOK.Identifier, ID.name};
    private_members ~= "Identifier _"~pair[0]~` = {"`~pair[1]~`", TOK.Identifier, IDK.`~pair[0]~"};\n";
    // Identifier* name = &_name;
    public_members ~= "Identifier* "~pair[0]~" = &Ids._"~pair[0]~";\n";
    array ~= pair[0]~",";
  }

  private_members ~= "}"; // Close private {
  array ~= "];";

  return private_members ~ public_members ~ array;
}

/// CTF for generating the members of the enum IDK.
char[] generateIDMembers()
{
  char[] members;
  foreach (ident; predefIdents)
    members ~= getPair(ident)[0] ~ ",\n";
  return members;
}

// pragma(msg, generateIdentMembers());
// pragma(msg, generateIDMembers());

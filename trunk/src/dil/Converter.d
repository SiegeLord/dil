/++
  Author: Aziz Köksal
  License: GPL3
+/
module dil.Converter;

import dil.Information;
import dil.Location;
import dil.Unicode;
import dil.FileBOM;
import dil.LexerFuncs;
import dil.Messages;
import common;

/// Converts various Unicode encoding formats to UTF-8.
struct Converter
{
  char[] filePath; /// For error messages.
  InfoManager infoMan;

  static Converter opCall(char[] filePath, InfoManager infoMan)
  {
    Converter conv;
    conv.filePath = filePath;
    conv.infoMan = infoMan;
    return conv;
  }

  dchar swapBytes(dchar c)
  {
    return c = (c << 24) |
              ((c >> 8) & 0xFF00) |
              ((c << 8) & 0xFF0000) |
              (c >> 24);
  }

  wchar swapBytes(wchar c)
  {
    return (c << 8) | (c >> 8);
  }

  wchar BEtoMachineDword(dchar c)
  {
    version(LittleEndian)
      return swapBytes(c);
    else
      return c;
  }

  wchar LEtoMachineDword(dchar c)
  {
    version(LittleEndian)
      return c;
    else
      return swapBytes(c);
  }

  wchar BEtoMachineWord(wchar c)
  {
    version(LittleEndian)
      return swapBytes(c);
    else
      return c;
  }

  wchar LEtoMachineWord(wchar c)
  {
    version(LittleEndian)
      return c;
    else
      return swapBytes(c);
  }

  char[] UTF32toUTF8(bool isBigEndian)(ubyte[] data)
  {
    if (data.length == 0)
      return null;

    char[] result;
    uint lineNum = 1;
    dchar[] text = cast(dchar[]) data[0 .. $-($%4)]; // Trim to multiple of 4.
    foreach (dchar c; text)
    {
      static if (isBigEndian)
        c = BEtoMachineDword(c);
      else
        c = LEtoMachineDword(c);

      if (!isValidChar(c))
      {
        infoMan ~= new LexerError(
          new Location(filePath, lineNum),
          Format(MSG.InvalidUTF32Character, c)
        );
        c = REPLACEMENT_CHAR;
      }

      if (isNewline(c))
        ++lineNum;
      dil.Unicode.encode(result, c);
    }

    if (data.length % 4)
      infoMan ~= new LexerError(
        new Location(filePath, lineNum),
        MSG.UTF32FileMustBeDivisibleBy4
      );

    return result;
  }

  alias UTF32toUTF8!(true) UTF32BEtoUTF8;
  alias UTF32toUTF8!(false) UTF32LEtoUTF8;

  char[] UTF16toUTF8(bool isBigEndian)(ubyte[] data)
  {
    if (data.length == 0)
      return null;

    wchar[] text = cast(wchar[]) data[0 .. $-($%2)]; // Trim to multiple of two.
    wchar* p = text.ptr,
         end = text.ptr + text.length;
    char[] result;
    uint lineNum = 1;
    dchar c = *p;

    do
    {
      static if (isBigEndian)
        c = BEtoMachineWord(c);
      else
        c = LEtoMachineWord(c);

      if (c < 0xD800 || 0xDFFF > c)
      {}
      else if (c <= 0xDBFF && p+1 < end)
      {
        wchar c2 = p[1];
        static if (isBigEndian)
          c2 = BEtoMachineWord(c2);
        else
          c2 = LEtoMachineWord(c2);

        if (0xDC00 <= c2 && c2 <= 0xDFFF)
        {
          c = (c - 0xD7C0) << 10;
          c |= (c2 & 0x3FF);
          ++p;
        }
      }
      else
      {
        infoMan ~= new LexerError(
          new Location(filePath, lineNum),
          Format(MSG.InvalidUTF16Character, c)
        );
        c = REPLACEMENT_CHAR;
      }

      if (isNewline(c))
        ++lineNum;
      ++p;
      dil.Unicode.encode(result, c);
    } while (p < end)

    if (data.length % 2)
      infoMan ~= new LexerError(
        new Location(filePath, lineNum),
        MSG.UTF16FileMustBeDivisibleBy2
      );

    return result;
  }

  alias UTF16toUTF8!(true) UTF16BEtoUTF8;
  alias UTF16toUTF8!(false) UTF16LEtoUTF8;

  char[] data2UTF8(ubyte[] data)
  {
    if (data.length == 0)
      return null;

    char[] text;
    BOM bom = tellBOM(data);

    switch (bom)
    {
    case BOM.None:
      // No BOM found. According to the specs the first character
      // must be an ASCII character.
      if (data.length >= 4)
      {
        if (data[0..3] == cast(ubyte[3])x"00 00 00")
        {
          text = UTF32BEtoUTF8(data); // UTF-32BE: 00 00 00 XX
          break;
        }
        else if (data[1..4] == cast(ubyte[3])x"00 00 00")
        {
          text = UTF32LEtoUTF8(data); // UTF-32LE: XX 00 00 00
          break;
        }
      }
      if (data.length >= 2)
      {
        if (data[0] == 0) // UTF-16BE: 00 XX
        {
          text = UTF16BEtoUTF8(data);
          break;
        }
        else if (data[1] == 0) // UTF-16LE: XX 00
        {
          text = UTF16LEtoUTF8(data);
          break;
        }
      }
      text = cast(char[])data; // UTF-8
      break;
    case BOM.UTF8:
      text = cast(char[])data[3..$];
      break;
    case BOM.UTF16BE:
      text = UTF16BEtoUTF8(data[2..$]);
      break;
    case BOM.UTF16LE:
      text = UTF16LEtoUTF8(data[2..$]);
      break;
    case BOM.UTF32BE:
      text = UTF32BEtoUTF8(data[4..$]);
      break;
    case BOM.UTF32LE:
      text = UTF32LEtoUTF8(data[4..$]);
      break;
    default:
      assert(0);
    }
    return text;
  }
}
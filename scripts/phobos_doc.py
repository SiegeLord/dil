#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Aziz Köksal
import os, re
from sys import argv
from path import Path
from common import *

def modify_std_ddoc(std_ddoc, phobos_ddoc, version):
  """ Modify std.ddoc and write it out to phobos.ddoc. """
  ddoc = open(std_ddoc).read() # Read the whole file.
  # Add a website icon.
  ddoc = re.sub(r"</head>", '<link rel="icon" type="image/gif" href="./holy.gif">\r\n</head>', ddoc)
  # Make "../" to "./".
  ddoc = re.sub(r"\.\./(style.css|dmlogo.gif)", r"./\1", ddoc)
  # Make some relative paths to absolute ones.
  ddoc = ddoc.replace("../", "http://www.digitalmars.com/d/%s/" % version)
  # Replace with a DDoc macro.
  ddoc = re.sub("Page generated by.+", "$(GENERATED_BY)", ddoc)
  # Replace phobos.html#xyz.
  # ddoc = re.sub("href=\"phobos.html#(std_[^\"]+)\"", "href=\"\\1.html\"", ddoc)
  # Make e.g. "std_string.html" to "std.string.html".
  ddoc = re.sub('href="std_.+?"', lambda m: m.group(0).replace("_", "."), ddoc)
  # Linkify the title.
  ddoc = re.sub("<h1>\$\(TITLE\)</h1>", '<h1><a href="$(SRCFILE)">$(TITLE)</a></h1>', ddoc)
  # Add a link to the index in the navigation sidebar.
  ddoc = re.sub('(NAVIGATION_PHOBOS=\r\n<div class="navblock">)', '\\1\r\n$(UL\r\n$(LI<a href="index.html" title="Index of all HTML files">Index</a>)\r\n)', ddoc)
  # Write new ddoc file.
  open(phobos_ddoc, "w").write(ddoc)

# Create an index file.
def create_index_file(index_d, prefix_path, FILES):
  text = ""
  for filepath in FILES:
    fqn = get_module_fqn(prefix_path, filepath)
    text += '  <li><a href="%(fqn)s.html">%(fqn)s.html</a></li>\n' % {'fqn':fqn}
  text = "Ddoc\n<ul>\n%s\n</ul>\nMacros:\nTITLE = Index" % text
  open(index_d, 'w').write(text)

def copy_files(DATA, PHOBOS_SRC, HTML_SRC, DEST):
  """ Copies required files to the destination folder. """
  PHOBOS_HTML = PHOBOS_SRC/".."/".."/"html"/"d"/"phobos"
  for file in ["erfc.gif", "erf.gif"] + Path("..")//("style.css", "holy.gif", "dmlogo.gif"):
    (PHOBOS_HTML/file).copy(DEST)
  # Syntax highlighted files need html.css.
  (DATA/"html.css").copy(HTML_SRC)

def modify_phobos_html(phobos_html, version):
  """ Modifys DEST/phobos.html. """
  ddoc = open(phobos_html).read() # Read the whole file.
  # Make relative links to absolute links.
  ddoc = ddoc.replace("../", "http://www.digitalmars.com/d/%s/" % version)
  # Make e.g. "std_string.html" to "std.string.html".
  ddoc = re.sub("href=\"std_[^\"]+\"", lambda m: m.group(0).replace("_", "."), ddoc)
  # De-linkify the title.
  ddoc = re.sub("<h1><a[^>]+>(.+?)</a></h1>", "<h1>\\1</h1>", ddoc)
  # Write the contents back to the file.
  open(phobos_html, "w").write(ddoc)

def write_overrides_ddoc(path):
  open(path, "w").write("""
GENERATED_BY = Page generated by $(LINK2 http://code.google.com/p/dil, dil) on $(DATETIME)
SRCFILE = ./htmlsrc/$(DIL_MODFQN).html
DIL_SYMBOL = <a href="$(SRCFILE)#L$3" name="$2" title="At line $3.">$1</a>

WIKI =
COMMENT = <!-- -->
DOLLAR = $
_PI = &pi;
POW = $1<sup>$2</sup>
TABLE_DOMRG = $(TABLE_SV $0)
std_boilerplate = <!-- undefined macro in std/outbuffer.d -->
DOMAIN = <!-- undefined macro in std/math.d -->
RANGE = <!-- undefined macro in std/math.d -->"""
  )


def main():
  from sys import argv
  if len(argv) <= 1:
    print "Usage: scripts/phobos_doc.py /home/user/phobos/ [phobosdoc/]"
    return

  # Path to the executable of dil.
  DIL_EXE   = Path("bin")/"dil"
  D_VERSION  = "1.0" # TODO: Needs to be determined dynamically.
  # The source code folder of Phobos.
  PHOBOS_SRC = Path(argv[1])
  # Destination of doc files.
  DEST       = Path(argv[2] if len(argv) > 2 else 'phobosdoc')
  # Destination of syntax highlighted source files.
  HTML_SRC   = DEST/"htmlsrc"
  # Dil's data/ directory.
  DATA       = Path('data')
  # Temporary directory, deleted in the end.
  TMP        = DEST/"tmp"
  # The list of module files (with info) that have been processed.
  MODLIST    = TMP/"modules.txt"
  # List of files to ignore.
  IGNORE_LIST = ("phobos.d", "cast.d", "invariant.d", "switch.d", "unittest.d")
  # The files to generate documentation for.
  FILES       = []

  if not PHOBOS_SRC.exists:
    print "The path '%s' doesn't exist." % PHOBOS_SRC
    return

  build_dil_if_inexistant(DIL_EXE)

  # Create the destination folders.
  DEST.makedirs()
  map(Path.mkdir, (HTML_SRC, TMP))

  # Begin processing.
  find_source_files(PHOBOS_SRC, FILES)
  # Filter out files in the internal/ folder and in the ignore list.
  FILES = [f for f in FILES if not any(map(f.endswith, IGNORE_LIST)) and \
                               not f.startswith(PHOBOS_SRC/"internal") ]
  FILES.sort() # Sort for index.

  modify_std_ddoc(PHOBOS_SRC/"std.ddoc", TMP/"phobos.ddoc", D_VERSION)
  write_overrides_ddoc(TMP/"overrides.ddoc")

  create_index_file(TMP/"index.d", PHOBOS_SRC, FILES)


  DOC_FILES = FILES + [PHOBOS_SRC/"phobos.d"] + \
              TMP//("index.d", "phobos.ddoc", "overrides.ddoc")
  versions = ["DDoc"]
  generate_docs(DIL_EXE, DEST, MODLIST, DOC_FILES, versions, options='-v -i')

  modlist = read_modules_list(MODLIST)

  for args in generate_shl_files2(DIL_EXE, HTML_SRC, modlist):
    print "hl %s > %s" % args;

  modify_phobos_html(DEST/"phobos.html", D_VERSION)

  copy_files(DATA, PHOBOS_SRC, HTML_SRC, DEST)

  TMP.rmtree()

if __name__ == "__main__":
  main()

/**
 * Author: Jari-Matti Mäkelä
 * License: GPL3
 */
module docgen.document.htmlwriter;

import docgen.document.writer;
import tango.io.FileConduit : FileConduit;
import tango.io.Print: Print;
import tango.text.convert.Layout : Layout;

// TODO: this is mostly broken now

/**
 * Writes a HTML document skeleton.
 */
class HTMLWriter : AbstractDocumentWriter!(2, "html") {
  this(DocumentWriterFactory factory, OutputStream[] outputs) {
    super(factory, outputs);
  }

  void generateDocument() {
    auto output = new Print!(char)(new Layout!(char), outputs[0]);
    
    output.format(
      templates["firstpage"],
      factory.options.templates.title,
      factory.options.templates.copyright,
      factory.options.templates.versionString,
      docgen_version
    );
  }
}
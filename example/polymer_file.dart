// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library main;

import 'dart:html' show document, Blob, TextAreaElement;
import 'package:polymer/polymer.dart' show initMethod, Polymer;
import 'package:logging/logging.dart' show hierarchicalLoggingEnabled, Level, Logger;
import 'package:polymer_elements/polymer_file/polymer_file.dart' show PolymerFile;

@initMethod
init() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.FINEST;

  //Logger.root.onRecord.listen((e) => print(e));

  Polymer.onReady.then((e) {
    var pfile = document.querySelector('polymer-file') as PolymerFile;
    pfile.blob = new Blob(['abc123'], 'text/plain');
    //pfile.auto = true;
    //pfile.read();

    pfile.onFileReadResult.listen((e) {
      (document.querySelector('textarea') as TextAreaElement).value = e.detail;
    });
  });
}
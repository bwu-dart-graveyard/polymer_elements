// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_file.test;

import "dart:html";
import "package:polymer/polymer.dart";
import "package:unittest/unittest.dart";
import "package:unittest/html_enhanced_config.dart";
import "package:polymer_elements/polymer_file/polymer_file.dart";

@initMethod
void init() {
  //return;
  useHtmlEnhancedConfiguration();

  test("polymer-file", () {
    var done = expectAsync(() {});
    String DATA = 'abc123';

    PolymerFile pfile = document.querySelector('polymer-file');

    expect(pfile.blob, isNull);
    expect(pfile.auto, isTrue);
    expect(pfile.readas, equals('text'));
    expect(pfile.result, isNull, reason: ".auto doesn't start a read");

    pfile.blob = new Blob([DATA], 'text/plain');

    pfile.onFileReadResult.listen((e) {
      expect(e.detail, isNotNull);
      expect(e.detail, new isInstanceOf<String>('String'), reason:
          'Result is a text string');
      expect(e.detail, equals(DATA), reason: 'Result correct data');
      expect(pfile.result, equals(DATA), reason: '.result was set correctly');

      done();
    });
  });
}

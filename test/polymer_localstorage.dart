// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_localstorage.test;

import "dart:html";
import "package:polymer/polymer.dart";
import "package:unittest/unittest.dart";
import "package:unittest/html_enhanced_config.dart";
import "package:polymer_elements/polymer_localstorage/polymer_localstorage.dart";

@initMethod
void init() {
  useHtmlEnhancedConfiguration();

  test("polymer-localstorage", () {
    var done = expectAsync((){});
    var s = document.querySelector('#localstorage') as PolymerLocalstorage;
    var m = 'hello wold';
    window.localStorage[s.name] = m;

    var doneEvent = expectAsync((){});

    s.onLoadEvent.listen((_) {
      doneEvent();
    });

    s.load();
    expect(s.value, equals(m));
    s.value = 'goodbye';
    expect(window.localStorage[s.name], equals(m));
    done();
  });
}


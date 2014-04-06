// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_selection.test.multi;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:polymer_elements/polymer_selection/polymer_selection.dart' show
    PolymerSelection;

@initMethod
void init() {
  useHtmlEnhancedConfiguration();

  Polymer.onReady.then((e) {
    test('polymer-selection-multi', () {
      var done = expectAsync(() {}, count: 2);
      var s = dom.document.querySelector('polymer-selection') as
          PolymerSelection;
      int testNr = 0;

      s.addEventListener('polymer-select', (event) {
        if (testNr == 1) {
          // check test1
          expect(event.detail['isSelected'], isTrue);
          expect(event.detail['item'], equals('(item1)'));
          expect(s.isSelected(event.detail['item']), isTrue);
          expect(s.selection.length, equals(1));
          // test2
          testNr++;
          s.select('(item2)');
          done();
        } else {
          if (testNr == 2) {
            // check test2
            expect(event.detail['isSelected'], isTrue);
            expect(event.detail['item'], equals('(item2)'));
            expect(s.isSelected(event.detail['item']), isTrue);
            expect(s.selection.length, equals(2));
            done();
          }
        }
      });
      testNr = 1;
      s.select('(item1)');
    });
  });
}

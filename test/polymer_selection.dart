// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_selection.test;

import 'dart:async' as async;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:polymer_elements/polymer_selection/polymer_selection.dart' show
    PolymerSelection;

@initMethod
void init() {
  useHtmlEnhancedConfiguration();

  Polymer.onReady.then((e) {
    group('polymer-selection', () {
      test('polymer-selection', () {
        var done = expectAsync(() {}, count: 2);
        var s = document.querySelector('polymer-selection') as PolymerSelection;
        int testNr = 0;

        async.StreamSubscription subscr;
        subscr = s.on['polymer-select'].listen((event) {
          if (testNr == 1) {
            expect(event.detail['isSelected'], isTrue);
            expect(event.detail['item'], equals('(item)'));
            expect(s.isSelected(event.detail['item']), isTrue);
            expect(s.isSelected('(some_item_not_selected)'), isFalse);
            testNr++;
            s.select(null);
            done();
          } else {
            if (testNr == 2) {
              // check test2
              expect(event.detail['isSelected'], isFalse);
              expect(event.detail['item'], equals('(item)'));
              expect(s.isSelected(event.detail['item']), isFalse);
              subscr.cancel(); // don't fire when other tests run
              done();
            }
          }
        });
        testNr = 1;
        s.select('(item)');
      });

      test('event stream getter', () {
        var done = expectAsync(() {}, count: 2);
        var s = document.querySelector('polymer-selection') as PolymerSelection;
        int testNr = 0;

        async.StreamSubscription subscr;
        subscr = s.onPolymerSelect.listen((e) {
          if (testNr == 1) {
            testNr++;
            s.select(null);
            done();
          } else if (testNr == 2) {
            subscr.cancel();
            done();
          }
        });
        testNr = 1;
        s.select('(item)');
      });
    });
  });
}

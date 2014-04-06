// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_selector.test.multi;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:polymer_elements/polymer_selector/polymer_selector.dart' show
    PolymerSelector;

void oneMutation(dom.Element node, options, Function cb) {
  var o = new dom.MutationObserver((List<dom.MutationRecord>
      mutations, dom.MutationObserver observer) {
    cb();
    observer.disconnect();
  });
  o.observe(node, attributes: options['attributes']);
}

@initMethod
void init() {
  useHtmlEnhancedConfiguration();

  Polymer.onReady.then((e) {
    test('polymer-selector-multi', () {
      var done = expectAsync(() {});
      // selector1
      var s = (dom.document.querySelector('#selector') as PolymerSelector);
      expect(s, isNotNull);
      expect(s.selected, isNull);
      expect(s.selectedClass, equals('polymer-selected'));
      expect(s.multi, isTrue);
      expect(s.valueattr, equals('name'));
      expect(s.items.length, equals(5));
      // setup listener for polymer-select event
      var selectEventCounter = 0;
      s.on['polymer-select'].listen((dom.CustomEvent e) {
        if (e.detail['isSelected']) {
          selectEventCounter++;
        } else {
          selectEventCounter--;
        }
        // check selectedItem in polymer-select event
        expect(s.selectedItem.length, selectEventCounter);
      });
      // set selected
      //dom.Platform.flush();
      s.selected = [0, 2];
          // TODO doesn't work as expected https://code.google.com/p/dart/issues/detail?id=17472
      s.dummy = 'dummy'; // TODO remove workaround for ^
      oneMutation(s, {
        'attributes': true
      }, () {
        new async.Future(() {
            // TODO workaround for https://code.google.com/p/dart/issues/detail?id=14496
          // check polymer-select event
          expect(selectEventCounter, equals(2));
          // check selected class
          expect(s.children[0].classes.contains('polymer-selected'), isTrue);
          expect(s.children[2].classes.contains('polymer-selected'), isTrue);
          // check selectedItem
          expect(s.selectedItem.length, equals(2));
          expect(s.selectedItem[0], equals(s.children[0]));
          expect(s.selectedItem[1], equals(s.children[2]));
          // tap on already selected element should unselect it
          s.children[0].dispatchEvent(new dom.CustomEvent('click', canBubble:
              true)); // change to 'tap' when it's working
          // check selected
          expect(s.selected.length, equals(1));
          expect(s.children[0].classes.contains('polymer-selected'), isFalse);
          done();
        });
      });
    });
  });
}


// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_selector.test.basic;

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

    test('polymer-selector', () {
      var done = expectAsync(() {});
      // selector1
      var s = (dom.document.querySelector('#selector1') as PolymerSelector);
      expect(s, isNotNull);
      expect(s.selectedClass, equals('polymer-selected'));
      expect(s.multi, isFalse);
      expect(s.valueattr, equals('name'));
      expect(s.items.length, equals(5));

      // selector2
      s = (dom.document.querySelector('#selector2') as PolymerSelector);
      expect(s.selected, equals('item3'));
      expect(s.selectedClass, equals('my-selected'));
      // setup listener for polymer-select event
      var selectEventCounter = 0;
      s.onPolymerSelect.listen((dom.CustomEvent e) {
        //s.on['polymer-select'].listen((dom.CustomEvent e) {
        if (e.detail['isSelected']) {
          selectEventCounter++;
          // selectedItem and detail.item should be the same
          expect(e.detail['item'], equals(s.selectedItem));
        }
      });
      // set selected
      s.selected = 'item5';
      //dom.Platform.flush();
      oneMutation(s, {
        'attributes': true
      }, () {
        new async.Future(() { // TODO workaround
          // check polymer-select event
          expect(selectEventCounter, equals(1));
              // TODO doesn't work due to https://code.google.com/p/dart/issues/detail?id=14496
          // check selected class
          expect(s.children[4].classes.contains('my-selected'), isTrue);
          // check selectedItem
          expect(s.selectedItem, equals(s.children[4]));
          // selecting the same value shouldn't fire polymer-select
          selectEventCounter = 0;
          s.selected = 'item5';
          //Platform.flush();
          // TODO(ffu): would be better to wait for something to happen
          // instead of not to happen
          new async.Future.delayed(new Duration(milliseconds: 50), () {
            expect(selectEventCounter, equals(0));
            done();
          });
        });
      });
    });
  });
}


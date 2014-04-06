// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_selector.test.activate_event;

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
    test('polymer-selector-activate-event', () {
      var done = expectAsync(() {});
      // selector1
      var s = (dom.document.querySelector('#selector') as PolymerSelector);
      s.onPolymerActivate.listen((dom.CustomEvent event) {
        expect(event.detail['item'], equals(s.children[1]));
        expect(s.selected, equals(1));
        done();
      });
      expect(s.selected, equals(0));
      dom.window.requestAnimationFrame((e) {
        s.children[1].dispatchEvent(new dom.CustomEvent('click', canBubble: true
            )); // TODO change to 'tap' when supported
      });
    });
  });
}


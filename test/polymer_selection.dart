// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 


library polymer_selection;

import "dart:html";
import "package:polymer/polymer.dart";
import "package:unittest/unittest.dart";
import "package:unittest/html_enhanced_config.dart";
import "package:polymer_elements/polymer_selection/polymer_selection.dart" show PolymerSelection;

void main() { 
  useHtmlEnhancedConfiguration();

  initPolymer();
  
  test("polymer-selection", () {
    var done = expectAsync0((){}, count: 2);
    var s = document.querySelector('polymer-selection') as PolymerSelection;
    int testNr = 0;
    
    s.addEventListener('polymer-select', (event) {
      if (testNr == 1) {
        expect(event.detail['isSelected'], isTrue);
        expect(event.detail['item'], equals('(item)'));
        expect(s.isSelected(event.detail['item']), isTrue);
        expect(s.isSelected('(some_item_not_selected)'), isFalse);
        testNr++;
        s.select(null);
        done();
      } else if (testNr == 2) {
        // check test2
        expect(event.detail['isSelected'], isFalse);
        expect(event.detail['item'], equals('(item)'));
        expect(s.isSelected(event.detail['item']), isFalse);
        done();        
      }
    });
    testNr = 1;
    s.select('(item)');
    
  });
}



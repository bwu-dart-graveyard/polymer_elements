// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_flex_panel;

import 'package:polymer/polymer.dart';
import 'polymer_flex_layout.dart';

@CustomTag('polymer-flex-panel')
class PolymerFlexPanel extends PolymerFlexLayout {
  PolymerFlexPanel.created() : super.created();

  @override
  void polymerCreated() {
    isContainer = true;
    super.polymerCreated();
  }
}

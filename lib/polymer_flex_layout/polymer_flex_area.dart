// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_flex_area;

import 'dart:html';
import 'package:polymer/polymer.dart';


@CustomTag('polymer-flex-area')
class PolymerFlexArea extends PolymerElement {
  PolymerFlexArea.created() : super.created();

  void polymerAddFlexbox(Event e, var details, Node node) {
      this.classes.add('flexbox');
      e.stopImmediatePropagation();
  }
}


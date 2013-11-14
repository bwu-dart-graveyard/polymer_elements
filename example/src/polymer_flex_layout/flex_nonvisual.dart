// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library flex_nonvisual;

import 'dart:html' show Event, Node;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement;

@CustomTag('flex-nonvisual')
class FlexNonvisual extends PolymerElement {
  FlexNonvisual.created() : super.created();
  
  void polymerAddFlexbox(Event e, var details, Node node) {
    //if(this.children.contains(node)) {
      this.classes.add('flexbox');
      e.stopImmediatePropagation();
    //}
  }
}

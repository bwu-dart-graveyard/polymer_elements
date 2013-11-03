// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_page;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('polymer-page')
class PolymerPage extends PolymerElement {
  PolymerPage.created() : super.created();

  @published bool fullbleed = true;
  void enteredView() {
    super.enteredView();
    document.head.style.cssText += 'height: 100%; overflow: hidden; margin: 0;';
    document.body.style.cssText += 'position: absolute; top: 0; right: 0; bottom: 0; left: 0; overflow: hidden; margin: 0;';
    document.body.style.transition = 'all 0.3s';
  }
}
// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library my_app;

import 'package:polymer/polymer.dart';

@CustomTag('my-app')
class MyApp extends PolymerElement {
  
  MyApp.created() : super.created();
  
  fooSignal(e, detail, sender){
    this.appendHtml('<br>[my-app] got a [' + detail + '] signal<br>');
  }
  
}
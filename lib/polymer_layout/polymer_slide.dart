// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_slide;

//import 'dart:html' show;
import 'package:logging/logging.dart' show Logger;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement;

@CustomTag('polymer-slide')
class PolymerSlide extends PolymerElement {
  PolymerSlide.created() : super.created();
  
  final _logger = new Logger('polymer-slide');


}
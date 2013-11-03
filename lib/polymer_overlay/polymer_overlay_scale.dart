// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_overlay_scale;

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_animation/polymer_animation.dart';

@CustomTag('polymer-overlay-scale')
class PolymerOverlayScale extends PolymerAnimation {
  PolymerOverlayScale.created() : super.created() {
    duration = 0.218;
// TODO    properties = {
//      'opacity': ['0', '1'],
//      'transform': ['scale(1.05)', 'scale(1)']};
  }
}
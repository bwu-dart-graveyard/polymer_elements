// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_overlay_slideup;

import 'package:polymer/polymer.dart';
import '../polymer_animation/polymer_animation.dart';

@CustomTag('polymer-overlay-slideup')
class PolymerOverlaySlideup extends PolymerAnimation {

  PolymerOverlaySlideup.created(): super.created() {
    duration = '0.4';
    properties = {
      'opacity': ['1', '0'],
      'transform': ['translateY(0)', 'translateY(-100%)']
    };
  }
}

// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_blink;

import 'package:polymer/polymer.dart';
import 'polymer_animation.dart';

/**
 * A CSS property and value to use in a `<polymer-animation-keyframe>`.
 */
@CustomTag('polymer-blink')
class PolymerBlink extends PolymerAnimation {

  PolymerBlink.created(): super.created() {
    targetSelector = null;
    duration = '0.7';
    iterationCount = -1;
    easing = 'cubic-bezier(1.0, 0, 0, 1.0)';
    keyframes = [{'opacity': 1}, {'opacity': 0}];
  }
}

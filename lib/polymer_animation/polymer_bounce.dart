// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_bounce;

import 'package:polymer/polymer.dart';
import 'polymer_animation.dart';

/**
 * A CSS property and value to use in a `<polymer-animation-keyframe>`.
 */
@CustomTag('polymer-bounce')
class PolymerBounce extends PolymerAnimation {

  PolymerBounce.created(): super.created() {
    targetSelector = null;
    duration = '1';
  }

  @observable String magnitude = '-30px';

  @override
  void ready() {
    super.ready();

    this.magnitudeChanged(null);
  }

  void magnitudeChanged(old) {
    generate();
  }

  void generate() {
    var parsed = new RegExp('([\-0-9]+)(.*)').allMatches(magnitude);

    num num1 = 0;
    if(parsed.length > 0) {
      try {
        num1 = num.parse(parsed[1]);
      } catch(e){}
    }

    num num2 = 0;
    if(parsed.length > 1) {
      try {
        num1 = num.parse(parsed[2]);
      } catch(e){}
    }

    this.keyframes = [
      {'offset': 0, 'transform': 'translateY(0)'},
      {'offset': 0.2, 'transform': 'translateY(0)'},
      {'offset': 0.4, 'transform': 'translateY(' + this.magnitude + ')'},
      {'offset': 0.5, 'transform': 'translateY(0)'},
      {'offset': 0.6, 'transform':'translateY(${num1 / 2 + num2})'}, // + Number(parsed[1]) / 2 + parsed[2] + ')'},
      {'offset': 0.8, 'transform': 'translateY(0)'},
      {'offset': 1, 'transform': 'translateY(0)'}
    ];

  }
}

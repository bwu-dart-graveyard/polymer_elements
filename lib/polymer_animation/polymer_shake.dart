// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_shake;

import 'package:polymer/polymer.dart';
import 'polymer_animation_group.dart';

@CustomTag('polymer-shake')
class PolymerShake extends PolymerAnimationGroup {

  PolymerShake.created(): super.created() {
    targetSelector = null;
    duration = 0.3;
    easing = 'ease-in';
    type = 'seq';
  }

  @observable String negTransform;
  @observable String posTransform;
  @observable var shakeDuration;
  @observable int shakeIterations;
  @observable String magnitude = '10px';
  @observable double period = 0.1;

  void ready() {
    super.ready();
    magnitudeChanged(null);
    periodChanged(null);
  }

  void durationChanged(old) {
    super.durationChanged(old);
    generate();
  }

  void magnitudeChanged(old) {
    generate();
  }

  void periodChanged(old) {
    generate();
  }

  void generate() {

    double d = 0.0;
    try {
      d = double.parse(duration);
    } catch(e){}

    negTransform = 'translateX(-${magnitude})';
    posTransform = 'translateX(${magnitude})';
    shakeDuration = period * 2;
    shakeIterations = this.duration == -1 ? d : (d ~/ shakeDuration);
  }

  Map get timingProps {
    return {};
  }
}

// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_scale;

import 'package:polymer/polymer.dart';
import 'polymer_animation.dart';

@CustomTag('polymer-scale')
class PolymerScale extends PolymerAnimation {

  PolymerScale.created(): super.created();

  @observable String fromX = '0';
  @observable String fromY = '0';
  @observable String toX = '0';
  @observable String toY = '0';

  void fromXChanged(old) {
    this.generate();
  }

  void fromYChanged(old) {
    this.generate();
  }

  void toXChanged(old) {
    this.generate();
  }

  void toYChanged(old) {
    this.generate();
  }

  void generate() {
    this.keyframes = [
      {'transform': 'translate3d(${fromX},${fromY})'},
      {'transform': 'translate3d(${toX},${toY}'}
    ];
  }
}

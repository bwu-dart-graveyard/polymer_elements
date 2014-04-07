// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_animation_keyframe;

import 'package:polymer/polymer.dart';

@CustomTag('polymer-animation-keyframe')
class PolymerAnimationKeyframe extends PolymerElement {

  PolymerAnimationKeyframe.created(): super.created();

  Map get properties {
    var props = {};
    var children = this.querySelectorAll('polymer-animation-prop');
    children.forEach((c) {
      props[c.name] = c.value;
    });
    if (animoffset != null) {
      props['offset'] = animoffset;
    }
    return props;
  }

  @published double animoffset;

  @published String value;
  @published String easing;
}

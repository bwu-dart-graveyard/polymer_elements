// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_animation_group;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'polymer_animation.dart';

/**
 * Component for a group of animations.
 */
@CustomTag('polymer-animation-group')
class PolymerAnimationGroup extends PolymerAnimation {

  PolymerAnimationGroup.created(): super.created();

  var ANIMATION_GROUPS = {
    'par': null,
    'seq': null
  };

  /**
      * If specified the target will be assigned to all child animations.
      * HTMLElement|Node
      */
  @published
  String targetSelector;

  /**
      * If specified and not "auto" the duration will apply to the group
      * and propagate to any child animations that is not a group and does
      * not specify a duration.
      * valid values number|"auto"
      */
  @published
  var duration = 'auto';

  /**
      * Group type. 'par' for parallel and 'seq' for sequence.
      */
  @published
  String type = 'par';

  void typeChanged(old) {
    this.apply();
  }

  @override
  void targetChanged(old) {
    // Only propagate target to children animations if it's defined.
    if (target != null) {
      this.doOnChildren((c) {
        c.target = target;
      }); // TODO .bind(this));
    }
  }

  @override
  void durationChanged(old) {
    if (duration != null && this.duration != 'auto') {
      this.doOnChildren((c) {
        // Propagate to children that is not a group and has no
        // duration specified.
        if (c is! PolymerAnimationGroup && (c.duration == null || c.duration != null || c.duration ==
            'auto')) {
          c.duration = this.duration;
        }
      }); // TODO .bind(this));
    }
  }

  void doOnChildren(Function inFn) {
    var children = this.children;
    if (children.length == 0 && shadowRoot != null) {
      children = shadowRoot.children;
    }
    children.forEach((c) {
      // TODO <template> in the way
      if(c is PolymerAnimation) inFn(c);
    });
  }

  @override
  dom.Animation makeAnimation() {
    // TODO return new ANIMATION_GROUPS[this.type](this.childAnimations, this.timingProps);
  }

  @override
  hasTarget() {
    var ht = target != null;
    if (!ht) {
      doOnChildren((c) {
        ht = ht || c.hasTarget();
      }); // TODO .bind(this));
    }
    return ht;
  }

  @override
  dom.Animation apply() {
    // Propagate target and duration to child animations first.
    this.durationChanged(null);
    this.targetChanged(null);
    this.doOnChildren((c) {
      c.apply();
    });
    return super.apply();
  }

  List<dom.Node> get childAnimationElements {
    var list = [];
    this.doOnChildren((c) {
      if (c.makeAnimation) {
        list.add(c);
      }
    });
    return list;
  }

  List<dom.Animation> get childAnimations {
    var list = [];
    this.doOnChildren((c) {
      if (c.animation) {
        list.add(c.animation);
      }
    });
    return list;
  }
}

// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_animation.polymer_animation;

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/polymer_animation/helper.dart';

/**
 * WebAnimations module.
 * @module Animation
 * @main animation
 * @example toolkitchen/labs/animation2/grid-fade.html
 * @example toolkitchen/labs/animation2/group.html
 */

/**
 * Component for a single animation.
*
 * A animation component to fade out an element:
*
 *     <polymer-animation id="fadeout">
 *       <polymer-animation-keyframe offset="0">
 *         <polymer-animation-prop name="opacity" value="0">
 *         </polymer-animation-keyframe>
 *       </polymer-animation-keyframe>
 *       <polymer-animation-keyframe offset="1">
 *         <polymer-animation-prop name="opacity" value="1">
 *         <polymer-animation-prop>
 *       </polymer-animation-keyframe>
 *     </polymer-animation>
 * @class polymer-animation
 */

/**
 * Fired when the animation starts
 * @event polymer-animation-start
*
 * Fired when the animation completes
 * @event polymer-animation-end
 * 
 */
@CustomTag('polymer-overlay-scale')
class PolymerAnimation extends PolymerElement {
  PolymerAnimation.created() : super.created();
  
  Node findTarget(String inSelector, Node inNode) {
    Node p = inNode;
    Node target;
    while (p != null &&  p != document) {
      p = p.parentNode;
    }
    if (p != null && p is HtmlElement) {
      target = (p as HtmlElement).querySelector(inSelector);
    }
    if (target == null && p != null) {
      target = findTarget(inSelector, p);
    }
    return target;
  }
  
  double toNumber(String value, bool allowInfinity) {
    return (allowInfinity && value == 'Infinity') ? double.INFINITY : double.parse(value);
  }
      
  /**
   * The node being animated.
   * @type HTMLElement|Node
   */
  @published Node target = null;

  /**
   * Selector for the node being animated.
   */
  @published String targetSelector = '';
  
  // animation
  /**
   * Animation keyframes specified as an array of dictionaries of
   * &lt;css properties&gt;:&lt;array of values&gt; pairs. For example,
   * @type Object
   */
  @published var keyframes = null;
  
  /**
   * A custom animation function. Either provide this or keyframes.
   * @type Function
   */
  @published Function sample = null;
  
  //accumulate: null, // not working in polyfill
  /**
   * The composition behavior. "replace", "add" or "merge".
   * @type "replace"|"add"|"merge"
   */
  @published String composite = 'replace';
  
  // timing
  /**
   * Animation duration in milliseconds, 'infinity' or 'auto'. 'auto'
   * means use the animation's intrinsic duration.
   * @type Number|"Infinity"|"auto"
   */
  @published var duration = 'auto';
  
  /**
   * "none", "forwards", "backwards", "both" or "auto". When set to
   * "auto", the fillMode is "none" for a polymer-animation and "both"
   * for a polymer-animation-group.
   * @type "none"|"forwards"|"backwards"|"both"|"auto"
   */
  @published String fillMode = 'auto';
  
  /**
   * A transition timing function.
   * @type "linear"|"ease"|"ease-in"|"ease-out"|"ease-in-out"|
   *     "step-start"|"step-middle"|"step-end"
   */
  @published  String easing = 'linear';

  /**
   * Number of iterations into the timed item in which to begin
   * the animation. e.g. 0.5 will cause the animation to begin
   * halfway through the first iteration.
   * @type Number
   */
  @published num iterationStart = 0;

  /**
   * @type Number|'Infinity'
   */
  @published var iterationCount = 1;
  
  /**
   * Delay in milliseconds.
   * @type Number
   */
  @published num delay = 0;
  
  /**
   * @type "normal"|"reverse"|"alternate"|"alternate-reverse"
   */
  @published String direction = 'normal';

  @published bool autoplay = false;

  bool animation = false;
  
  Observe observe = new Observe(
    target: 'apply',
    keyframes: 'apply',
    sample: 'apply',
    composite: 'apply',
    duration: 'apply',
    fillMode: 'apply',
    easing: 'apply',
    iterationCount: 'apply',
    delay: 'apply',
    direction: 'apply',
    autoplay: 'apply');
  
  @override
  createdPolymer() {
    this.apply();
  }
  
  /**
   * Plays the animation.
   * @method play
   */
  void play() {
    this.apply();
    if (this.animation && !this.autoplay) {
      this.bindAnimationEvents();
      // TODO this.player = document.timeline.play(this.animation);
    }
  }
  
  /**
   * Stops the animation.
   * @method cancel
   */
  void cancel() {
// TODO    if (this.player) {
//      this.player.source = null;
//    }
  }
  
  bool apply() {
    this.animation = null;
    // TODOthis.animation = this.makeAnimation();
    if (this.autoplay && this.animation) {
      this.play();
    }
    return this.animation;
  }
  
  void makeAnimation() {
    // this.target && console.log('makeAnimation target', this.target, 'animation', this.animationEffect, 'timing', this.timingProps);
    // TODO return this.target != null ? new Animation(this.target, this.animationEffect, this.timingProps) : null;
  }
  
  void animationChanged() {
    // TODO: attributes are not case sensitive.
    // TODO: Sending 'this' with the event because if the children is
    // in ShadowDOM the sender becomes the shadow host.
    // TODO this.fire('animationchange', this);
  }
  
  void targetSelectorChanged(old) {
    if (this.targetSelector != null && this.targetSelector.isNotEmpty) {
      this.target = findTarget(this.targetSelector, this);
    }
  }
  
  get timingProps {
    var props = {};
    var timing = {
      'fillMode': {'property': 'fill'},
      'easing': {},
      'delay': {'isNumber': true},
      'iterationCount': {'isNumber': true, 'allowInfinity': true},
      'direction': {},
      'duration': {'isNumber': true}
    };
    for (var t in timing) {
      // TODO if (this[t] != null) {
        var name = timing[t].property || t;
        // TODO props[name] = timing[t].isNumber && this[t] != 'auto' ?
            // TODO toNumber(this[t], timing[t].allowInfinity) : this[t];
      // TODO}
    }
    return {}; // TODO return props;
  }
  
  get animationEffect {
    var props = {};
    var frames = [];
    var effect;
    if (this.keyframes) {
      frames = this.keyframes;
    } else if (this.sample != null) {
      var children = this.querySelectorAll('polymer-animation-keyframe');
      if (children.length == 0) {
        children = this.shadowRoot.querySelectorAll('polymer-animation-keyframe');
      }
      children.forEach((HtmlElement c) {
        // frames.add(c.properties);
      });
    }
    if (this.sample != null) {
      effect = {sample: this.sample};
    } else {
      // TODOeffect = new KeyframeAnimationEffect(frames, this.composite);
    }
    return effect;
  }
  
  void bindAnimationEvents() {
// TODO    if (this.animation.onstart == null) {
//      this.animation.onstart = this.animationStartHandler.bind(this);
//    }
//    if (this.animation.onend == null) {
//      this.animation.onend = this.animationEndHandler.bind(this);
//    }
  }
  
  void animationStartHandler() {
    this.fire('polymer-animation-start');
  }
  
  void animationEndHandler() {
    this.fire('polymer-animation-end');
  }
}


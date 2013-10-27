// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
        * Fired when the web animation object changes.
        * @event polymer-animation-change
        * 
        */

library polymer.elements.polymer_animation;

import 'dart:html';
import 'package:polymer/polymer.dart';

findTarget(inSelector, inNode) {
  var p = inNode;
  var target;
  while (p && !p.host && p != inNode.ownerDocument) {
    p = p.parentNode;
  }
  if (p) {
    target = p.querySelector(inSelector);
  }
  if (!target && p && p.host) {
    target = findTarget(inSelector, p.host);
  }
  return target;
}

/*
toNumber(value, allowInfinity) {
  return (allowInfinity && value === 'Infinity') ? Number.POSITIVE_INFINITY : Number(value);
}
*/

@CustomTag('polymer-animation')
class PolymerAnimation extends PolymerElement {
  
  /**
   * The node being animated.
   * @property target
   * @type HTMLElement|Node
   */
  @published
  Node target = null;
  /**
   * Selector for the node being animated.
   * @property targetSelector
   * @type String
   */
  @published
  String targetSelector = '';
  // animation
  /**
   * Animation keyframes specified as an array of dictionaries of
   * &lt;css properties&gt;:&lt;array of values&gt; pairs. For example,
   * @property keyframes
   * @type Object
   */
  @published
  List keyframes = null;
  /**
   * A custom animation function. Either provide this or keyframes.
   * @property sample
   * @type Function
   */
  //TODO Create a typedef
  @published
  var sample = null;
  //accumulate: null, // not working in polyfill
  /**
   * The composition behavior. "replace", "add" or "merge".
   * @property composite
   * @type "replace"|"add"|"merge"
   * @default "replace"
   */
  @published
  String composite = 'replace';
  // timing
  /**
   * Animation duration in milliseconds, 'infinity' or 'auto'. 'auto'
   * means use the animation's intrinsic duration.
   * @property duration
   * @type Number|"Infinity"|"auto"
   * @default "auto"
   */
  @published
  var duration = 'auto';
  /**
   * "none", "forwards", "backwards", "both" or "auto". When set to
   * "auto", the fillMode is "none" for a polymer-animation and "both"
   * for a polymer-animation-group.
   * @property fillMode
   * @type "none"|"forwards"|"backwards"|"both"|"auto"
   * @default "auto"
   */
  
  @published
  String fillMode: 'auto';
  /**
   * A transition timing function.
   * @property easing
   * @type "linear"|"ease"|"ease-in"|"ease-out"|"ease-in-out"|
   *     "step-start"|"step-middle"|"step-end"
   * @default "linear"
   */
  @published
  String easing: 'linear';
  /**
   * Number of iterations into the timed item in which to begin
   * the animation. e.g. 0.5 will cause the animation to begin
   * halfway through the first iteration.
   * @property iterationStart
   * @type Number
   * @default 0
   */
  @published
  int iterationStart = 0;
  /**
   * @property iterationCount
   * @type Number|'Infinity'
   * @default 1
   */
  
  @published
  int iterationCount = 1;
  /**
   * Delay in milliseconds.
   * @property delay
   * @type Number
   * @default 0
   */
  @published
  int delay= 0;
  /**
   * @property direction
   * @type "normal"|"reverse"|"alternate"|"alternate-reverse"
   * @default "normal"
   */
  @published
  String direction = 'normal';

  @published
  bool autoplay = false;
  
  @published
  bool animation = false;  
  
  Map observe = {
    'target': 'apply',
    'keyframes': 'apply',
    'sample': 'apply',
    'composite': 'apply',
    'duration': 'apply',
    'fillMode': 'apply',
    'easing': 'apply',
    'iterationCount': 'apply',
    'delay': 'apply',
    'direction': 'apply',
    'autoplay': 'apply'
  };
  
  var _player;
  
  PolymerAnimation.created() : super.created();
  
  ready() {
    this.apply();
  }
  /**
   * Plays the animation.
   * @method play
   */
  play() {
    this.apply();
    if (this.animation && !this.autoplay) {
      this.bindAnimationEvents();
      this._player = ownerDocument.timeline.play(this.animation);
    }
  }
  /**
   * Stops the animation.
    * @method cancel
   */
  cancel() {
    if (this._player != null) {
      this._player.source = null;
    }
  }
  
  apply() {
    this.animation = null;
    this.animation = this.makeAnimation();
    if (this.autoplay && this.animation) {
      this.play();
    }
    return this.animation;
  }
  
  makeAnimation() {
    // this.target && console.log('makeAnimation target', this.target, 'animation', this.animationEffect, 'timing', this.timingProps);
    return this.target ? new Animation(this.target, this.animationEffect, this.timingProps) : null;
  }
  
  animationChanged() {
    // TODO: attributes are not case sensitive.
    // TODO: Sending 'this' with the event because if the children is
    // in ShadowDOM the sender becomes the shadow host.
    this.fire('polymer-animation-change', this);
  }
  
  targetSelectorChanged() {
    if (this.targetSelector) {
      this.target = findTarget(this.targetSelector, this);
    }
  }
  
  get timingProps {
    var props = {};
    var timing = {
                  fillMode: {property: 'fill'},
                  easing: {},
                  delay: {isNumber: true},
                  iterationCount: {isNumber: true, allowInfinity: true},
                  direction: {},
                  duration: {isNumber: true}
    };
    for (t in timing) {
      if (this[t] !== null) {
        var name = timing[t].property || t;
        props[name] = timing[t].isNumber && this[t] !== 'auto' ?
            toNumber(this[t], timing[t].allowInfinity) : this[t];
      }
    }
    return props;
  }
  
  get animationEffect {
    var props = {};
    var frames = [];
    var effect;
    if (this.keyframes) {
      frames = this.keyframes;
    } else if (!this.sample) {
      var children = this.querySelectorAll('polymer-animation-keyframe');
      if (children.length === 0) {
        children = this.shadowRoot.querySelectorAll('polymer-animation-keyframe');
      }
      Array.prototype.forEach.call(children, function(c) {
        frames.push(c.properties);
      });
    }
    if (this.sample) {
      effect = {sample: this.sample};
    } else {
      effect = new KeyframeAnimationEffect(frames, this.composite);
    }
    return effect;
  }
  
  bindAnimationEvents() {
    if (!this.animation.onstart) {
      this.animation.onstart = this.animationStartHandler.bind(this);
    }
    if (!this.animation.onend) {
      this.animation.onend = this.animationEndHandler.bind(this);
    }
  }
  
  animationStartHandler() {
    this.fire('polymer-animation-start');
  }
  
  animationEndHandler() {
    this.fire('polymer-animation-end');
  }

  
}
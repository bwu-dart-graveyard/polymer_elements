// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_animation;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'package:polymer/polymer.dart';

/**
 * Component for a single animation.
 *
 * A animation component to fade out an element:
 *
 *     <polymer-animation id="fadeout">
 *       <polymer-animation-keyframe animoffset="0">
 *         <polymer-animation-prop name="opacity" value="0">
 *         </polymer-animation-prop>
 *       </polymer-animation-keyframe>
 *       <polymer-animation-keyframe animoffset="1">
 *         <polymer-animation-prop name="opacity" value="1">
 *         </polymer-animation-prop>
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
@CustomTag('polymer-animation')
class PolymerAnimation extends PolymerElement {

  PolymerAnimation.created() : super.created() {
    attrs = new Attributes(this);
  }

  dom.HtmlElement findTarget(String inSelector, dom.HtmlElement inNode) {
    var p = inNode;
    dom.HtmlElement target;

    while(p != null && p is! dom.ShadowRoot && p != dom.document) {
      p = p.parentNode;
    }

    if(p != null) {
      target = p.querySelector(inSelector);
    }
    if(target == null && p != null && p is dom.ShadowRoot) {
      target = findTarget(inSelector, p);
    }
    return target;
  }

  num toNumber(num value, bool allowInfinity) {
    if(allowInfinity && value.isInfinite) {
      return -1; // infinite
    }
    if(value.isNaN) {
      return 0;
    }
    return value;
  }

  @published Map properties; // TODO needed for overlay

  /**
   * One or more nodes to animate.
   */
  @published dom.Element target;

  /**
   * Selector for the node being animated.
   */
  @published String targetSelector;

  // animation
  /**
   * Animation keyframes specified as an array of dictionaries of
   * &lt;css properties&gt;:&lt;array of values&gt; pairs. For example,
   */
  @published List<Map> keyframes;

  /**
   * A custom animation function. Either provide this or keyframes.
   */
  @published Function sample;

  //accumulate: null, // not working in polyfill
  /**
   * The composition behavior. "replace", "add" or "merge".
   * valid values "replace"|"add"|"merge"
   */
  @published String composite = 'replace';

  // timing
  /**
   * Animation duration in milliseconds, 'infinity' or 'auto'. 'auto'
   * means use the animation's intrinsic duration.
   * valid values Number|"Infinity"|"auto"
   */
  @published var duration = 'auto';

  /**
   * "none", "forwards", "backwards", "both" or "auto". When set to
   * "auto", the fill is "none" for a polymer-animation and "both"
   * for a polymer-animation-group.
   * valid values "none"|"forwards"|"backwards"|"both"|"auto"
   */
  @published String fill = 'auto';

  /**
   * A transition timing function.
   * @property easing
   * valid values "linear"|"ease"|"ease-in"|"ease-out"|"ease-in-out"|
   *     "step-start"|"step-middle"|"step-end"
   */
  @published String easing = 'linear';

  /**
   * Number of iterations into the timed item in which to begin
   * the animation. e.g. 0.5 will cause the animation to begin
   * halfway through the first iteration.
   */
  @published double iterationStart = 0.0;

  /**
   * -1 == infinity
   */
  @published int iterationCount = 1;

  /**
   * Delay in milliseconds.
   */
  @published int delay = 0;

  /**
   * valid values "normal"|"reverse"|"alternate"|"alternate-reverse"
   */
  @published String direction = 'normal';

  @published bool autoplay = false;

  dom.Animation anAnimation;
  dom.Player _player;
  Attributes attrs;


  void keyframesChanged(old) {
    apply();
  }

  void sampleChanged(old) {
    apply();
  }

  void compositeChanged(old) {
    apply();
  }

  void durationChanged(old) {
    apply();
  }

  void fillChanged(old) {
    apply();
  }

  void easingChanged(old) {
    apply();
  }

  void iterationCountChanged(old) {
    apply();
  }

  void delayChanged(old) {
    apply();
  }

  void directionChanged(old) {
    apply();
  }

  void autoplayChanged(old) {
    apply();
  }

  @override
  void enteredView() {
    super.enteredView();
    apply();
  }

  /**
   * Plays the animation.
   */
  dom.Player play() {
    apply();
    if (anAnimation != null && !autoplay) {
      this.bindAnimationEvents();
      _player = dom.document.timeline.play(anAnimation);
      print('play: $anAnimation, ${anAnimation.player}');
      anAnimation.player.play();
      return anAnimation.player;
    }
    return null;
  }

  /**
   * Stops the animation.
   */
  void cancel() {
    if(_player != null) {
      _player.source = null;
    }
  }

  bool hasTarget() {
    return target != null;
  }

  dom.Animation apply() {
    anAnimation = null;
    anAnimation = makeAnimation();
    if (autoplay && anAnimation) {
      play();
    }
    return anAnimation;
  }

  dom.Animation makeSingleAnimation(target) {
    // XXX(yvonne): for selecting all the animated elements.
    target.classes.add('polymer-animation-target');
    print(animationEffect);
    print(timingProps);
    var a = new dom.Animation(target, animationEffect, timingProps);
    print(a);
    return a;
  }

  dom.Animation makeAnimation() {
    // this.target && console.log('makeAnimation target', this.target, 'animation', this.animationEffect, 'timing', this.timingProps);
    if (this.target == null) {
      return null;
    }
    var animation;
    if (target is List) {
      var array = [];
      target.children.forEach((t) {
        array.add(this.makeSingleAnimation(t));
      }); // TODO .bind(this));
      anAnimation = new dom.Animation(target, array); // TODO verify if that is translated correctly
    } else {
      anAnimation = makeSingleAnimation(this.target);
    }
    return anAnimation;
  }

  void anAnimationChanged() {
    // TODO: attributes are not case sensitive.
    // TODO: Sending 'this' with the event because if the children is
    // in ShadowDOM the sender becomes the shadow host.
    this.fire('polymer-animation-change', detail: this);
  }

  void targetSelectorChanged() {
    if (targetSelector != null && targetSelector.isNotEmpty) {
      target = findTarget(targetSelector, this);
    }
  }

  void targetChanged(old) {
    apply();
    if (old != null) {
      (old as dom.HtmlElement).classes.remove('polymer-animation-target');
    }
  }

  Map get timingProps {
    var props = {};
    var timing = {
      'fill': {},
      'easing': {},
      'delay': {'isNumber': true},
      'iterationCount': {'isNumber': true, 'allowInfinity': true},
      'direction': {},
      'duration': {'isNumber': true}
    };

    for (var t in timing.keys) {
      if (attrs[t] != null) {
        var name = t;
        if(timing[t] is Map && (timing[t] as Map).containsKey('property')) {
          t = timing[t]['property'];
        }
        props[name] = timing[t] is num && attrs[t] != 'auto' ?
            toNumber(attrs[t], timing[t].allowInfinity) : attrs[t];
      }
    }
    return props;
  }

  List<Map> get animationEffect {
    var props = {};
    var frames = [];
    var effect;
    if (keyframes != null) {
      frames = keyframes;
    } else if (sample == null) {
      var children = this.querySelectorAll('polymer-animation-keyframe');
      if (children.length == 0) {
        children = this.shadowRoot.querySelectorAll('polymer-animation-keyframe');
      }
      children.forEach((c) {
        frames.add(c.properties);
      });
    }
    if (sample != null) {
      effect = [{'sample': sample}];
    } else {
      effect = []; //new KeyframeEffect(frames, this.composite); // seems to be a simple list of maps [{'offset': 0.2, 'left' '50px'} {}], offset can be omitted
    }
    return effect;
  }

  async.StreamSubscription _animationStartSubscription;
  async.StreamSubscription _animationEndSubscription;

  void bindAnimationEvents() {
    if (_animationStartSubscription == null) {
      _animationStartSubscription = dom.window.onAnimationStart.listen(animationStartHandler);
    }
    if (_animationEndSubscription == null) {
      _animationEndSubscription = dom.window.onAnimationEnd.listen(animationEndHandler);
    }
  }

  void animationStartHandler(dom.AnimationEvent event) {
    this.fire('polymer-animation-start');
  }

  void animationEndHandler(dom.AnimationEvent event) {
    this.fire('polymer-animation-end');
  }
}

class Attributes {
  PolymerAnimation elem;
  Attributes(this.elem);
  dynamic operator [](String key) {
    switch(key) {
      case 'fill':  return elem.fill;
      case 'easing': return elem.easing;
      case 'delay': return elem.delay;
      case 'iterationCount': return elem.iterationCount;
      case 'direction': return elem.direction;
      case 'duration': return elem.duration;
      default: throw 'Unsupported attribute: $key';
    }
  }
}
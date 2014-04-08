// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_overlay;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:polymer/polymer.dart';

/**
 * polymer-overlay displays overlayed on top of other content. It starts
 * out hidden and is displayed by setting it's opened property to true.
 * A polymer-overlay's opened state can be toggled by calling the toggle
 * method.
 *
 * It's common to want a polymer-overlay to animate to its opened
 * position. A number of helper css classes provide some basic open/close
 * animations. For example, assigning the class polymer-overlay-fade to a
 * polymer-overlay will make it fade into and out of view as it opens and
 * closes. Note, if multiple polymer-overlay's are opened, they should
 * stack on top of each other.
 *
 * Styling: The size and position of a polymer-overlay should be setup
 * via css.
 * polymer-overlay is natually sized around its content. When a
 * polymer-overlay is opened it is shown and the 'opened' class is added
 * to it. This is typically where css transitions and animations are
 * applied. When the polymer-overlay is closed, the 'opened' class is
 * removed and a 'closing' class is added. Use 'closing' to customize
 * the closing animation.
 *
 * Classes for animating polymer-overlay:
 *
 * * polymer-overlay-fade: fade in/out when opened/closed
 * * polymer-overlay-scale-slideup: open: fade in and shrink;
 * close: slide up
 * * polymer-overlay-shake: open: fly in and shake; close: shake and
 * fly out.
 *
 * It's common to use polymer-overlay to gather user input, for example
 * a login dialog. To facilitate this, polymer-overlay supports automatic
 * focusing of a specific element when it's opened. The element to be
 * focused should be given an autofocus attribute.
 *
 * An element that should close the polymer-overlay will automatically
 * do so if it is given the overlay-toggle attribute. Please note that
 * polymer-overlay will close whenever the user taps outside it or
 * presses the escape key. The behavior can be turned off via the
 * autoCloseDisabled property.
 *
 *     <div>
 *       <polymer-overlay></polymer-overlay>
 *       <h2>Dialog</h2>
 *       <input placeholder="say something..." autofocus>
 *       <div>I agree with this wholeheartedly.</div>
 *       <button overlay-toggle>OK</button>
 *     </div>
 *
 * @class polymer-overlay
 */
/**
 * Fired when the polymer-overlay opened property is set.
 *
 * @event polymer-overlay-open
 * @param {Object} inDetail
 * @param {Object} inDetail.opened the opened state
 */
@CustomTag('polymer-overlay')
class PolymerOverlay extends PolymerElement {

  PolymerOverlay.created(): super.created();

  // track overlays for z-index and focus managemant
  static final List overlays = [];
  static void trackOverlays(PolymerOverlay inOverlay) {
    if (inOverlay.opened) {
      //var overlayZ = window.getComputedStyle(inOverlay.target).zIndex;
      //var z0 = Math.max(currentOverlayZ(), overlayZ);
      var z0 = currentOverlayZ();
      overlays.add(inOverlay);
      var z1 = currentOverlayZ();
      if (z1 <= z0) {
        applyOverlayZ(inOverlay, z0);
      }
    } else {
      var i = overlays.indexOf(inOverlay);
      if (i >= 0) {
        overlays.remove(inOverlay);
        setZ(inOverlay, null);
      }
    }
  }

  static void applyOverlayZ(PolymerOverlay inOverlay, int inAboveZ) {
    setZ(inOverlay.target, inAboveZ + 2);
  }

  static void setZ(dom.HtmlElement inNode, int inZ) {
    inNode.style.zIndex = inZ.toString();
  }

  static PolymerOverlay currentOverlay() {
    if (overlays.length == 0) {
      return null;
    }
    return overlays[overlays.length - 1];
  }

  static var DEFAULT_Z = 10;

  static int currentOverlayZ() {
    var z;
    var current = currentOverlay();
    if (current != null) {
      var z1 = current.target.getComputedStyle().zIndex;
      try {
        z = num.parse(z1);
      } catch (e) {}
    }
    if (z != null) {
      return z;
    } else {
      return DEFAULT_Z;
    }
  }

  static void focusOverlay() {
    var current = currentOverlay();
    if (current != null) {
      current.applyFocus();
    }
  }



  /**
   * The target element.
   */
  @published
  dom.HtmlElement target;

  /**
   * Set opened to true to show an overlay and to false to hide it.
   * A polymer-overlay may be made intially opened by setting its
   * opened attribute.
   */
  @published
  bool opened = false;

  /**
   * By default an overlay will close automatically if the user
   * taps outside it or presses the escape key. Disable this
   * behavior by setting the autoCloseDisabled property to true.
   */
  @published
  bool autoCloseDisabled = false;

  /**
   * This property specifies the animation to play when the overlay is
   * opened/closed. It can be an array of two animations
   * [opening, closing], a single animation, an array of two strings, or
   * a string. The strings should the tag names of custom elements
   * descending from a polymer-animation. In the case of a single
   * animation the closing animation is the opening animation played
   * backwards.
   * @type polymer-animation
   * @type Array&lt;polymer-animation>
   * @type string
   * @type Array&lt;string>
   */
  @published
  List transitions = null;

  int _timeout = 1000;
  String _captureEventType = 'click'; //'tap';

  void ready() {
    if (this.tabIndex == null) {
      this.tabIndex = -1;
    }
    this.setAttribute('touch-action', 'none');
  }

  void enteredView() {
    super.enteredView();
    this.installControllerStyles();
  }

  /**
   * Toggle the opened state of the overlay.
   * @method toggle
   */
  void toggle() {
    this.opened = !this.opened;
  }

  void targetChanged(old) {
    if (this.target != null) {
      if (this.target.tabIndex == null) {
        this.target.tabIndex = -1;
      }
      this.target.classes.add('polymer-overlay');
      this.addListeners(this.target);
    }
    if (old != null) {
      old.classes.remove('polymer-overlay');
      this.removeListeners(old);
    }
  }

  //  Map listeners = {
  //    'tap': 'tapHandler',
  //    'keydown': 'keydownHandler'
  //  };

  async.StreamSubscription tapSubscription;
  async.StreamSubscription keydownSubscription;

  void addListeners(dom.HtmlElement node) {
    tapSubscription = node.onClick.listen(tapHandler);
    keydownSubscription = node.onKeyDown.listen(keydownHandler);
  }

  void removeListeners(dom.HtmlElement node) {
    tapSubscription.cancel();
    tapSubscription = null;

    keydownSubscription.cancel();
    keydownSubscription = null;
  }

  void openedChanged() {
    this.renderOpened();
    trackOverlays(this);
    new async.Future(() {
      if (!this.autoCloseDisabled) {
        this.enableCaptureHandler(this.opened);
      }
    });
    this.enableResizeHandler(this.opened);
    this.fire('polymer-overlay-open', detail: this.opened);
  }

  //  void enableHandler(bool inEnable, String inMethodName, dom.HtmlElement inNode, String inEventName, [bool inCapture = false]) {
  //    var m = 'bound' + inMethodName;
  //    this[m] = this[m] || this[inMethodName].bind(this);
  //
  //    inNode[inEnable ? 'addEventListener' : 'removeEventListener'](
  //      inEventName, this[m], inCapture);
  //  }

  async.StreamSubscription resizeSubscription;
  void enableResizeHandler(bool inEnable) {
    if (inEnable) {
      if (resizeSubscription != null) return;
      resizeSubscription = dom.window.onResize.listen(resizeHandler);
    } else {
      if (resizeSubscription == null) return;
      resizeSubscription.cancel();
      resizeSubscription = null;
    }
  }

  async.StreamSubscription captureSubscription;

  void enableCaptureHandler(bool inEnable) {
    if (inEnable) {
      if (captureSubscription != null) return;
      dom.GlobalEventHandlers.clickEvent.forTarget(dom.document, useCapture:
          true).listen(captureHandler);
      //captureSubscription = dom.document.onClick.listen(captureHandler);
    } else {
      if (captureSubscription == null) return;
      captureSubscription.cancel();
      captureSubscription = null;
    }
  }

  dom.HtmlElement getFocusNode() {
    var t = this.target.querySelector('[autofocus]');
    return t != null ? t : this.target;
  }

  // TODO(sorvell): nodes stay focused when they become un-focusable
  // due to an ancestory becoming display: none; file bug.
  void applyFocus() {
    var focusNode = this.getFocusNode();
    if (this.opened) {
      focusNode.focus();
    } else {
      focusNode.blur();
      focusOverlay();
    }
  }

  void positionTarget() {
    if (this.opened) {
      // vertically and horizontally center if not positioned
      var computedStyle = target.getComputedStyle();
      if (computedStyle.top == 'auto' && computedStyle.bottom == 'auto') {
        this.target.style.top =
            '${((dom.window.innerHeight - this.target.getBoundingClientRect().height) / 2)}px';
      }
      if (computedStyle.left == 'auto' && computedStyle.right == 'auto') {
        this.target.style.left =
            '${((dom.window.innerWidth - this.target.getBoundingClientRect().width) / 2)}px';
      }
    }
  }

  void resetTargetPosition() {
    this.target.style.top = this.target.style.left = null;
  }

  get transition {
    return (this.transitions is! List && this.transitions != null || this.opened
        && this.transitions != null && this.transitions[0] != null || !this.opened &&
        this.transitions != null && this.transitions[1] != null);
  }

  void applyTransition() {
    var animation = this.transition is String ? dom.document.createElement(
        this.transition) : this.transition;
    // FIXME: Apply a default duration.
    if ((!animation.duration || animation.duration == 'auto') &&
        !animation.type) {
      animation.duration = 0.3;
    }
    if (!animation.hasTarget()) {
      animation.target = this.target;
    }
    // Make the overlay visible while the animation is running.
    var transition = new dom.Animation(target, [
        // TODO verify if this is translated correctly
      animation.apply(), new dom.Animation(this.target, [{
          'visibility': 'visible',
          'display': 'block'
        }])], {
      'fill': 'none'
    });

    dom.window.onAnimationEnd.listen(completeOpening);
    //transition['onend'] = this.completeOpening;
    this.target.classes.add('animating');
    dom.document.timeline.play(transition);
  }

  void renderOpened() {
    this.target.classes.add('revealed');
    // continue styling after delay so display state can change
    // without aborting transitions
    new async.Future(continueRenderOpened);
  }

  void continueRenderOpened() {
    this.positionTarget();
    if (this.transition) {
      this.applyTransition();
      // FIXME: Apply the class after the animation starts playing to
      // prevent a flicker at the end of the animation. Should be handled
      // in polymer-animation-start event but not working in polyfill
      new async.Future.delayed(new Duration(milliseconds: 100), () {
        this.target.classes.toggle('opened', this.opened);
      });
    } else {
      this.target.classes.toggle('opened', this.opened);
      new async.Future(() => completeOpening(null));
    }
  }

  void completeOpening(dom.AnimationEvent e) {
    this.target.classes.remove('animating');
    this.target.classes.toggle('revealed', this.opened);
    if (!this.opened) {
      this.resetTargetPosition();
    }
    this.applyFocus();
  }

  void tapHandler(dom.MouseEvent e) {
    if (e.target != null && (e.target as
        dom.HtmlElement).attributes.containsKey('overlay-toggle')) {
      this.toggle();
    } else {
      if (this.autoCloseJob != null) {
        this.autoCloseJob.cancel();
        this.autoCloseJob = null;
      }
    }
  }

  async.Timer autoCloseJob;
  // TODO(sorvell): This approach will not work with modal. For
  // this we need a scrim.
  void captureHandler(dom.MouseEvent e) {
    if (!this.autoCloseDisabled && (currentOverlay() == this) && (this !=
        e.target) && !(this.contains(e.target))) {
      // TODO (zoechi) seems to work // this.autoCloseJob = this.job(this.autoCloseJob, () {
      autoCloseJob = new async.Timer(Duration.ZERO, () {
        this.opened = false;
      });
    }
  }

  void keydownHandler(dom.KeyboardEvent e) {
    if (!this.autoCloseDisabled && (e.keyCode == dom.KeyCode.ESC)) {
      this.opened = false;
      e.stopPropagation();
      e.preventDefault();
    }
  }

  /**
   * Extensions of polymer-overlay should implement the resizeHandler
   * method to adjust the size and position of the overlay when the
   * browser window resizes.
   * @method resizeHandler
   */
  void resizeHandler(dom.Event e) {
  }
}

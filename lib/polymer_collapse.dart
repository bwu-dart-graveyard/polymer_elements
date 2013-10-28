// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * polymer-collapse is used to add collapsible behavior to the
 * target element.  It adjusts the height or width of the target element
 * to make the element collapse and expand.
 *
 * Example:
 *
 *     <button on-click="{{toggle}}">toggle collapse</button>
 *     <div id="demo">
 *       ...
 *     </div>
 *     <polymer-collapse id="collapse" targetId="demo"></polymer-collapse>
 *
 *     ...
 *
 *     toggle() {
 *       this.$.collapse.toggle();
 *     }
 *
 */

library polymer.elements.polymer_collapse;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('polymer-collapse')
class PolymerCollapse extends PolymerElement {
 
  PolymerCollapse.created() : super.created();
  
  /**
   * The id of the target element.
   */
  @published
  String targetId = '';
  /**
   * The target element.
   */
  @published
  Element target =  null;
  
  /**
   * If true, the orientation is horizontal; otherwise is vertical.
   */
  @published
  bool horizontal = false;
  /**
   * If true, the target element is hidden/collapsed.
   */
  @published
  bool closed = false;
  
  /**
   * Collapsing/expanding animation duration in second.
   */
  @published
  
  double duration = 0.33;
  /**
   * If true, the size of the target element is fixed and is set
   * on the element.  Otherwise it will try to 
   * use auto to determine the natural size to use
   * for collapsing/expanding.
   */
  @published
  bool fixedSize = false;
  
  @published
  double size =  null;
  
  bool _inDocument;
  
  bool _afterInitialUpdate;
  
  bool _isTargetReady;
  
  var transitionEndListener;
  
  String _hasClosedClass;
  
  String _dimension;
  
  enteredView() {
    //TODO port styles.js to dart
   // this.installControllerStyles();
    this._inDocument = true;
    this.async((_) {
      this._afterInitialUpdate = true;
    });
  }
  
  leftView() {
    this._removeListeners(this.target);
  }
  
  targetIdChanged(old) {
    var p = this.parentNode;
    while (p.parentNode) {
      p = p.parentNode;
    }
    this.target = p.querySelector('#' + this.targetId);
  }
  
  targetChanged(old) {
    if (old) {
      this._removeListeners(old);
    }
    this.horizontalChanged();
    //TODO What is this?
    this._isTargetReady = !!this.target;
    if (this.target != null) {
      this.target.style.overflow = 'hidden';
      this._addListeners(this.target);
      // set polymer-collapse-closed class initially to hide the target
      this._toggleClosedClass(true);
    }
    // don't need to update if the size is already set and it's opened
    if (!this.fixedSize || !this.closed) {
      this._update();
    }
  }
  
  _addListeners(node) {
    this.transitionEndListener = this.transitionEndListener != null ? this.transitionEndListener : 
        this._transitionEnd;
    node.addEventListener('webkitTransitionEnd', this.transitionEndListener);
    node.addEventListener('transitionend', this.transitionEndListener);
  }
  
  _removeListeners(node) {
    node.removeEventListener('webkitTransitionEnd', this.transitionEndListener);
    node.removeEventListener('transitionend', this.transitionEndListener);
  }
  
  horizontalChanged(old) {
    this._dimension = this.horizontal ? 'width' : 'height';
  }
  
  closedChanged() {
    this._update();
  }
  
  /** 
   * Toggle the closed state of the collapsible.le
   */
  toggle() {
    this.closed = !this.closed;
  }
  
  setTransitionDuration(duration) {
    var s = this.target.style;
    s.transitionDuration= s.transition == duration ? 
        (this._dimension + ' ' + duration + 's') : null;
    if (duration == 0) {
      //TODO polymer.js has an asynchronous method dispatch, not sure if this
      //is an appropriate replacement
      this.async((_){
        _transitionEnd();
      });
    }
  }
  
  _transitionEnd() {
    if (!this.closed && !this.fixedSize) {
      this._updateSize('auto', null, false);
    }
    this.setTransitionDuration(null);
    this._toggleClosedClass(this.closed);
  }
  
  _toggleClosedClass(add) {
    this._hasClosedClass = add;
    this.target.classes.toggle('polymer-collapse-closed', add);
  }
  
  _updateSize(size, duration, forceEnd) {
    if (duration != null) {
      this._calcSize();
    }
    this.setTransitionDuration(duration);
    var s = this.target.style;
    var nochange = s.getPropertyValue(this._dimension) == size;
    s.setProperty(this._dimension, size);
    // transitonEnd will not be called if the size has not changed
    if (forceEnd && nochange) {
      this._transitionEnd();
    }
  }
  
  _update() {
    if (this.target == null|| !this._inDocument) {
      return;
    }
    if (!this._isTargetReady) {
      this.targetChanged(null); 
    }
    this.horizontalChanged(null);
    if(this.closed){
      hide();
    }else {
      show();
    }
  }
  
  _calcSize() {
    if(this._dimension == 'width'){
      return this.target.getBoundingClientRect().width+'px';
    }
    return this.target.getBoundingClientRect().height+'px';
  }
  
  _getComputedSize() {
    if(this._dimension == 'width'){
      return this._getComputedSize().width+'px';
    }
    return this._getComputedSize().height+'px';
  }
  
  show() {
    this._toggleClosedClass(false);
    // for initial update, skip the expanding animation to optimize
    // performance e.g. skip calcSize
    if (!this._afterInitialUpdate) {
      this._transitionEnd();
      return;
    }
    if (!this.fixedSize) {
      this._updateSize('auto', null, false);
      var s = this._calcSize();
      this._updateSize(0, null, false);
    }
    //TODO Polymer.js has an async method dispatch.  Is this the right replacement?
    this.async((_) {
      this._updateSize(this.size || s, this.duration, true);
    });
  }
  
  hide() {
    // don't need to do anything if it's already hidden
    if (this._hasClosedClass && !this.fixedSize) {
      return;
    }
    if (this.fixedSize) {
      // save the size before hiding it
      this.size = this._getComputedSize();
    } else {
      this._updateSize(this._calcSize(), null, false);
    }
    this.async((_) {
      this._updateSize(0, this.duration, false);
    });
  }

  
}
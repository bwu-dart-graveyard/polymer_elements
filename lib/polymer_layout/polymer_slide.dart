// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_slide;

import 'dart:async' show Timer;
import 'dart:html' show Element, Node;
import 'package:logging/logging.dart' show Logger;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, published,
  ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved https://code.google.com/p/dart/issues/detail?id=15095

@CustomTag('polymer-slide')
class PolymerSlide extends PolymerElement {
  PolymerSlide.created() : super.created();
  
  final _logger = new Logger('polymer-slide');

  @published bool closed = false;
  @published bool open = true;
  @published bool vertical = false;
  @published String targetId = '';
  @published Element target;
  
  @override
  void ready() {
    super.ready();
    this.setAttribute('nolayout', '');
  }
  
  @override
  void enteredView() {
    super.enteredView();
    this.target = this.parentNode;
  }
  
  void targetIdChanged(oldValue) {
    var p = this.parentNode;
    while (p.parentNode != null) {p = p.parentNode;};
    this.target = p.querySelector('#' + this.targetId);
  }
  
  void targetChanged() {
    if (this.closed) {
      new Timer(Duration.ZERO, this.update);
    }
  }
  
  void toggle() {
    this.open = !this.open;
  }
  
  void closedChanged(oldValue) {
    this.open = !this.closed;
  }
  
  void openChanged() {
    new Timer(Duration.ZERO, this.update);
  }
  
  void update() {
    this.closed = !this.open;
    if (this.target != null) {
      if (this.vertical) {
        if (this.target.style.top != '') {
          this.updateTop();
        } else {
          this.updateBottom();
        }
      } else {
        if (this.target.style.left != '') {
          this.updateLeft();
        } else {
          this.updateRight();
        }
      }
    }
  }
  
  void updateLeft() {
    var w = this.target.offsetWidth;
    var l = this.open ? 0 : -w;
    this.target.style.left = '${l}px';
    var s = this.target.nextElementSibling;
    while (s != null) {
      if (!s.attributes.containsKey('nolayout')) {
        if (s.style.left == '' && s.style.right != '') {
          break;
        }
        l += w;
        s.style.left = '${l}px';
        w = s.offsetWidth;
      }
      s = s.nextElementSibling;
    }
  }
  
  void updateRight() {
    var w = this.target.offsetWidth;
    var r = this.open ? 0 : -w;
    this.target.style.right = '${r}px';
    //var s = this.target.previousElementSibling;
    var s = _previousElementSibling(this.target);
    while (s != null) {
      if (!s.attributes.containsKey('nolayout')) {
        if (s.style.right == '' && s.style.left != '') {
          break;
        }
        r += w;
        s.style.right = '${r}px';  
        w = s.offsetWidth;
      }
      //if (s == s.previousElementSibling) {
      //  console.error(s.localName + ' is its own sibling', s);
      //  break;
      //}
      //s = s.previousElementSibling;
      s = _previousElementSibling(s);
    }
  }
  
  void updateTop() {
    var h = this.target.offsetHeight;
    var t = this.open ? 0 : -h;
    this.target.style.top = '${t}px';
    var s = this.target.nextElementSibling;
    while (s != null) {
      if (!s.attributes.containsKey('nolayout')) {
        if (s.style.top == '' && s.style.bottom != '') {
          break;
        }
        t += h;
        s.style.top = t + 'px';
        h = s.offsetHeight;
      }
      s = s.nextElementSibling;
    }
  }
  
  void updateBottom() {
    var h = this.target.offsetHeight;
    var b = this.open ? 0 : -h;
    this.target.style.bottom = '${b}px';
    //var s = this.target.previousElementSibling;
    var s = _previousElementSibling(this.target);
    while (s != null) {
      if (!s.attributes.containsKey('nolayout')) {
        if (s.style.bottom == '' && s.style.top != '') {
          break;
        }
        b = b + h;
        s.style.bottom = '${b}px';  
        h = s.offsetHeight;
      }
      //if (s == s.previousElementSibling) {
      //  console.error(s.localName + ' is its own sibling', s);
      //  break;
      //}
      //s = s.previousElementSibling;
      s = _previousElementSibling(s);
    }
  }

    // TODO(sjmiles): temporary workaround for b0rked property in ShadowDOMPolyfill
  Element _previousElementSibling(Element e) {
    do {
      e = e.previousElementSibling;
    } while (e != null && e.nodeType != Node.ELEMENT_NODE);
    return e;
  }
}
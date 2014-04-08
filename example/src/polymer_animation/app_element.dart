// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library app_element;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_animation/polymer_animation.dart' as anim;

@CustomTag('app-element')
class AppElement extends PolymerElement {

  AppElement.created(): super.created();

  void sampleAnimationFn(int timeFraction, int currentIteration, dom.HtmlElement
      animationTarget, underlyingValue) {
    if (timeFraction < 1) {
      animationTarget.text = timeFraction.toString();
    } else {
      animationTarget.text = 'animated!';
    }
  }

  @override
  void enteredView() {
    super.enteredView();
    shadowRoot.querySelector('.animations').onClick.listen((e) {
      print(e.target.toString());
      var animation = (e.target as anim.PolymerAnimation);
      if (animation.id == 'sample-animation') {
        animation.sample = sampleAnimationFn;
      }
      animation.target = $['target'];
      print('Target: ${animation.target}');
      animation.play();
    });
    shadowRoot.querySelector('polymer-fadeout').on['complete'].listen((e) {
      dom.window.alert('complete!');
    });
  }
}

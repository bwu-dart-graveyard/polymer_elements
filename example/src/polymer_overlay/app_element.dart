// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library app_element;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart';
import 'x_dialog.dart';


@CustomTag('app-element')
class AppElement extends PolymerElement {

  @observable
  List entries;

  @observable bool confirmation = false;
  @observable bool isModal = false;
  @observable bool isScrim = false;
  @observable String inputSomething = '';

  AppElement.created() : super.created();

  void inputSomethingChanged(old) {
    confirmation = inputSomething == 'something';
  }

  dom.HtmlElement dialog;

  void changeOpening(dom.Event e, detail, dom.HtmlElement target) {
    var s = (target as dom.SelectElement).selectedOptions[0];
    if (s != null) {
      var d = $['dialog'];
      d.classes.toList().forEach((c) {
        if(c.startsWith('polymer-') && c != 'polymer-overlay') {
          d.classes.remove(c);
        }
      });
      d.classes.add(s.text);
    }
  }

  @override
  void enteredView() {
    var overlayButtons = shadowRoot.querySelectorAll('button[overlay]');

    overlayButtons.forEach((b) {
      (b as dom.ButtonElement).onClick.listen((e) {
        (shadowRoot.querySelector(e.target.getAttribute('overlay')) as XDialog).toggle();
      });
    });
  }
}
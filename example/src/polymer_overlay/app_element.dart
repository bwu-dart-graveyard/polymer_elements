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

  AppElement.created() : super.created();

  void somethingCheck(dom.Event e) {
    (shadowRoot.querySelector('#confirmation') as XDialog).opened = (e.target.value == 'something');
  }

  var dialog;

  void changeOpening(dom.Event e) {
    var s = e.target.selectedOptions[0];
    if (s) {
      dialog.className = dialog.className.replace(new RegExp('polymer-[^\s]*'), '');
      dialog.classList.add(s.textContent);
    }
  }

  void modalChange(dom.Event e) {
    dialog.autoCloseDisabled = e.target.checked;
  }

  void scrimChange(dom.Event e) {
    dialog.scrim = e.target.checked;
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
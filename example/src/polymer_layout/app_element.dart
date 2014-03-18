// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library polymer_elements.polymer_layout.example.app_element;

import 'dart:html';
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement;
import 'package:polymer_elements/polymer_layout/polymer_slide.dart' show PolymerSlide;

@CustomTag('app-element')
class AppElement extends PolymerElement {
  AppElement.created() : super.created();

  void toggle(event, detail, HtmlElement target) {
    var s = ($[target.attributes['data-target']] as PolymerSlide);
    s.closed = !s.closed;
  }
}
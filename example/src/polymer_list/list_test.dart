// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library polymer_elements.polymer_list.example.list_test;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart' show CustomTag, observable, PolymerElement, toObservable;

@CustomTag('list-test')
class ListTest extends PolymerElement {
  ListTest.created() : super.created();

  @observable List<String> data;

  void ready() {
    super.ready();
    var data = [];
    for (var i = 0, o; i < 50000; i++) {
      o = {'index': i};
      if ((i + 1) % 10 == 0) {
        o['header'] = 'Header';
      }
      data.add(o);
    }
    this.data = toObservable(data);
  }

  void selectAction(dom.Event e, detail, dom.HtmlElement target) {
    //this.data[detail['item']].selected = detail['isSelected'] != null ? 'polymer-selected' : '';
    //this.$['list'].refresh();
  }
}

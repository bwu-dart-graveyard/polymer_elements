// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library polymer_elements.polymer_grid_layout.grid_test;

import 'dart:html' show ContentElement, Element;
import 'package:observe/observe.dart' show ObservableList;
import 'package:logging/logging.dart' show Logger;
import 'package:polymer/polymer.dart' show CustomTag, observable, PolymerElement, published,
  ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved
// https://code.google.com/p/dart/issues/detail?id=13849

@CustomTag('grid-test')
class GridTest extends PolymerElement {
  GridTest.created() : super.created();

  final _logger = new Logger('grid-test');

  @published List<int> layout;
  @published ObservableList<Element> xnodes;


  List<List<int>> _arrangements =
    [[
      [1, 1, 1],
      [2, 3, 4],
      [2, 3, 5]
    ], [
      [4, 3, 2],
      [5, 3, 2],
      [5, 1, 1]
    ], [
      [1, 1],
      [2, 3],
      [4, 3]
    ]];

  @observable int outputLayout = 0;

  @override
  void enteredView() {
    super.enteredView();
    this.xnodes = new ObservableList<Element>.from(this.shadowRoot.children.where(
        (Element e) => e.localName != 'polymer-grid-layout' && e.localName != 'style'));
    this.outputLayoutChanged(null);
  }

  void outputLayoutChanged(old) {
    this.layout = this._arrangements[this.outputLayout];
  }

  void toggleLayout() {
    this.outputLayout = (this.outputLayout + 1) % this._arrangements.length;
  }
}

// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.
library polymer_elements.polymer_template_list;

import 'dart:html' as dom;
import 'package:polymer/polymer.dart' show CustomTag, observable, PolymerElement, published,
ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved
// https://code.google.com/p/dart/issues/detail?id=13849
// (https://code.google.com/p/dart/issues/detail?id=15095)
import 'package:logging/logging.dart' show Logger;
import 'polymer_virtual_list.dart' show PolymerVirtualList;

@CustomTag('polymer_template_list')
class PolymerTemplateList extends PolymerVirtualList {
  PolymerTemplateList.created() : super.created();

  final _logger = new Logger('polymer_template_list');

  @published List data = [];
  @published dom.TemplateElement template;

  @override
  void enteredView() {
    super.enteredView();
  }

  @override
  void reset() {
    if(this.data != null) {
      super.reset(); // [data.length]
    }
  }

  void dataChanged(old) {
    reset();
  }

  void templateChanged(old) {
    reset();
  }

  @override
  void generatePageContent(dom.DivElement page, int start, int end) {
    super.generatePageContent(page, start, end);
    var data = this.data.sublist(start, end);
    if(data.length > 0 && this.template != null) {
      for(var i = 0; i < data.length; i++) {
        page.append(template.createFragment(data[i], validator: new dom.NodeValidatorBuilder.common()));
      }
    }
  }
}
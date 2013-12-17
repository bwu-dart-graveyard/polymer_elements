// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_collapse_toggle;

import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

import 'polymer_collapse.dart';

@CustomTag('polymer-collapse-toggle')
class PolymerCollapseToggle extends PolymerElement {
  PolymerCollapseToggle.created() : super.created();

  final _logger = new Logger('PolymerCollapseButton');

  /**
   * The selector for the target polymer-collapse element.
   */
  @published PolymerCollapse target;
  
  void handleClick([e]) {
    if (target != null) {
      target.toggle();
    }else {
      print('t is null!!!');
    }
  }
}

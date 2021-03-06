// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library flex_container;

//import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_flex_layout/polymer_flex_panel.dart';

// Polymer has issues with inheriance when noscript is used
// remove when solved
@CustomTag('flex-container')
class FlexContainer extends PolymerFlexPanel {
  FlexContainer.created() : super.created();
}

// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library x_dialog;

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_overlay/polymer_overlay.dart';

@CustomTag('x-dialog')
class XDialog extends PolymerElement {

  @published
  bool opened;
  @published bool autoCloseDisabled;

  XDialog.created() : super.created();

  void ready() {
    ($['overlay'] as PolymerOverlay).target = this;
  }

  void toggle() {
    ($['overlay'] as PolymerOverlay).toggle();
  }
}
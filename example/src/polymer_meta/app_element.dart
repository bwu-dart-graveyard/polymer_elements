// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library app_element;

import 'dart:html';
import 'package:template_binding/template_binding.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_meta/polymer_meta.dart' show PolymerMeta;

@CustomTag('app-element')
class AppElement extends PolymerElement {

  @published
  List metadata;

  AppElement.created() : super.created();

  ready(){
    var meta = document.createElement('polymer-meta');
   metadata = meta.list;
   var archetype = (meta.byId('x-zot') as PolymerMeta).archetype;

   document.body.append(templateBind(archetype).createInstance().querySelector('*'));
  }
}
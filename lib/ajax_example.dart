// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library polymer.elements.polymer_ajax_example;

import 'package:polymer/polymer.dart';

@CustomTag('ajax-example')
class AjaxExample extends PolymerElement {
  
  @observable
  List entries;
  
  AjaxExample.created() : super.created();
  
  responseReceived(e, detail, node){
    entries = detail['response']['feed']['entry'];   
  }
  
}
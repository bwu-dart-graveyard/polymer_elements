// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library polymer.elements.selection_example;

import 'package:polymer/polymer.dart';
    
@CustomTag('selection-example')
class SelectionExample extends PolymerElement {
      
  SelectionExample.created() : super.created();
  
  //Note: Have to use dom listeners here to workaround 
  //https://code.google.com/p/dart/issues/detail?id=14457
  enteredView(){
    this.$dom_addEventListener('click',itemTapAction);
  }
  
  leftView(){
    this.$dom_removeEventListener('click', itemTapAction);
  }
      
  itemTapAction(e) {
    this.$['selection'].select(e.target);
  }

  selectAction(e, detail, target) {
    detail.item.classes.toggle('selected', detail.isSelected);
  }
      
   
  
  
  
}
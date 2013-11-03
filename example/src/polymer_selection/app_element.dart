// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_selection.app_element;

import 'package:polymer/polymer.dart';
    
@CustomTag('app-element')
class AppElement extends PolymerElement {
      
  AppElement.created() : super.created();
  
  //Note: Have to use dom listeners here to workaround 
  //https://code.google.com/p/dart/issues/detail?id=14457
  enteredView(){
    super.enteredView();
    this.addEventListener('click',itemTapAction);
  }
  
  leftView(){
    this.removeEventListener('click', itemTapAction);
    super.leftView();
  }
      
  itemTapAction(e) {
    this.$['selection'].select(e.target);
  }

  selectAction(e, detail, target) {
    detail['item'].classes.toggle('selected', detail['isSelected']);
  }
      
   
  
  
  
}
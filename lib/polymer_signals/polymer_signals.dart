// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 


library polymer_elements.polymer_signals;

import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('polymer-signals')
class PolymerSignals extends PolymerElement {
  
  PolymerSignals.created() : super.created();
  
      enteredView() {
        _signals.add(this);
      }
      
      leftView() {
        _signals.remove(this);
      }
}
   
// private shared database
List _signals = [];
// signal dispatcher
_notify(name, data) {
  // convert generic-signal event to named-signal event
  var signal = new CustomEvent('polymersignal' + name, 
    canBubble: true,
    detail: data    
  );
  // dispatch named-signal to all 'signals' instances,
  // only interested listeners will react
  _signals.forEach((s) {
    s.dispatchEvent(signal);  
  });    
}
    

@initMethod
registerListener(){
// signal listener at document
  document.addEventListener('polymer-signal', (e) {
    _notify(e.detail['name'], e.detail['data']);
  });
}
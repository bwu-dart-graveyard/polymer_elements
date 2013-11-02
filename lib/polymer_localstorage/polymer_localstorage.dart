// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer.elements.polymer_localstorage;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

@CustomTag('polymer-localstorage')
class PolymerLocalstorage extends PolymerElement {
  
  /**
   * The key to the data stored in localStorage.
   */
  @published String name;
  
  /**
   * The data associated with the specified name.
   */
  @published var value;

  /**
   * If true, the value is stored and retrieved without JSON processing.
   */
  @observable bool useRaw = false;

  /**
   * If true, auto save is disabled.
   */
  @observable bool autoSaveDisabled = false;
  
  bool loaded = false;
  
  PolymerLocalstorage.created() : super.created();
  
  final _logger = new Logger('polymer-localstorage');

  @override
  void enteredView() {
    super.enteredView();
    print('polymer-localstorage inserted');
    
    // let the bindings complete, so run this async
    // TODO: should we use runAsync here?
    scheduleMicrotask(load);
  }

  valueChanged(oldValue) {
    if (loaded && !this.autoSaveDisabled) {
      this.save();
    }
  }
  
  void load() {
    var s = window.localStorage[name];
    if (s != null && !useRaw) {
      try {
        value = JSON.decode(s);
      } catch (x) {
        value = s;
      }
    } else {
      value = s;
    }
    loaded = true;
    // TODO this.asyncFire('polymer-localstorage-load');
  }

  
  void save() {
    window.localStorage[name] = useRaw ? value : JSON.encode(this.value);
  }
  
}
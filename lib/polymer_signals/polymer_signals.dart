// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_elements.polymer_signals;

import 'dart:html';

import 'package:polymer/polymer.dart';
import '../src/interfaces.dart';

@CustomTag('polymer-signals')
class PolymerSignals extends PolymerElement {

  PolymerSignals.created() : super.created();

  void enteredView() {
    super.enteredView();
    _signals.add(this);
  }

  void leftView() {
    _signals.remove(this);
    super.leftView();
  }
}

// private shared database
List _signals = [];

// signal dispatcher
void _notify(name, data) {
  // convert generic-signal event to named-signal event
  var signal = new CustomEvent('polymer-signal-' + name, canBubble: true, detail:
      data);

  // workaround for http://stackoverflow.com/questions/22821638
  var l = _signals.toList(growable: false);
  // dispatch named-signal to all 'signals' instances,
  // only interested listeners will react
  l.forEach((s) {
    s.dispatchEvent(signal);
  });
}


@initMethod
void registerListener() {
  const INVALID_MAP_ERROR = "If 'detail' is a Map then it must contain an entry with key 'name' with a value of type 'String' and an entry with key 'data' and a value of arbitrary type.";
  const NAME_KEY = 'name';
  const DATA_KEY = 'data';

  // signal listener at document
  document.addEventListener('polymer-signal', (e) {
    if(e.detail is Map) {
      var d = e.detail as Map;

      if(!d.containsKey(NAME_KEY)) {
        throw INVALID_MAP_ERROR;
      }
      _notify(d[NAME_KEY], e.detail[DATA_KEY]);
    } else if (e.detail is EventNameProvider) {
      _notify((e.detail as EventNameProvider).polymerEventName, e.detail);
    } else {
      throw "The Provided detail is invalid. ${INVALID_MAP_ERROR} Other types must implement 'EventNameProvider'.";
    }
  });
}



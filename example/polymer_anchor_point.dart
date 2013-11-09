// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library main;

import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

final _logger = new Logger('main');
main() {
  _logger.finest('main');
  
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.FINEST;
  //Logger.root.onRecord.listen((e) => print(e));
  
  initPolymer();
}

@initMethod
_init() {

}



library main;

//import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

//@initMethod
main() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.FINEST;

  //Logger.root.onRecord.listen((e) => print(e)); 
  initPolymer();
}
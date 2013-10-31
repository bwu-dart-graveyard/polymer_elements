library main;

import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

final _logger = new Logger('main');
main() {
  _logger.finest('main');
  
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((e) => print(e));
  
  initPolymer();
}

@initMethod
_init() {

}



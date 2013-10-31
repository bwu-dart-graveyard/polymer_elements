library main;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

//import 'package:polymer_elements/polymer_anchor_point/polymer_anchor_point.dart';

final _logger = new Logger('main');

@initMethod
init() {
  _logger.finest('main');
  
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((e) => print(e));
  
  initPolymer();
  
  var sampleAnimationFn = (timeFraction, currentIteration, animationTarget, underlyingValue) {
    if (timeFraction < 1) {
      animationTarget.textContent = timeFraction;
    } else {
      animationTarget.textContent = 'animated!';
    }
  };

  document.on['WebComponentsReady'].listen((_) {
    document.querySelector('.animations').onClick.listen((e) {
      var animation = e.target;
      if (animation.id == 'sample-animation') {
        // TODO animation.sample = sampleAnimationFn;
      }
      // TODO animation.target = target;
      animation.play();
    });
    document.querySelector('polymer-fadeout').addEventListener(
        'complete', (e) {
          window.alert('complete!');
        });
  });  
}
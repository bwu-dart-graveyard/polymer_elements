library polymer_overlay_scale;

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_animation/polymer_animation.dart';

@CustomTag('polymer-overlay-scale')
class PolymerOverlayScale extends PolymerAnimation {
  PolymerOverlayScale.created() : super.created() {
    duration = 0.218;
// TODO    properties = {
//      'opacity': ['0', '1'],
//      'transform': ['scale(1.05)', 'scale(1)']};
  }
}
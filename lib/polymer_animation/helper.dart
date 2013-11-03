// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_animation.helper;

class Observe {
  Observe({this.target, this.keyframes, this.sample, this.composite, this.duration, this.fillMode, this.easing, this. iterationCount, this.delay, this.direction, this.autoplay});
  
  String target = 'apply';
  String keyframes = 'apply';
  String sample = 'apply';
  String composite = 'apply';
  String duration = 'apply';
  String fillMode = 'apply';
  String easing = 'apply';
  String iterationCount = 'apply';
  String delay = 'apply';
  String direction = 'apply';
  String autoplay = 'apply';
}
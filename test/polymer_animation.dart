// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


library polymer_ajax.test;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'src/polymer_animation/polymer_transition_hslide_scale_out.dart';

@initMethod
void init() {
  useHtmlEnhancedConfiguration();

  test('polymer-animation', () {
    var done = expectAsync(() {});
    var a = (dom.document.querySelector('transition-hslide-scale-out') as
        PolymerTransitionHslideScaleOut);
    a.target = dom.querySelector('div');

    new async.Future.delayed(new Duration(milliseconds: 50));
    a.play();
    done();
  });
}


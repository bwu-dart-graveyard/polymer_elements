// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library app_element;

import 'dart:html';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_anchor_point/polymer_anchor_point.dart'
    show PolymerAnchorPoint;

@CustomTag('app-element')
class AppElement extends PolymerElement {
  final _logger = new Logger('app-element');

  AppElement.created(): super.created();
  @override
  void enteredView() {
    super.enteredView();
    querySelector('#tmptoggle1').onClick.listen((e) => toggle(e));
    querySelector('#tmptoggle2').onClick.listen((e) => toggle(e));
    querySelector('#target').onClick.listen((e) => toggle(e));
    querySelector('#tmptogglecustom1').onClick.listen((e) => toggleCustom(e));
  }

  void toggle(e) {
    _logger.finest('toggle');

    var anchorable = (document.querySelector('#anchorable') as
        PolymerAnchorPoint);
    var target = document.querySelector('#target');
    var anchor = e.target;
    if (target.classes.contains('active')) {
      target.classes.remove('active');
    } else {
      var targetAnchorPt = anchor.getAttribute('target-anchor-point');
      if (targetAnchorPt == null || targetAnchorPt.isEmpty) {
        return;
      }
      target.attributes['anchor-point'] = targetAnchorPt;
      target.innerHtml = 'anchor-point: ' + anchor.getAttribute('anchor-point')
          + '<br>' + 'target anchor-point: ' + targetAnchorPt;
      anchorable.target = target;
      anchorable.anchor = anchor;
      target.classes.add('active');
      anchorable.apply();
    }
  }

  void toggleCustom(e) {
    _logger.finest('toggleCustom');

    var anchorable = document.querySelector('#anchorable');
    var target = document.querySelector('#target');
    var anchor = e.target;
    if (target.classes.contains('active')) {
      target.classes.remove('active');
    } else {
      var anchorPt = (document.querySelector('#customAnchorPt') as
          InputElement).value;
      anchor.setAttribute('anchor-point', anchorPt);
      var targetAnchorPt = (document.querySelector('#customTargetAnchorPt') as
          InputElement).value;
      target.attributes['anchor-point'] = targetAnchorPt;
      target.innerHtml = 'anchor-point: ' + anchorPt + '<br>' +
          'target anchor-point: ' + targetAnchorPt;
      anchorable.target = target;
      anchorable.anchor = anchor;
      target.classes.add('active');
      anchorable.apply();
    }
  }
}

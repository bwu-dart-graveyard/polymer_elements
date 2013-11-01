library app_element;

import 'dart:html';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_anchor_point/polymer_anchor_point.dart';

@CustomTag('app-element')
class AppElement extends PolymerElement {
  final _logger = new Logger('app-element');
  
  AppElement.created() : super.created();
  
  void toggle(e) {
    _logger.finest('toggle');
    
    PolymerAnchorPoint anchorable = document.querySelector('#anchorable');
    var target = document.querySelector('#target');
    var anchor = e.target;
    if (target.classes.contains('active')) {
      target.classes.remove('active');
    } else {
      var targetAnchorPt = anchor.getAttribute('target-anchor-point');
      target.attributes['anchor-point'] = targetAnchorPt;
      target.innerHtml = 'anchor-point: ' + anchor.getAttribute('anchor-point') + '<br>' + 'target anchor-point: ' + targetAnchorPt;
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
      var anchorPt = (document.querySelector('#customAnchorPt') as InputElement).value;
      anchor.setAttribute('anchor-point', anchorPt);
      var targetAnchorPt = (document.querySelector('#customTargetAnchorPt') as InputElement).value;
      target.attributes['anchor-point'] = targetAnchorPt;
      target.innerHtml = 'anchor-point: ' + anchorPt + '<br>' + 'target anchor-point: ' + targetAnchorPt;
      anchorable.target = target;
      anchorable.anchor = anchor;
      target.classes.add('active');
      anchorable.apply();
    }
  }  
}
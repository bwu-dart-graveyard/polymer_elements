// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

/**
 * polymer-anchor-point can be used to align two nodes. The node to
 * use as the reference position is the anchor node, and the node to
 * be positioned is the target node.
 *
 * Both the anchor and target nodes should have an anchor-point
 * attribute. The target node is positioned such that its anchor-point
 * aligns with the anchor node's anchor-point.
 *
 * Note: The target node is positioned with position: fixed, and will not
 * scroll with the page.
 *
 * Note: This is meant to polyfill the `<dialog>` positioning behavior when
 * an anchor is provided. Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/commands.html#the-dialog-element
 *
 * Example:
 *
 *     <div id="anchor" anchor-point="bottom left"></div>
 *     <div id="target" anchor-point="top left"></div>
 *     <polymer-anchor-point id="anchor-helper"></polymer-anchor-point>
 *     <script>
 *       var helper = document.querySelector('#anchor-helper');
 *       helper.anchor = document.querySelector('#anchor');
 *       helper.target = document.querySelector('#target');
 *       helper.apply();
 *     </script>
 *
 */

library polymer_elements.polymer_anchor_point;

import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

@CustomTag('polymer-anchor-point')
class PolymerAnchorPoint extends PolymerElement {
  PolymerAnchorPoint.created() : super.created();

  static const DEFAULT_ANCHOR_POINT = 'center center';

  final _logger = new Logger('PolymerAnchorPoint');
  
  /**
   * The node to be positioned.
   */
  @published HtmlElement target = null;
  
  /**
   * The node to align the target to.
   */
  @published HtmlElement anchor = null;

  bool canPosition() {
    _logger.finest('canPosition');
    
    return (this.target != null && this.anchor != null); 
  }
  
  void apply() {
    _logger.finest('apply');
    
    if (!this.canPosition()) {
      return;
    }
    
    Point pos = this.computePosition();
    this.target.style.position = 'fixed';
    this.target.style.top = '${pos.y}px';
    this.target.style.left = '${pos.x}px';
  }
  
  Point computePosition() {
    _logger.finest('computePosition');
    
    var rect = this.anchor.getBoundingClientRect();
    var anchorPt = getAnchorPoint(this.anchor);
    var anchorOffset = computeAnchorOffset(rect, anchorPt);
    var targetRect = this.target.getBoundingClientRect();
    var targetAnchorPt = getAnchorPoint(this.target);
    var targetOffset = computeAnchorOffset(targetRect, targetAnchorPt);
    var pos = new Point(
      rect.left + anchorOffset.x - targetOffset.x,
      rect.top + anchorOffset.y - targetOffset.y
    );
    return pos;
  }
  
  
  String getAnchorPoint(HtmlElement node) {
    _logger.finest('getAnchorPoint');
    
    String anchorPt = node.attributes['anchor-point'];
    if (anchorPt == null || anchorPt.isEmpty || anchorPt == 'none') {
      anchorPt = DEFAULT_ANCHOR_POINT;
    }
    return anchorPt;
  }
  
  bool lengthIsPx(String length) {
    _logger.finest('lengthIsPx');
    
    return length.endsWith('px');
  }
  
  bool lengthIsPercent(String length) {
    _logger.finest('lengthIsPercent');
    
    return length.endsWith('%');
  }

  double computeLength(String length, double ref) {
    _logger.finest('computeLength');
    
    double computed = 0.0;
    if(lengthIsPx(length)) {
      computed = this._extractNumber(length).toDouble();
    } else if(lengthIsPercent(length)) {
      int l = this._extractNumber(length);
      computed = ref * l / 100;
    }
    return computed;
  }
  
  int _extractNumber(String value) {
    _logger.finest('_extractNumber');
    
    String digits = new RegExp(r"^-?(\d+).*$").firstMatch(value).group(1);
    return int.parse(digits);
  }
  
  bool partIsX(String part) {
    _logger.finest('partIsX');
    
    return part == 'left' || part == 'right' || part == 'center';
  }
  
  bool partIsY(String part) {
    _logger.finest('partIsY');
    
    return part == 'top' || part == 'bottom' || part == 'center';
  }
  
  bool partIsKeyword(String part) {
    _logger.finest('partIsKeyword');
    
    return !part.endsWith('%') && !part.endsWith('px'); 
  }
  
  Position parsePosition(String position) {
    _logger.finest('parsePosition');
    
    var parsed = new Position();
    
    List<String> parts = position.split(' ');
    int i = 0;
    bool lastEdgeX = true;
    do {
      if(partIsX(parts[i])) {
        parsed.x = parts[i];
        lastEdgeX = parts[i] != 'center';
      } else if (partIsY(parts[i])) {
        parsed.y = parts[i];
        lastEdgeX = false;
      } else if (lastEdgeX) {
        parsed.xOffset = parts[i];
        lastEdgeX = false;
      } else {
        parsed.yOffset = parts[i];
      }
    } while (++i < parts.length);
    return parsed;
  }
  
  Point computeAnchorOffset(Rectangle<double> rect, String anchorPt) {
    _logger.finest('computeAnchorOffset');
    
    var offset = new Point(0, 0);
    Position parsed = parsePosition(anchorPt);
    if((parsed.x == null || parsed.x.isEmpty) && 
        (parsed.xOffset == null || parsed.xOffset.isEmpty)) {
      offset = new Point(rect.width / 2, offset.y);
    } else if (parsed.x != null && parsed.x.isNotEmpty && 
        (parsed.xOffset == null || parsed.xOffset.isEmpty)) {
      switch(parsed.x) {
        case 'left':
          offset = new Point(0, offset.y);
          break;
          
        case 'right':
          offset = new Point(rect.width, offset.y);
          break;
          
        case 'center':
          offset = new Point(rect.width / 2, offset.y);
          break;
      }
    } else {
      double computed = computeLength(parsed.xOffset, rect.width);
      if(parsed.x == 'right') {
        offset.x = new Point(rect.width - computed, offset.y);
      } else if (parsed.x == null || parsed.x.isEmpty || parsed.x == 'left') {
        offset = new Point(computed, offset.y);
      }
    }
    
    if((parsed.y == null || parsed.y.isEmpty) && 
        (parsed.yOffset == null || parsed.yOffset.isEmpty)) {
      offset = new Point(offset.x, rect.height / 2);
    } else if (parsed.y != null && parsed.y.isNotEmpty && 
        (parsed.yOffset == null || parsed.yOffset.isEmpty)) {
      switch(parsed.y) {
        case 'top':
          offset = new Point(offset.x, 0);
          break;
          
        case 'bottom':
          offset = new Point(offset.x, rect.height);
          break;
          
        case 'center':
          offset = new Point(offset.x, rect.height / 2);
          break;
      }
    } else {
      double computed = computeLength(parsed.yOffset, rect.height);
      if(parsed.y == 'bottom') {
        offset = new Point(offset.x, rect.height - computed);
      } else if (parsed.y == null || parsed.y.isEmpty || parsed.y == 'top') {
        offset = new Point(offset.x, computed);
      }
    }
    
    return offset;
  }
}

class Position {
  String x, y, xOffset, yOffset;
}



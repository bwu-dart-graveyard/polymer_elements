// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_layout;

import 'dart:async' show Timer;
import 'dart:html' show CssStyleDeclaration, Element, Node;
import 'package:logging/logging.dart' show Logger;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, published,
  ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved https://code.google.com/p/dart/issues/detail?id=15095

/**
 * `<polymer-layout>` arranges nodes horizontally via absolution positioning.
 * Set the `vertical` attribute (boolean) to arrange vertically instead.
 * 
 * `<polymer-layout>` arranges it's <b>sibling elements</b>, not
 * it's children.
 *
 * One arranged node may be marked as elastic by giving it a `flex`
 * attribute (boolean).
 *
 * You may remove a node from layout by giving it a `nolayout`
 * attribute (boolean).
 * 
 * CSS Notes:
 *
 *  * `padding` is ignored on the parent node.
 *  * `margin` is ignored on arranged nodes.
 *  * `min-width` is ignored on arranged nodes, use `min-width` on the parent node
 *    instead.
 *
 * Example: 
 *
 * Arrange three `div` into columns. `flex` attribute on Column Two makes that
 * column elastic.
 *
 *      <polymer-layout></polymer-layout>
 *      <div>Column One</div>
 *      <div flex>Column Two</div>
 *      <div>Column Three</div>
 *
 *  Remember that `<polymer-layout>` arranges it's sibling elements, not it's children.
 *
 * If body has width 52 device pixels (in this case, ascii characters), call that 52px.
 * Column One has it's natural width of 12px (including border), Column Three has it's
 * natural width of 14px, body border uses 2px, and Column Two automatically uses the
 * remaining space: 24px.
 *
 *      |-                    52px                        -| 
 *      ----------------------------------------------------
 *      ||Column One||      Column Two      ||Column Three||
 *      ----------------------------------------------------
 *       |-  12px  -||-     (24px)         -||    14px   -|
 *
 * As the parent node resizes, the elastic column reacts via CSS to adjust it's size.
 * No javascript is used during parent resizing, for best performance. 
 *
 * Changes in content or sibling size is not handled automatically. 
 *
 *      ----------------------------------------------------------------
 *      ||Column One|             Column Two             |Column Three||
 *      ----------------------------------------------------------------
 *
 *      --------------------------------------
 *      ||Column One|Column Two|Column Three||
 *      --------------------------------------
 *
 * Arrange in rows by adding the `vertical` attribute.
 *
 * Example:
 *
 *      <polymer-layout vertical></polymer-layout>
 *      <div>Row One</div>
 *      <div flex>Row Two</div>
 *      <div>Row Three</div>
 *
 * This setup will cause Row Two to stretch to fill the container.
 *
 *      -----------             -----------
 *      |---------|             |---------|
 *      |         |             |         |
 *      |Row One  |             |Row One  |
 *      |         |             |         |
 *      |---------|             |---------|
 *      |         |             |         |
 *      |Row Two  |             |Row Two  |
 *      |         |             |         |
 *      |---------|             |         |
 *      |         |             |         |
 *      |Row Three|             |         |
 *      |         |             |---------|
 *      |---------|             |         |
 *      -----------             |Row Three|
 *                              |         |
 *                              |---------|
 *                              |---------|
 *
 * Layouts can be nested arbitrarily.
 *
 *      <polymer-layout></polymer-layout>
 *      <div>Menu</div>
 *      <div flex>
 *         <polymer-layout vertical></polymer-layout>
 *         <div>Title</div>
 *         <div>Toolbar</div>
 *         <div flex>Main</div>
 *         <div>Footer</div>
 *      </div>
 *
 * Renders something like this
 *
 *      --------------------------------
 *      ||Menu     ||Title            ||
 *      ||         ||-----------------||
 *      ||         ||Toolbar          ||
 *      ||         ||-----------------||
 *      ||         ||Main             ||
 *      ||         ||                 ||
 *      ||         ||-----------------||
 *      ||         ||Footer           ||
 *      --------------------------------
 */
@CustomTag('polymer-layout')
class PolymerLayout extends PolymerElement {
  PolymerLayout.created() : super.created();
  
  final _logger = new Logger('polymer-layout');

  @published bool vertical = false;
  
  @override
  void ready() {
    super.ready();
    this.setAttribute('nolayout', '');
  }
  
  @override
  void enteredView() {
    super.enteredView();
    new Timer(Duration.ZERO, () {
      this.prepare();
      this.layout();
    });
  }
  
  void prepare() {
    var parent = this.parent;
    // may recalc
    var cs = parent.getComputedStyle(); // window.getComputedStyle(parent);
    if (cs.position == 'static') {
      parent.style.position = 'relative';
    }
    //parent.style.overflow = 'hidden';
    // changes will cause another recalc at next validation step
    var vertical;
    int i = 0;
    for(Element c in this.parent.children) {
      if (c.nodeType == Node.ELEMENT_NODE && !c.attributes.containsKey('nolayout')) {
        stylize(c, {
          'position': 'absolute',
          'boxSizing': 'border-box',
          //MozBoxSizing: 'border-box',
        });
        // test for auto-vertical
        if (vertical == null) {
          vertical = (c.offsetWidth == 0 && c.offsetHeight != 0);
        }
      }
      i++;
    };
    this.vertical = this.vertical || vertical;
  }
  /**
   * Arrange sibling nodes end-to-end in one dimension.
  *
   * Arrangement is horizontal unless the `vertical`
   * attribute is applied on this node.
  *
   * @method layout
   */
  void layout() {
    var parent = this.parentNode;
    var vertical = this.vertical;
    var ww = 0, hh = 0;
    var pre = new List<Map<String,dynamic>>();
    Element fit;
    var post = new List<Map<String,dynamic>>();
    var list = pre;
    // gather element information (at most one recalc)
    int i = 0;
    this.parent.children.forEach((c) {
      if (c.nodeType == Node.ELEMENT_NODE && !c.attributes.containsKey('nolayout')) {
        var info = {
                    'element': c,
                    'w': c.offsetWidth,
                    'h': c.offsetHeight
        };
        if (!c.attributes.containsKey('fit') && !c.attributes.containsKey('flex')) {
          ww += c.offsetWidth;
          hh += c.offsetHeight;
          list.add(info);
        } else {
          fit = c;
          list = post;
          ww = 0; 
          hh = 0;
        }
      }
      i++;
    });
    // update layout styles (invalidate, no recalc)
    var v = 0;
    var mxp = 0, myp = 0;
    pre.forEach((info) {
      if (vertical) {
        stylize(info['element'], {
          'top': '${v}px', 'right': mxp, 'height': '${info['h']}px', 'left': mxp
        });
      } else {
        stylize(info['element'], {
          'top': myp, 'width': '${info['w']}px', 'bottom': myp, 'left': '${v}px'
        });
      }
      vertical ? v += info['h'] : v += info['w'];
    });
    if (fit != null) {
      if (vertical) {
        stylize(fit, {
          'top': '${v}px', 'right': mxp, 'bottom': '${hh}px', 'left': mxp
        });
      } else {
        stylize(fit, {
          'top': myp, 'right': '${ww}px', 'bottom': myp, 'left': '${v}px'
        });
      }
      vertical ? v = hh : v = ww;
      post.forEach((info) {
        vertical ? v -= info['h'] : v -= info['w'];
        if (vertical) {
          stylize(info['element'], {
            'height': '${info['h']}px', 'right': mxp, 'bottom': '${v}px', 'left': mxp
          });
        } else {
          stylize(info['element'], {
            'top': myp, 'right': '${v}px', 'bottom': myp, 'width': '${info['w']}px'
          });
        }
      });
    }
  }

  void stylize(Element element, Map<String,String> styles) {
    var style = element.style;
    styles.keys.forEach((k){
      style.setProperty(k, styles[k].toString());
    });
  }
}
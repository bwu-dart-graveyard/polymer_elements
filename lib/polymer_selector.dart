// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * polymer-selector is used to manage a list of elements that can be selected.
 * The attribute "selected" indicates which item element is being selected.
 * The attribute "multi" indicates if multiple items can be selected at once.
 * Tapping on the item element would fire "polymer-activate" event. Use
 * "polymer-select" event to listen for selection changes.  
 * The [CustomEvent.detail] for "polymer-select" is set to
 * a [PolymerSelectDetail].
 *
 * Example:
 *
 *     <polymer-selector selected="0">
 *       <div>Item 1</div>
 *       <div>Item 2</div>
 *       <div>Item 3</div>
 *     </polymer-selector>
 *
 * polymer-selector is not styled.  So one needs to use "polymer-selected" CSS
 * class to style the selected element.
 * 
 *     <style>
 *       .item.polymer-selected {
 *         background: #eee;
 *       }
 *     </style>
 *     ...
 *     <polymer-selector>
 *       <div class="item">Item 1</div>
 *       <div class="item">Item 2</div>
 *       <div class="item">Item 3</div>
 *     </polymer-selector>
 *
 * The polymer-selector element fires a "polymer-select" event with an 
 * attached [PolymerSelectDetail] when an item's selection state is changed. 
*/

library polymer.elements.polymer_selector;

import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('polymer-selector')
class PolymerSelector extends PolymerElement {
  
  @published
  var selected = null;
  
  /**
   * If true, multiple selections are allowed.
   */
  
  @published
  bool multi = false;
  /**
   * Specifies the attribute to be used for "selected" attribute.
  */
  
  @published
  String valueattr = 'name';
  /**
   * Specifies the CSS class to be used to add to the selected element.
   */
  @published
  String selectedClass= 'polymer-selected';
  /**
   * Specifies the property to be used to set on the selected element
   * to indicate its active state.
  */
  @published
  String selectedProperty = 'active';
  /**
   * Returns the currently selected element. In multi-selection this returns
   * an array of selected elements.
   */
  @published
  var selectedItem = null;
  /**
   * In single selection, this returns the model associated with the
   * selected element.
  */
  @published
  var selectedModel = null;
  /**
   * The target element that contains items.  If this is not set 
   * polymer-selector is the container.
  */
  @published
  Node target=null;
  /**
   * This can be used to query nodes from the target node to be used for 
   * selection items.  Note this only works if the 'target' property is set.
  *
   * Example:
  *
   *     <polymer-selector target="{{$.myForm}}" itemsSelector="input[type=radio]"></polymer-selector>
   *     <form id="myForm">
   *       <label><input type="radio" name="color" value="red"> Red</label> <br>
   *       <label><input type="radio" name="color" value="green"> Green</label> <br>
   *       <label><input type="radio" name="color" value="blue"> Blue</label> <br>
   *       <p>color = {{color}}</p>
   *     </form>
   * 
  */
  @published
  String itemsSelector = '';
  /**
   * The event that would be fired from the item element to indicate
   * it is being selected.
  */
  @published
  String activateEvent= 'click';
  
  @published
  bool notap = false;
  
  PolymerSelector.created() : super.created();
  
  MutationObserver _observer;
  
  ready() {
    this._observer = new MutationObserver(_updateSelected);
    if (!this.target) {
      this.target = this;
    }
  }
  
//TODO revisit the polymer code - what does the where clause do?
  get items {
    
    List nodes;
    if(itemsSelector.isNotEmpty){
      nodes = target.querySelectorAll(this.itemsSelector);
    } else {
      nodes = target.children;
    }

    return nodes.where((Element e){
      return e.localName != 'template';
    }).toList();     
  }
  
  _updateSelected(){
    this._validateSelected();
    if (this.multi) {
      this.clearSelection();
      this.selected && this.selected.forEach(function(s) {
        this.valueToSelection(s);
      }, this);
    } else {
      this.valueToSelection(this.selected);
    }
  }
  
  _activateHandler(e) {
    if (!this.notap) {
      var i = this._findDistributedTarget(e.target, this.items);
      if (i >= 0) {
        var item = this.items[i];
        var s = this.valueForNode(item) || i;
        if (this.multi) {
          if (this.selected) {
            this.addRemoveSelected(s);
          } else {
            this.selected = [s];
          }
        } else {
          this.selected = s;
        }
        this.asyncFire('polymer-activate', detail: item);
      }
    }
  }
  
}
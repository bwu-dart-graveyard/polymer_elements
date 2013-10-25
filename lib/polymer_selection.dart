// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * The polymer-selection element is used to manage selection state. It has no
 * visual appearance and is typically used in conjunction with another element.
 * For example, <a href="polymer-selector.html">polymer-selector</a>
 * uses a polymer-selection to manage selection.
 *
 * To mark an item as selected, call the select(item) method on 
 * polymer-selection. Notice that the item itself is an argument to this method.
 * The polymer-selection element manages selection state for any given set of
 * items. When an item is selected, the `polymer-select` event is fired.
 * The attribute "multi" indicates if multiple items can be selected at once.
 * 
 * Example:
 *
 *     TODO
 *
 * The polymer-selection element fires the 'polymer-select' event with an 
 * attached [PolymerSelectDetail] when an item's selection state is changed. 
 * This event is fired both when an item is selected or deselected. 
 * 
*/

library polymer.elements.polymer_selection;

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/event_details.dart';

@CustomTag('polymer-selection')
class PolymerSelection extends PolymerElement {
  
  final List _selection = [];
  
  /**
   * If true, multiple selections are allowed.
   */
  
  @published
  bool multi = false;
  
  PolymerSelection.created() : super.created();
  
  /**
   * Retrieves the selected item(s). If the multi property is true,
   * selection will return a [List], otherwise it will return 
   * the selected item or null if there is no selection.
   */
  get selection {
    if(this.multi){
     return this._selection;
    } else if(this._selection.isNotEmpty){
      return this._selection[0];
    } else {
      return null;
    }
  }

  /**
   * Returns true if the given [item] is selected.
   */
  isSelected(item){
    return this.selection.indexOf(item) >= 0;
  }
  
  /**
   * Sets the selected state of [item] to [isSelected] and fires
   * a corresponding 'polymer-select' event with [PolymerSelectDetail] containing
   * the [PolymerSelectDetail.item] equal to [item] and [PolymerDetail.isSelected]
   * equal to [isSelected]. 
   */
  setItemSelected(item, isSelected) {
    if (item != null) {  
      if (isSelected) {
        this._selection.add(item);
      } else {
        var i = this._selection.indexOf(item);
        if (i >= 0) {
          this._selection.removeAt(i);
        }
      }     
 
      this.fire('polymer-select',detail: new PolymerSelectDetail(item, isSelected));
          
    }
  }
  /**
   * Set the selection state for a given [item]. If the multi property
   * is true, then the selected state of [item] will be toggled; otherwise
   * the [item] will be selected.  Fires a corresponding 'polymer-select' event 
   * with [PolymerSelectDetail] containing the [PolymerSelectDetail.item] equal 
   * to [item] and with the [PolymerDetail.isSelected] set to the new selection
   * state for the [item].
   */
  select(item) { 
    if (this.multi) {
      this._toggle(item);
    } else if (this.selection != item) {
      this.setItemSelected(this.selection, false);
      this.setItemSelected(item, true);
    }
  }
   
  ready(){
    this.clear();
  }
  
  clear(){
    this._selection.clear();
  }
  
  _toggle(item) {
    this.setItemSelected(item, !this.isSelected(item));
  }

  
}
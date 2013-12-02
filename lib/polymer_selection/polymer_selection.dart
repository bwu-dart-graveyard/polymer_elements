// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

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
 *     <polymer-element name="selection-example">
 *        <template>
 *          <style>
 *            ::-webkit-distributed(> .selected) {
 *              font-weight: bold;
 *              font-style: italic;
 *            }
 *          </style>
 *          <ul on-tap="{{itemTapAction}}">
 *            <content></content>
 *          </ul>
 *          <polymer-selection id="selection" multi on-polymer-select="{{selectAction}}"></polymer-selection>
 *        </template>
 *        <script>
 *          Polymer('selection-example', {
 *            itemTapAction: function(e) {
 *              this.$.selection.select(e.target);
 *            },
 *            selectAction: function(e, detail) {
 *              detail.item.classList.toggle('selected', detail.isSelected);
 *            }
 *          });
 *        </script>
 *     </polymer-element>
 *
 *     <selection-example>
 *       <li>Red</li>
 *       <li>Green</li>
 *       <li>Blue</li>
 *     </selection-example>
 *
 * The polymer-selection element fires a 'polymer-select' event when an item's 
 * selection state is changed. The [CustomEvent.detail] for the event is a map
 * containing 'item' and 'isSelected'.
 * 
*/

library polymer_elements.polymer_selection;

import 'package:polymer/polymer.dart';

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
   * Retrieves the selected item(s) (String or Element). If the multi property is true,
   * selection will return a [List], otherwise it will return fire
   * the selected item or null if there is no selection.
   */
  dynamic get selection {
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
  bool isSelected(item){
    if(this.selection == null) {
      return false;
    }
    return this.selection.indexOf(item) >= 0;
  }
  
  /**
   * Sets the selected state of [item] to [isSelected] and fires
   * a corresponding 'polymer-select' event with the [CustomEvent.detail] set to 
   * a map containing 'item' set to [item] and 'isSelected' set to [isSelected].
   */
  void setItemSelected(item, isSelected) {
    if (item != null) {  
      if (isSelected) {
        this._selection.add(item);
      } else {
        var i = this._selection.indexOf(item);
        if (i >= 0) {
          this._selection.removeAt(i);
        }
      }     

      this.fire('polymer-select',detail: {'item': item, 'isSelected':  isSelected});
          
    }
  }
  
  /**
   * Set the selection state for a given [item]. If the multi property
   * is true, then the selected state of [item] will be toggled; otherwise
   * the [item] will be selected.  Fires a corresponding 'polymer-select' event 
   * with the [CustomEvent.detail] set to a map containing 'item' set to [item] 
   * and 'isSelected' set to [isSelected]. set to the new selection state for 
   * the [item].
   */
  void select(item) { 
    if (this.multi) {
      this._toggle(item);
    } else if (this.selection != item) {
      this.setItemSelected(this.selection, false);
      this.setItemSelected(item, true);
    }
  }
   
  void ready(){
    super.ready();
    this.clear();
  }
  
  void clear(){
    this._selection.clear();
  }
  
  void _toggle(item) {
    this.setItemSelected(item, !this.isSelected(item));
  }
}

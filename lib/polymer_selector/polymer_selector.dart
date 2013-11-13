// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

/**
 * polymer-selector is used to manage a list of elements that can be selected.
 * The attribute 'selected' indicates which item element is being selected.
 * The attribute "multi" indicates if multiple items can be selected at once.
 * Tapping on the item element fires 'polymeractivate' event. Use the
 * 'polymerselect' event to listen for selection changes.  
 * The [CustomEvent.detail] for 'polymerselect' is a map containing 'item'
 * and 'isSelected'.
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
 * The polymer-selector element fires a 'polymerselect' event when an item's 
 * selection state is changed. The [CustomEvent.detail] for the event is a map
 * containing 'item' and 'isSelected'.
*/

library polymer_elements.polymer_selector;

import 'dart:async';
import 'dart:html';
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_selection/polymer_selection.dart' show PolymerSelection;

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
  
  /**  Stream<CustomEvent> get onPolymerSelect =>
      PolymerSelection._polymerSelectEvent.forTarget(this);
   * 
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
   * 
   * (egrimes) Note: Working around
   */
  @published
  Element target = null;
  
  /**
   * This can be used to query nodes from the target node to be used for 
   * selection items.  Note this only works if the 'target' property is set.
  *
   * Example:
  *
   *     <polymer-selector target="{ {$['myForm'] }}" itemsSelector="input[type=radio]"></polymer-selector>
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
  
  Stream<CustomEvent> get onPolymerSelect {
    PolymerSelection selection = $['selection'] as PolymerSelection;
    if(selection != null) {
      return selection.onPolymerSelect;
    }
  }
  
  ready() {
    this._observer = new MutationObserver(_onMutation);
    
    if (this.target == null) {
      this.target = this;
    }
  }
  
//TODO revisit the polymer code - what does the where clause do? 
  // => returns only the elements where the closure evaluates to true (where e.localName != 'template);
  get items {
    List nodes;
    if (this.target != this) {
      if (this.itemsSelector != null && this.itemsSelector.isNotEmpty) {
        nodes = this.target.querySelectorAll(this.itemsSelector);
      } else {
        nodes = this.target.children;
      }
    } else {
      nodes = (this.$['items'] as ContentElement).getDistributedNodes();
    }

    return nodes.where((Element e){
      return e != null && e.localName != 'template';
    }).toList();     
  }
  
  targetChanged(old) {
    if (old != null) {
      this._removeListener(old);
      this._observer.disconnect();
    }
    if (this.target != null) {
      this._addListener(this.target);
      this._observer.observe(this.target, childList: true);
    }
  }
  
  _addListener(node) {
    node.addEventListener(this.activateEvent, activateHandler);
  }
  
  _removeListener(node) {
    node.removeEventListener(this.activateEvent, activateHandler);
  }
  
  get selection {
    return this.$['selection'].selection;
  }
  
  selectedChanged(old){
    //(egrimes) Note: Workaround for https://code.google.com/p/dart/issues/detail?id=14496
    new Timer(Duration.ZERO, (){_updateSelected();});
    //this._updateSelected();
  }
  
  _onMutation(records, observer){
    _updateSelected();
  }
  
  _updateSelected(){
    this._validateSelected();
    if (this.multi) {
      this.clearSelection();
      if(this.selected != null){
        this.selected.forEach((s) {
          this._valueToSelection(s);
        });
      }
    } else {
      this._valueToSelection(this.selected);
    }
  }
  
  _validateSelected(){
    // convert to a list for multi-selection
    if (this.multi && this.selected != null && this.selected is! List) {
      this.selected = [this.selected];
    }
  }
  
  clearSelection() {
    if (this.multi) {
      var copy = new List.from(this.selection);
      copy.forEach((s) {
        this.$['selection'].setItemSelected(s, false);
      });
    } else {
      this.$['selection'].setItemSelected(this.selection, false);
    }
    this.selectedItem = null;
    this.$['selection'].clear();
  }
  
  _valueToSelection(value) {
    var item = (value == null) ? 
        null : this.items[this._valueToIndex(value)];
    this.$['selection'].select(item);
  }
  
  _updateSelectedItem() {
    this.selectedItem = this.selection;
  }
  
  selectedItemChanged(old){
    if (this.selectedItem != null) {
      //TODO Figure out why this doesn't work
      //var t = this.selectedItem.templateInstance;
      //this.selectedModel = t ? t.model : null;
    } else {
      this.selectedModel = null;
    }
  }
  
  _valueToIndex(value) {
    // find an item with value == value and return it's index
    for (var i=0, items=this.items; i< items.length; i++) {
      if (this._valueForNode(items[i]) == value) {
        return i;
      }
    }
    // if no item found, the value itself is probably the index
    return value;
  }
  
  _valueForNode(HtmlElement node) {
    var mirror = reflect(node);
    //TODO This is gross.  The alternative is to search the type heirarchy
    //for a matching variable or getter.
    try {
      return mirror.getField(new Symbol('${this.valueattr}')).reflectee;
    }catch(e){
      return node.attributes[this.valueattr]; 
    };
  }
  
  // events fired from <polymer-selection> object
  selectionSelect(e, detail, node) {
    this._updateSelectedItem();
    if (detail.containsKey('item')) {
      this._applySelection(detail['item'], detail['isSelected']);
    }
  }
  
  _applySelection(HtmlElement item, isSelected) {
    if (this.selectedClass != null) {
      item.classes.toggle(this.selectedClass, isSelected);
    }
    
    //(egrimes) Note: It looks like Polymer.js adds the property dynamically to 
    //the item. PolymerSelector defaults selectedProperty to 'active', so users 
    //will have to explicitly set selectedProperty to an empty string to keep 
    //from blowing up. I'm not sure that's reasoable.
    if (this.selectedProperty != null && this.selectedProperty.isNotEmpty) {
      reflect(item).setField(new Symbol('${this.selectedProperty}'), isSelected);
    }
  }
  
  activateHandler(e) {
    if (!this.notap) {
      var i = this._findDistributedTarget(e.target, this.items);
      if (i >= 0) {
        var item = this.items[i];
        var s = this._valueForNode(item);
        if(s == null){
          s = i;
        }
        if (this.multi) {
          if (this.selected != null) {
            this._addRemoveSelected(s);
          } else {
            this.selected = [s];
          }
        } else {
          this.selected = s;
        }
        this.asyncFire('polymeractivate', detail: item);
      }
    }
  }
  
  _addRemoveSelected(value) {
    int i = this.selected.indexOf(value);
    if (i >= 0) {
      this.selected.removeAt(i);
    } else {
      this.selected.add(value);
    }
    this._valueToSelection(value);
  }
  
  int _findDistributedTarget(target, nodes) {
    // find first ancestor of target (including itself) that
    // is in nodes, if any
    int i = 0;
    while (target != null && target != this) {
      i = nodes.indexOf(target);
      if (i >= 0) {
        return i;
      }
      target = target.parentNode;
    }
  }
  
}

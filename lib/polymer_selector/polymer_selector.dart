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
 * 'polymer-select' event to listen for selection changes.  
 * The [CustomEvent.detail] for 'polymer-select' is a map containing 'item'
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
 * The polymer-selector element fires a 'polymer-select' event when an item's 
 * selection state is changed. The [CustomEvent.detail] for the event is a map
 * containing 'item' and 'isSelected'.
*/

library polymer_elements.polymer_selector;

import 'dart:async';
import 'dart:html';
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
//import 'package:polymer_elements/polymer_selection/polymer_selection.dart' show PolymerSelection;

@CustomTag('polymer-selector')
class PolymerSelector extends PolymerElement {
  
  /**
   * Gets or sets the selected element.  Default to use the index
   * of the item element.
   *
   * If you want a specific attribute value of the element to be
   * used instead of index, set "valueattr" to that attribute name.
   *
   * Example:
   *
   *     <polymer-selector valueattr="label" selected="foo">
   *       <div label="foo"></div>
   *       <div label="bar"></div>
   *       <div label="zot"></div>
   *     </polymer-selector>
   *
   * In multi-selection this should be an array of values.
   *
   * Example:
   *
   *     <polymer-selector id="selector" valueattr="label" multi>
   *       <div label="foo"></div>
   *       <div label="bar"></div>
   *       <div label="zot"></div>
   *     </polymer-selector>
   *
   *     this.$.selector.selected = ['foo', 'zot'];
   *
   */  
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
   * In single selection, this returns the selected index.
   */
  int selectedIndex = -1;
  
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
  String activateEvent = 'click'; // TODO change to tap when pointerevents are supported
  
  @published
  bool notap = false;
  
  PolymerSelector.created() : super.created();
  
  MutationObserver _observer;
  
  Stream<CustomEvent> get onPolymerSelect {
    Element selection = $['selection'];
    if(selection != null) {
      // TODO return selection.onPolymerSelect;
    }
  }
  
  void ready() {
    super.ready();
    this._observer = new MutationObserver(_onMutation);
    
    if (this.target == null) {
      this.target = this;
    }
  }
  
  List<Element> get items {
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
  
  void targetChanged(old) {
    if (old != null) {
      this._removeListener(old);
      this._observer.disconnect();
    }
    if (this.target != null) {
      this._addListener(this.target);
      this._observer.observe(this.target, childList: true);
    }
  }
  
  void _addListener(node) {
    node.addEventListener(this.activateEvent, activateHandler);
  }
  
  void _removeListener(node) {
    node.removeEventListener(this.activateEvent, activateHandler);
  }
  
  dynamic get selection {
    return this.$['selection'].selection;
  }
  
  void selectedChanged(old){
    //(egrimes) Note: Workaround for https://code.google.com/p/dart/issues/detail?id=14496
    Timer.run(() =>_updateSelected());
    //this._updateSelected();
  }
  
  void _onMutation(records, observer){
    _updateSelected();
  }
  
  void _updateSelected(){
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
  
  void _validateSelected(){
    // convert to a list for multi-selection
    if (this.multi && this.selected != null && this.selected is! List) {
      this.selected = [this.selected];
    }
  }
  
  void clearSelection() {
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
  
  void _valueToSelection(value) {
    var item = (value == null) ? 
        null : this.items[this._valueToIndex(value)];
    this.$['selection'].select(item);
  }
  
  void _updateSelectedItem() {
    this.selectedItem = this.selection;
  }
  
  void selectedItemChanged(old){
    if (this.selectedItem != null) {
      //TODO Figure out why this doesn't work
      //var t = this.selectedItem.templateInstance;
      //this.selectedModel = t ? t.model : null;
    } else {
      this.selectedModel = null;
    }
    this.selectedIndex = (this.selectedItem != null) ?
        this._valueToIndex(this.selected) : 1;
  }
  
  int _valueToIndex(value) {
    // find an item with value == value and return it's index
    for (var i = 0, items = this.items; i < items.length; i++) {
      if (this._valueForNode(items[i]) == value) {
        return i;
      }
    }
    // if no item found, the value itself is probably the index
    if(value is int) {
      return value;
    }
    
    if(value is String) {
      return int.parse(value);
    }
    return -1;
  }
  
  // TODO set mirrorsused
  String _valueForNode(HtmlElement node) {
    var mirror = reflect(node);
    // TODO (zoechi) I think we could require that a published property (attribute) is used.
    // than we can drop reflection
    //TODO This is gross.  The alternative is to search the type heirarchy
    //for a matching variable or getter.
    try {
      return mirror.getField(new Symbol('${this.valueattr}')).reflectee;
    }catch(e){
      return node.attributes[this.valueattr]; 
    };
  }
  
  // events fired from <polymer-selection> object
  void selectionSelect(e, detail, node) {
    this._updateSelectedItem();
    if (detail.containsKey('item')) {
      this._applySelection(detail['item'], detail['isSelected']);
    }
  }
  
  // TODO set mirrorsused
  void _applySelection(HtmlElement item, bool isSelected) {
    if (this.selectedClass != null) {
      item.classes.toggle(this.selectedClass, isSelected);
    }
    
    //(egrimes) Note: It looks like Polymer.js adds the property dynamically to 
    //the item. PolymerSelector defaults selectedProperty to 'active', so users 
    //will have to explicitly set selectedProperty to an empty string to keep 
    //from blowing up. I'm not sure that's reasoable.
    if (this.selectedProperty != null && this.selectedProperty.isNotEmpty) {
      //Note: Reflection is required to work properly with checkboxes
      try {
          // polymer-ui-submenu-item works only with this
          reflect(item).setField(new Symbol('${this.selectedProperty}'), isSelected);
      } catch(e) { // required for polymer_ui_breadcrumbs (when an attribute is set on a DOM element
          if(isSelected) {
            item.attributes[this.selectedProperty] = isSelected.toString();
          } else {
            item.attributes.remove(this.selectedProperty);
          }
       }
    }
  }
  
  void activateHandler(e) {
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
        this.asyncFire('polymer-activate', detail: item);
      }
    }
  }
  
  void _addRemoveSelected(value) {
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
    return -1;
  }
}

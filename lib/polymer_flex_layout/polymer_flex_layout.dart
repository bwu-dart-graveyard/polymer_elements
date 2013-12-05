// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_flex_layout;

//import 'dart:async' show Timer;
import 'dart:html';
import 'package:polymer/polymer.dart';


/**
 * polymer-flex-layout provides a helper to use CSS3 Flexible Boxes.  By putting
 * polymer-flex-layout inside an element it makes the element a flex
 * container. Use 'flex' attribute to make the flex item flexible.
*
 * Example:
*
 *     <div>
 *       <polymer-flex-layout></polymer-flex-layout>
 *       <div>Left</div>
 *       <div flex>Main</div>
 *       <div>Right</div>
 *     </div>
*
 *     ---------------------------------
 *     |-------------------------------|
 *     ||Left|       Main       |Right||
 *     |-------------------------------|
 *     ---------------------------------
*
 *     <div>
 *       <polymer-flex-layout vertical></polymer-flex-layout>
 *       <div>Header</div>
 *       <div flex>Body</div>
 *       <div>Footer</div>
 *     </div>
*
 *     ----------
 *     ||------||
 *     ||Header||
 *     ||------||
 *     ||Body  ||
 *     ||      ||
 *     ||      ||
 *     ||      ||
 *     ||      ||
 *     ||      ||
 *     ||      ||
 *     ||------||
 *     ||Footer||
 *     ||------||
 *     ----------
*
 */
@CustomTag('polymer-flex-layout')
class PolymerFlexLayout extends PolymerElement {
  PolymerFlexLayout.created() : super.created();
  

  /**
   * If true, flex items are aligned vertically.
   */
  @published bool vertical = false;

  /**
   * Defines the default for how flex items are laid out along the cross axis on 
   * the current line.  Possible values are 'start', 'center' and 'end'.
   */
  @published String align = '';
  
  /**
   * Defines how flex items are laid out along the main axis on the current line.
   * Possible values are 'start', 'center' and 'end'.
   */

  @published String justify = '';
  
  /**
   * If true, polymer-flex-layout is the flex container.
  *
   * Example:
  *
   *     <polymer-flex-layout isContainer>
   *       <div>Left</div>
   *       <div flex>Main</div>
   *       <div>Right</div>
   *     </polymer-flex-layout>
  *
   *     ---------------------------------
   *     |-------------------------------|
   *     ||Left|       Main       |Right||
   *     |-------------------------------|
   *     ---------------------------------
   */
  @published bool isContainer = false;
  
  @observable HtmlElement layoutContainer = null;

  @override
  void enteredView() {
    super.enteredView();
    
    if(this.isContainer) {
      this.layoutContainer = this;
    } else {
      if (this.parent != null) {
        this.layoutContainer = this.parent;
      }
    }
 
    this.verticalChanged(null);
    this.alignChanged(null);
    this.justifyChanged(null);
    
    this.layoutContainerChanged(null); // TODO remove when @observable fires changed as it should);

      // TODO this should become redundant when the domspec is more complete
    // http://api.dartlang.org/docs/bleeding_edge/polymer/Polymer.html#installControllerStyles
    //this.installControllerStyles(); // TODO has a bug https://code.google.com/p/dart/issues/detail?id=14751   
  }
  
  @override
  void leftView() {
    super.leftView();
    this.layoutContainer = null;
  }

  void layoutContainerChanged(old) {
    if (old != null) {
      old.classes.remove('flexbox');
    }
    
    if (this.layoutContainer == this) {
      this.style.display = '';
    } else {
      this.style.display = 'none';
    }
    
    if (layoutContainer == this) {
      this.layoutContainer.classes.add('flexbox');
    } else {
      dispatchLayoutContainerClassChange({'add': 'flexbox'});
    }
  }

  void switchContainerClass(String prefix, String old, String name) {
    String o = old;
    if (o == null) {
      o = '';
    }
    
    if (name != null && name.isNotEmpty) {
      if(this.layoutContainer != null) {
        this.layoutContainer.classes.remove(prefix + o);
        this.layoutContainer.classes.add(prefix + name);
      } else {
        dispatchLayoutContainerClassChange({'remove': prefix + o, 'add': prefix + name});
      }
    }
  }

  void verticalChanged(old) {
    if (this.layoutContainer != null) {
      this.layoutContainer.classes.toggle('column', this.vertical);
    } else {
      dispatchLayoutContainerClassChange({(this.vertical ? 'add' : 'remove') : 'column'});
    }
  }
  
  void alignChanged(String old) {
    this.switchContainerClass('align-', old, this.align);
  }
  
  void justifyChanged(old) {
    this.switchContainerClass('justify-', old, this.justify);
  }
  
  void dispatchLayoutContainerClassChange(Map<String,String> detail) {
    if(this.layoutContainer != this) {
      //Timer.run(() =>dispatchEvent(new CustomEvent('polymer-class-change', detail: detail)));
      dispatchEvent(new CustomEvent('polymer-class-change', detail: detail));
    }
  }
}


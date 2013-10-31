library polymer_collapse;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

@CustomTag('polymer-collapse')
class PolymerCollapse extends PolymerElement {
  PolymerCollapse.created() : super.created();

  final _logger = new Logger('polymer-collapse');

  /**
   * The id of the target element.
   */
  @published String targetId = '';
  
  /**
   * The target element.
   */
  @published HtmlElement target;
  
  /**
   * If true, the orientation is horizontal; otherwise is vertical.
   */
  @published bool horizontal = false;
  
  /**
   * If true, the target element is hidden/collapsed.
   */
  @published bool closed = false;

  /**
   * Collapsing/expanding animation duration in second.
   */
  @published double duration = 0.33; //new Duration(milliseconds: 333);

  /**
   * If true, the size of the target element is fixed and is set
   * on the element.  Otherwise it will try to 
   * use auto to determine the natural size to use
   * for collapsing/expanding.
   */
  @published bool fixedSize = false; 

  var size = null;
  StreamSubscription _transitionEndListener;
  String _dimension = "";
  bool _hasClosedClass = false;
  bool _inDocument = false;
  bool _afterInitialUpdate = false;
  
  @override
  void enteredView() {
    _logger.finest('enteredView');
    
    super.enteredView();
    //this.installControllerStyles();
    _inDocument = true;
    Timer.run(() => _afterInitialUpdate = true);
  }
  
  @override
  void leftView() {
    _logger.finest('leftView');
    
    this.removeListeners(this.target);
  }
   
  void targetIdChanged(e) {
    _logger.finest('targetIdChanged');
    
    var p = this.parentNode;
    while (p.parentNode != null) {
      p = p.parentNode;
    }
     
    this.target = p.querySelector('#' + this.targetId);
  }
  
  void targetChanged(HtmlElement old) {
    _logger.finest('targetChanged');
    
    if(old != null) {
      this.removeListeners(old);
    }
    this.horizontalChanged(); 
    if (this.target != null) {
      this.target.style.overflow = 'hidden';
      this.addListeners(this.target);
      // set polymer-collapse-closed class initially to hide the target
      this.toggleClosedClass(true);
    }
    // don't need to update if the size is already set and it's opened
    if (!this.fixedSize || !this.closed) {
      this.update();
    }
  }
  
  void addListeners(HtmlElement node) {
    _logger.finest('addListeners');
    
    if(_transitionEndListener == null) {
      _transitionEndListener = node.onTransitionEnd.listen((d) => this.transitionEnd(d)); 
    }
//  node.addEventListener('webkitTransitionEnd', this.transitionEndListener);
//  node.addEventListener('transitionend', this.transitionEndListener);
  }
  
  void removeListeners(HtmlElement node) {
    _logger.finest('removeListeners');
    
    _transitionEndListener.cancel();
    _transitionEndListener = null;
//  node.removeEventListener('webkitTransitionEnd', this.transitionEndListener);
//  node.removeEventListener('transitionend', this.transitionEndListener);
  }
  
  void horizontalChanged() {
    _logger.finest('horizontalChanged');
    
    if(this.horizontal) {
      _dimension = 'width';
    } else {
      _dimension = 'height';
    }
  }
  
  void closedChanged(e) {
    _logger.finest('closedChanged');
    
    this.update();
  }
  
  /** 
   * Toggle the closed state of the collapsible.
   *
   * @method toggle
   */
  void toggle() {
    _logger.finest("toggle '${this.id}'");
    
    this.closed = !this.closed;
  }
  
  void setTransitionDuration(double duration) {
    _logger.finest('setTransitionDuration');
    
    var s = this.target.style;
    if(duration != null && duration != 0) {
      _logger.finest("setTransitionDuration - ${this._dimension} ${duration}s");
      s.transition = '${this._dimension} ${duration}s'; 
    } else {
      _logger.finest("setTransitionDuration - duration 0ms");
      s.transition = null;
    }
    
    if (duration == null || duration == 0) {
      Timer.run(() => transitionEnd);
    }
  }
  
  void transitionEnd([e]) {
    _logger.finest('transitionEnd');
    
    if (!this.closed && !this.fixedSize) {
      this.updateSize('auto', null);
    }
    this.setTransitionDuration(null);
    this.toggleClosedClass(this.closed);
  }
  
  void toggleClosedClass(bool add) {
    _logger.finest('toggleClosedClass');
    
    this._hasClosedClass = add;
    this.target.classes.toggle('polymer-collapse-closed', add);
  }
  
  void updateSize(size, double duration, {bool forceEnd: false}) {
    _logger.finest('updateSize');
    
    if(duration != null && duration != 0) {
      this.calcSize();
    }
    this.setTransitionDuration(duration);
    var s = this.target.style;
    bool noChange = s.getPropertyValue(_dimension) == size;
    s.setProperty(_dimension, size.toString());
    // transitonEnd will not be called if the size has not changed
    if(forceEnd && noChange) {
      this.transitionEnd();
    }
  }
  
  void update() {
    _logger.finest('update');
    
    if(this.target == null || this._inDocument == null) {
      return;
    }
    this.horizontalChanged();
    if(this.closed) {
      hide();
    } else {
      show();
    }
  }
  
  dynamic calcSize() {
    _logger.finest('calcSize');
    
    var cr = this.target.getBoundingClientRect();
    if(_dimension == 'width') {
      return  '${cr.width}px';
    } else {
      return '${cr.height}px';
    }
  }
  
  String getComputedSize() {
    _logger.finest('getComputedSize');
    
    var cs = this.target.getComputedStyle();
    if(_dimension == 'width') {
      return cs.width;
    } else {
      return cs.height;
    }
  }
  
  void show() {
    _logger.finest('show');
    
    this.toggleClosedClass(false);
    // for initial update, skip the expanding animation to optimize
    // performance e.g. skip calcSize
    if (!_afterInitialUpdate) {
      this.transitionEnd();
      return;
    }
    var s; 
    if (!this.fixedSize) {
      this.updateSize('auto', null);
      s = this.calcSize();
      this.updateSize(0, null);
    }
    Timer.run(() {
      if(this.size != null) {
        s = this.size;
      }
      this.updateSize(s, this.duration, forceEnd: true);
    });
  }
  
  void hide() {
    _logger.finest('hide');
    
    // don't need to do anything if it's already hidden
    if (_hasClosedClass && !this.fixedSize) {
      return;
    }
    if (this.fixedSize) {
      // save the size before hiding it
      this.size = this.getComputedSize();
    } else {
      this.updateSize(this.calcSize(), null);
    }
    Timer.run(() {
      this.updateSize(0, this.duration);
    });
  }
}

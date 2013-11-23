// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_grid_layout;

import 'dart:async' show  Timer;
import 'dart:html' show CssStyleDeclaration, document, Element;
import 'dart:math' as math;
import 'package:logging/logging.dart' show Logger;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, published,
  ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved https://code.google.com/p/dart/issues/detail?id=15095

typedef SizeFn(int i);

@CustomTag('polymer-grid-layout')
class PolymerGridLayout extends PolymerElement {
  PolymerGridLayout.created() : super.created();
  
  final _logger = new Logger('polymer-grid-layout');

  @published List<Element> xnodes;
  @published List<List<int>> layout;
  @published bool auto = false;
  
  bool _isLayoutJobStarted = false;  
  int _colCount = 0, _rowCount = 0;
  List<Map<int,int>> _colOwners, _rowOwners;
  List<Element> _nodes;
  Element _lineParent;
  List<Map<String,int>> _rows;
  List<Map<String,int>> _columns;

  @override
  void enteredView() {
    super.enteredView();
    this.invalidate();
  }
  
  void xnodesChanged() {
    if(this.parent != null) {
      this.invalidate();
    }
  }
  
  void layoutChanged() {
    if(this.parent != null) {
      this.invalidate();
    }
  }
  
  void autoNodes() {
    if(parent == null) {
      return;
    }
    this.xnodes = this.parent.children.where((node) {
      switch(node.localName) {
        case 'polymer-grid-layout':
        case 'style':
          return false;
      }
      return true;
    });
  }
  
  void invalidate() {
    if (this.layout != null) {
      _isLayoutJobStarted = true;
      // job debounces layout, only letting it occur every N ms
      new Timer(Duration.ZERO, () {
        relayout();
        this._isLayoutJobStarted = false;
      });
    }
  }
  
  void relayout() {
    if (this.xnodes == null || this.auto) {
      this.autoNodes();
    }
    this._layout(this.layout, this.xnodes);
    this.asyncFire('polymer-grid-layout'); // TODO
  }


//
  void line(axis, p, d) {
    Element l = document.createElement('line');
    var extent = (axis == 'left' ? 'width' : 
      (axis == 'top' ? 'height' : axis));
    l.setAttribute('extent', extent);
    if (d < 0) {
      axis = (axis == 'left' ? 'right' : 
        (axis == 'top' ? 'bottom' : axis));
    }
    p = p.abs();
    l.style.setProperty(axis, '${p}px');
    l.style.setProperty(extent, '0px');
    _lineParent.append(l);
  }
  
  void matrixillate(List<List<int>> matrix) {
    // mesaure the matrix, must be rectangular
    _rowCount = matrix.length;
    _colCount = 0;
    if(_rowCount != 0 && matrix[0].length != 0) {
      _colCount = matrix[0].length;
    } 
    // transpose matrix
    var transpose = [];
    for (var i=0; i < _colCount; i++) {
      var c = [];
      for (var j=0; j < _rowCount; j++) {
        c.add(matrix[j][i]);
      }
      transpose.add(c);
    }
    // assign sizing control
    _colOwners = findOwners(matrix);
    _rowOwners = findOwners(transpose);
    //console.log('colOwners', colOwners);
    //console.log('rowOwners', rowOwners);
  }
  
  List<Map<int,int>> findOwners(List<List<int>> matrix) {
    int majCount = matrix.length;
    int minCount = 0;
    if(majCount != 0 && matrix[0].length != 0) {
      minCount = matrix[0].length;
    }
    var owners = new List<Map<int,int>>();
    // for each column (e.g.)
    for (var i = 0; i < minCount; i++) {
      // array of contained areas
      var contained = new Map<int,int>();
      // look at each row to find a containing area
      for (var j = 0; j < majCount; j++) {
        // get the row vector
        List<int> vector = matrix[j];
        // node index at [i,j]
        int nodei = vector[i];
        // if a node is there
        if (nodei != 0) {
          // determine if it bounds this column
          bool owns = false;
          if (i == 0) {
            owns = (i == minCount - 1) || (nodei != vector[i+1]);
          } else if (i == minCount - 1) {
            owns = (i == 0) || (nodei != vector[i-1]);
          } else {
            owns = nodei != vector[i-1] && nodei != vector[i+1];
          }
          if (owns) {
            contained[nodei] = 1;
          }
        }
        // store the owners for this column
        while(owners.length <= i) {
          owners.add(null);
        }
        owners[i] = contained;
      }
    }
    return owners;
  }
  
  
  int colWidth(int i) {
    for (var col in _colOwners[i].keys) {
      if (col == 0) {
        return 96;
      }
      var node = _nodes[col - 1];
      if (node.attributes.containsKey('h-flex') || node.attributes.containsKey('flex')) {
        return -1;
      }
      var w = node.offsetWidth;
      //console.log('colWidth(' + i + ') ==', w);
      return w;
    }
    return -1;
  }
  
  int rowHeight(int i) {
    for (var row in _rowOwners[i].keys) {
      if (row == 0) {
        return 96;
      }
      var node = _nodes[row - 1];
      if (node.attributes.containsKey('v-flex') || node.attributes.containsKey('flex')) {
        return -1;
      }
      var h = node.offsetHeight;
      //console.log('rowHeight(' + i + ') ==', h);
      return h;
    }
    return -1;
  }
  
  var _m = 0;
  
  List<Map<String,int>> railize(int count, SizeFn sizeFn) {
    //
    // create rails for `count` tracks using 
    // sizing function `sizeFn(trackNo)`
    //
    // for n tracks there are (n+1) rails
    //
    //   |track|track|track|
    //  0|->sz0|->sz1|<-sz2|0
    //
    //   |track|track|track|
    //  0|->sz0|     |<-sz2|0
    //
    // there can be one elastic track per set
    //
    //   |track|track|track|track|
    //  0|-->s0|-->s1|<--s1|<--s2|0
    //
    // sz1 spans multiple  tracks which makes
    // it elastic (it's underconstrained)
    //
    var rails = new List<Map<String,int>>();
    var a = 0;
    int rNum = 0;
    for (var i = 0, x; i < count; i++) {
      rNum = i;
      while(rails.length <= i) {
        rails.add(null);
      }
      rails[i] = {'p': a, 's': 1};
      x = sizeFn(i) + _m + _m;
      if (x == -1) {
        break;
      }
      a += x;
    }
    if (rNum == count) {
      rails[rNum] = {'p': 0, 's': -1};
    }
    var b = 0;
    for (var ii = count, x; ii > rNum; ii--) {
      while(rails.length <= ii) {
        rails.add(null);
      }
      
      rails[ii] = {'p': b, 's': -1};
      x = sizeFn(ii - 1) + _m + _m;
      if (x != -1) {
        b += x;
      }
    }
    return rails;
  }
  
  // TODO(sjmiles): this code tries to preserve actual position,
  // so 'unposition' is really 'naturalize' or something
  void unposition(Element box) {
    var style = box.style;
    //style.right = style.bottom = style.width = style.height = '';
    style.position = 'absolute';
    style.display = 'inline-block';
    style.boxSizing = 'border-box';
  }
  
  void _position(CssStyleDeclaration style, String maj, String min, String ext, Map<String,int> a, Map<String,int> b) {
    style.setProperty(maj, '');
    style.setProperty(min, '');
    style.setProperty(ext, 'auto');
    if (a['s'] < 0 && b['s'] < 0) {
      int siz = a['p'] - b['p'] - _m - _m;
      style.setProperty(ext, '${siz}px');
      var c = 'calc(100% - ${(b['p'] + siz + _m)}px)';
      style.setProperty(maj, c);
      //style[maj] = c;
    } else if (b['s'] < 0) {
      style.setProperty(maj, '${a['p'] + _m}px');
      style.setProperty(min, '${b['p'] + _m}px');
    } else {
      style.setProperty(maj, '${a['p'] + _m}px');
      style.setProperty(ext, '${b['p'] - a['p'] - _m - _m}px');
    }
  }
  
  void position(Element elt, int left, int right, int top, int bottom) {
    _position(elt.style, 'top', 'bottom', 'height', _rows[top], 
        _rows[bottom]);
    _position(elt.style, 'left', 'right', 'width', _columns[left], 
        _columns[right]);
  }
  
  void _layout(List<List<int>> matrix, anodes, [alineParent]) {
    //console.group('layout');
  
    _lineParent = alineParent;
    _nodes = anodes;
    matrixillate(matrix);
  
    _nodes.forEach(unposition);
  
    _columns = railize(_colCount, colWidth);
    _rows = railize(_rowCount, rowHeight);
  
    if (alineParent != null) {
      //console.group('column rails');
      _columns.forEach((c) {
        //console.log(c.p, c.s);
        line('left', c['p'], c['s']);
      });
      //console.groupEnd();
  
      //console.group('row rails');
      _rows.forEach((r) {
        //console.log(r.p, r.s);
        line('top', r['p'], r['s']);
      });
      //console.groupEnd();
    }
  
    //console.group('rail boundaries');
    
    int i = 0;
    for(Element node in _nodes) {
      // node indices are 1-based
      int n = i + 1;
      i++;
      // boundary rails
      int l, r, t = 10000000000, b = -10000000000;
      int j = 0;
      for(List<int> vector in matrix) {
        int f = vector.indexOf(n);
        if (f > -1) {
          l = f;
          r = vector.lastIndexOf(n) + 1;
          t = math.min(t, j);
          b = math.max(b, j) + 1;
        }
        j++;
      }
      if (l == null) {
        //console.log('unused');
        node.style.position = 'absolute';
        var offscreen = node.getAttribute('offscreen');
        switch (offscreen) {
          case 'basement':
            node.style.zIndex = "0";
            break;
          case 'left':
          case 'top':
            node.style.setProperty(offscreen, '${node.offsetWidth * -2}px');
            break;
          case 'right':
            node.style.left = '${node.offsetParent.offsetWidth 
            + node.offsetWidth }px';
            break;
          case 'bottom':
            node.style.top = '${node.parent.offsetHeight 
            + node.offsetHeight}px';
            break;
          default:
            node.style.setProperty(new math.Random().nextDouble() >= 0.5 ? 'left' : 'top', '-110%');
        }
        //node.style.opacity = 0;
        node.style.pointerEvents = 'none';
      } else {
        node.style.pointerEvents = '';
        //node.style.opacity = '';
        //console.log(l, r, t, b);
        position(node, l, r, t, b);
      }
    }
    //console.groupEnd();
    //console.groupEnd();
  }
}
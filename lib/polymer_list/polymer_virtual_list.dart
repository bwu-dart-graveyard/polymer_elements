// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library polymer_elements.polymer_virtual_list;

import 'dart:html' as dom;
import 'dart:math' as math;
import 'package:polymer/polymer.dart' show CustomTag, observable, PathObserver,
    PolymerElement, Polymer, published, ChangeNotifier, reflectable;
    // TODO remove ChangeNotifier, reflectable when
// bug is solved https://code.google.com/p/dart/issues/detail?id=13849 (15095)

@CustomTag('polymer-virtual-list')
class PolymerVirtualList extends PolymerElement {
  PolymerVirtualList.created(): super.created();

  /// rows per page
  @published
  int pageSize = 20;
  /// number of pages
  @published
  int numPages = 2;
  /// total number of rows
  @published
  int count = 0;
  /// number of pages to render at start
  int numInitialPages = 0;
  @published
  bool horizontal = false;
  @published
  bool fixedHeight = false;
  @observable
  int pageCount = 0;

  bool retainPages = false;
  bool _initialized = false;
  int _rowHeight = 0;
  int _viewportHeight = 0;
  List<int> _pageHeights = [];
  List<int> _pageTops = [];

  Map<String, dom.DivElement> _pageCache = {};
  List<dom.DivElement> _pages;
  List<dom.DivElement> _previousPages;
  Map<String, String> _metrics = {};


  void countChanged(old) {
    refresh();
  }

  void pageSizeChanged(old) {
    reset();
  }

  void numPagesChanged(old) {
    reset();
  }

  void retainPagesChanged(old) {
    reset();
  }

  void horizontalChanged(old) {
    reset();
  }

  void ready() {
    super.ready();
    this.setupScrollListener();
    this.reset();
  }

  void setupScrollListener() {
    this.$['list'].onScroll.listen((dom.Event e) {
      this.scroll(e);
    });
  }

  /// re-render at the top
  void reset() {
    this._initialized = false;
    // discover dimensionality
    this.$['viewport'].classes.toggle('horizontal', this.horizontal);
    this.updateMetrics();
    // clear size estimate caches
    this._rowHeight = 0;
    this._pageHeights = [];
    this._pageTops = [];
    // scroll to top!
    this.scrollOffset = 0;
    this.refresh();
  }

  // completely refresh rendering at the current scroll position
  void refresh() {
    this.pageCount = (this.count / this.pageSize).ceil();
    this.$['viewport'].text = '';
    this._pages = [];
    this._pageCache = {};
    // completely invalidate rendering
    this.invalidatePages(this.getViewportPageInfo());
  }

  // adjust viewport height when page count changes...
  void pageCountChanged(oldValue) {
    if (this._initialized && oldValue != null && oldValue != 0) {
      var h = 0,
          delta = this.pageCount - oldValue;
      if (delta > 0) {
        h = (delta - 1) * this.getPageHeight(this.pageCount - 1);
      } else {
        for (var i = oldValue - 1; i >= this.pageCount; i--) {
          h -= this.getPageHeight(i);
        }
      }
      this.viewportHeight += h;
    }
  }

  void updateMetrics() {
    var scrollOffset = 'scrollTop';
    var offsetExtent = 'offsetHeight';
    var offsetPosition = 'offsetTop';
    var extent = 'height';
    var position = 'top';

    if (this.horizontal) {
      scrollOffset = 'scrollLeft';
      offsetExtent = 'offsetWidth';
      offsetPosition = 'offsetLeft';
      extent = 'width';
      position = 'left';
    }

    this._metrics = {
      'scrollOffset': scrollOffset,
      'offsetExtent': offsetExtent,
      'offsetPosition': offsetPosition,
      'extent': extent,
      'position': position
    };
  }

  // get the current scrollOffset
  int get scrollOffset {
    return int.parse(this.$['list'].attributes[this._metrics['scrollOffset']]);
  }

  // sets the current scrollOffset
  void set scrollOffset(int offset) {
    this.$['list'].attributes[this._metrics['scrollOffset']] = offset.toString(
        );
  }

  void generatePageContent(dom.DivElement page, int start, int end) {
    this.fire('polymer-list-generate-page', detail: {
      'page': page,
      'start': start,
      'end': end
    });
  }

  dom.DivElement generatePage(int pageNum) {
    if (pageNum < this.pageCount) {
      dom.DivElement p = dom.document.createElement('div');
      p.attributes['pageNum'] = pageNum.toString();
      p.attributes['page'] = pageNum.toString();
      if (this.retainPages) {
        p.style.display = 'none';
      }
      var start = int.parse(p.attributes['pageNum']) * this.pageSize;
      var end = math.min(start + this.pageSize, this.count);
      this.generatePageContent(p, start, end);
      this.$['viewport'].append(p);
      this._pageCache['pageNum'] = p;
      if (this.fixedHeight) {
        this._pageTops[pageNum] = null;
        this.positionPage(p);
      }
      return p;
    }
    return null;
  }

  void initialize(int pageHeight, int pageNumber) {
    this._rowHeight = pageHeight ~/ (this.pageSize < this.count ? this.pageSize
        : this.count);
    this.viewportHeight = this.count * this._rowHeight;
    var numPages = math.min((this.count / this.pageSize).ceil(),
        this.numInitialPages);
    for (int i = 0; i < numPages; i++) {
      if (pageNumber != i) {
        this.generatePage(i);
      }
    }
    this._initialized = true;
  }

  int get viewportHeight {
    return this._viewportHeight;
  }

  void set viewportHeight(int value) {
    this._viewportHeight = value;
    this.$['viewport'].style.setProperty(this._metrics['extent'],
        '${this._viewportHeight}px');
  }

  int calcPageHeight(dom.DivElement page) {
    int pageHeight = (this.fixedHeight && this._rowHeight != 0) ? (this.pageSize
        * this._rowHeight) : page.attributes[this._metrics['offsetExtent']];
    if (pageHeight == null) {
      pageHeight = 0;
    }
    return pageHeight;
  }

  int getPageHeight(int pageNum) {
    return this._pageHeights.length > 0 && this._pageHeights[pageNum] != null ?
        this._pageHeights[pageNum] : this.pageSize * (this._rowHeight != 0 ?
        this._rowHeight : 100);
  }

  // calculates the start and center page for the current scroll position
  Map<String, int> getViewportPageInfo() {
    int listOffsetExtent = 0;
    if (this.$['list'].attributes[this._metrics['offsetExtent']] != null) {
      listOffsetExtent = int.parse(
          this.$['list'].attributes[this._metrics['offsetExtent']]);
    }
    var c = (this.locatePage(this.scrollOffset + listOffsetExtent / 2) +
        0.5).floor();
    var k = c - (this.numPages / 2).floor();
    k = math.max(0, k);
    // the current start/center page index
    return {
      'start': k,
      'center': c
    };
  }

  // given a positon, returns page number + decimal offset on page.
  double locatePage(double pos) {
    // guesstimate page given 1st page's height
    double pn_tmp = pos / this.getPageHeight(0);
    if (this.fixedHeight) {
      return pn_tmp;
    }
    int pn = (pn_tmp).floor();
    // decrement page if the pageTop of guesstimate is > requested pos
    while ((pn != 0 && this._pageTops[pn] == 0) || (this._pageTops.length > 0 &&
        this._pageTops[pn] != null && this._pageTops[pn] > pos)) {
      pn--;
    }
    var pt = this._pageTops.length > 0 && this._pageTops[pn] != null ?
        this._pageTops[pn] : 0;
    // increment page if pageTop of guesstimate is < requested pos
    // also adjust the _pageTops for any interrogated page

    while (pos >= pt) {
      pt += this.getPageHeight((pn++));
      while (this._pageTops.length <= pn) {
        this._pageTops.add(null);
      }
      this._pageTops[pn] = pt;
    }
    // find decimal offset on page
    pn--;
    var ph = this.getPageHeight(pn);
    return pn + (pos - pt + ph) / ph;
  }

  /* returns delta between actual and expected */
  int measurePage(dom.DivElement page) {
    int ph = this.calcPageHeight(page);
    int pn = int.parse(page.attributes['pageNum']);
    if (this._rowHeight == 0) {
      // rowHeight is not set, use the page's height to setup initial values
      this.initialize(ph, pn);
    }
    var ph0 = this.getPageHeight(pn);
    if (ph != 0 && ph0 != ph) {
      this._pageHeights[pn] = ph;
      // since page height has changed, invalidate all the _pageTops after
      // this page
      this._pageTops.removeRange(pn + 1, this._pageTops.length);
      // also adjust the viewport's height
      return ph - ph0;
    }
    return 0;
  }

  // positions the given page and returns the adjustment delta.
  int positionPage(dom.DivElement page) { // TODO what is page
    int pn = int.parse(page.attributes['pageNum']);
    var t;
    if (this.fixedHeight) {
      t = pn * this._rowHeight * this.pageSize;
      if (this._pageTops[pn] == 0) {
        this._pageTops[pn] = t;
        page.style.setProperty(this._metrics['position'], '${t}px');
      }
    } else {
      t = this._pageTops[pn] != null ? this._pageTops[pn] : this.calcPageTop(pn
          );
      // update _pageTops cache
      while (this._pageTops.length <= pn + 1) {
        this._pageTops.add(null);
      }
      this._pageTops[pn] = t;
      this._pageTops[pn + 1] = t + this.getPageHeight(pn);
      // save old top
      String t0 = page.style.getPropertyValue(this._metrics['position']);
      t0 = t0.isEmpty ? t0 : t0.substring(0, t0.length - 2);
      page.style.setProperty(this._metrics['position'], t0);
      // set the page's top
      page.style.setProperty(this._metrics['position'], '${t}px');
      //page.style.webkitTransform = 'translate3d(0, ' + t + 'px, 0)';
      // return delta between old and new
      if (t0 != null && t0.isNotEmpty) {
        return int.parse(t0) - t;
      }
    }
    return 0;
  }

  // calculate a pageTop from scratch by iterating from the top
  // NOTE: this is costly, but we almost never need to do this
  // because of the pageTop setting done by locatePage
  int calcPageTop(int pageNum) {
    var n = 0,
        t = 0;
    while (n < pageNum) {
      t += this.getPageHeight(n);
      n++;
    }
    return t != null ? t : 0;
  }

  // use cache if pages are retained because in this case we expect
  // querySelector to be slow!
  dom.DivElement findPage(pageNum) {
    if (!this.retainPages || this._pageCache[pageNum] == null) {
      this._pageCache[pageNum] = this.$['viewport'].querySelector(
          '[page="${pageNum}"]');
    }
    return this._pageCache[pageNum];
  }

  /*
  TODO(sorvell): chrome fires scroll events with raf timing;
  on other browser, we will want to throttle events to that timing
  */
  void scroll(dom.Event e) {
    this.fire('polymer-list-scroll');
    var info = this.getViewportPageInfo();
    // validate if needed
    if (this._pages[0] == null || this._pages[0].attributes['pageNum'] !=
        info['start']) {
      this.invalidatePages(info);
    }
  }

  // extension point for customizing page setup
  void invalidatePages(info) {
    this.invalidate(info);
  }

  // validate rendering at the given or current scroll position
  void invalidate(Map<String, int> info) {
    info = info != null ? info : this.getViewportPageInfo();
    int k = info['start'];
    int n = info['start'] + this.numPages;
    int c = info['center'];
    int v = 0;
    int s = 0;
    int d;
    this._previousPages = this._pages;
    this._pages = [];
    for ( ; k < n; k++) {
      dom.DivElement p = this.findPage(k) != null ? this.findPage(k) :
          this.generatePage(k);
      if (p != null) {
        if (this.retainPages) {
          p.style.display = null;
        }
        v += this.measurePage(p);
        d = this.positionPage(p);
        // adjust scrollOffset if center page's top has changed
        if (d != 0 && k == c) {
          s = d;
        }
        this._pages.add(p);
      }
    }
    // adjust viewport and scroll position iff needed
    if (!this.fixedHeight) {
      if (v != 0) {
        this.viewportHeight += v;
      }
      if (s != 0) {
        this.scrollOffset -= s;
      }
    }
    // remove out-of-bounds pages
    this.cleanupPages();
  }

  void cleanupPages() {
    var p$ = this._previousPages;
    for (var i = 0,
        l = p$.length,
        p; (i < l) && (p$[i] != null); i++) {
      p = p$[i];
      if (this._pages.indexOf(p) == -1) {
        if (this.retainPages) {
          p.style.display = 'none';
        } else {
          this.$['viewport'].children.remove(p);
        }
      }
    }
  }

  // setting scrollOffset is asynchronous; this method provides
  // a way to scroll the list synchronously.
  void setScrollOffsetImmediate(int pos) {
    this.scrollOffset = pos;
    this.scroll(null);
  }

  void scrollToRow(int row) {
    row = math.max(0, math.min(row, this.count - 1));
    // find page and row in page
    int pageNum = (row / this.pageSize).floor();
    // guesstimate offset and scroll to it
    int top = this._pageTops[pageNum] != null ? this._pageTops[pageNum] :
        this.calcPageTop(pageNum);
    this.setScrollOffsetImmediate(top);
    // re-scroll with updated info
    top = this._pageTops[pageNum];
    this.setScrollOffsetImmediate(top);
    // scroll to offset on this page
    dom.DivElement page = this.findPage(pageNum);
    int rowInPage = row - pageNum * this.pageSize;
    this.whenNodeFoundOnPage(page, rowInPage, (node) {
      this.setScrollOffsetImmediate(this.scrollOffset +
          node[this._metrics['offsetPosition']]);
    });
  }

  // note: may need to go async to find node
  void whenNodeFoundOnPage(dom.DivElement page, int index, Function callback) {
    var node = this.findRowOnPage(page, index, callback);
    if (node) {
      callback.call(this, node);
    } else {
      this.onMutation(this.mutationNodeForPage(page)).then((e) {
        this.whenNodeFoundOnPage(page, index, callback);
      });
    }
  }

  dom.DivElement mutationNodeForPage(dom.DivElement page) {
    return page;
  }

  dom.DivElement findRowOnPage(dom.DivElement page, int index, Function callback) {
    return page.children[index];
  }
}

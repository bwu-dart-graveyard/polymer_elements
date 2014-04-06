// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.

library polymer_elements.polymer_list;

import 'dart:async' as async;
import 'dart:html' show ContentElement, CssStyleDeclaration, DivElement,
    document, DocumentFragment, Element, Event, HtmlElement, Node, TemplateElement;
import 'dart:math' as math;
import 'package:polymer/polymer.dart' show CustomTag, observable, PathObserver,
    PolymerElement, Polymer, published, toObservable, ChangeNotifier, reflectable;
// TODO remove ChangeNotifier, reflectable when bug is solved https://code.google.com/p/dart/issues/detail?id=13849 (15095)
import 'polymer_virtual_list.dart' show PolymerVirtualList;
import 'package:polymer_elements/polymer_selection/polymer_selection.dart' show
    PolymerSelection;


////var extend = Polymer.extend;
Map<int, int> extend(Map<int, int> obj, Map<int, int> mixin) {
  for (var i in mixin.keys) {
    obj[i] = mixin[i];
  }
  return obj;
}


@CustomTag('polymer-list')
class PolymerList extends PolymerVirtualList {
  PolymerList.created(): super.created();

  @published
  List<Map<int, int>> data;

  @published
  List<ListDataItem> listData;

  @published
  bool multi = false;

  @published
  int selected;

  @observable
  TemplateElement template;

  String selectedClass = 'polymer-selected';
  int _dataStart = 0;
  int _dataEnd = 0;
  bool _useFreshData = false;
  var _rootData;
  int _dataIndex = 0;
  bool _fixedHeight = false;
  bool _rowHeight = false;
  int _userItem = 0;


  @override
  void ready() {
    this.data = toObservable([]);
    this.listData = toObservable([]);
    super.ready();
  }

  @override
  void enteredView() {
    //this.templateChanged(null);
    this.template = this.querySelector('template');
    super.enteredView();
  }

  void dataChanged(old) {
    this.count = this.data.length;
    //console.log('dataChanged', this.count);
  }

  @override
  void generatePageContent(HtmlElement page, int start, int end) {
    super.generatePageContent(page, start, end);
    // add a content w/select into this page
    ContentElement c = document.createElement('content');
    c.select = '.page' + page.attributes['pageNum'];
    page.append(c);
  }

  void generateListData(Map<String, int> info) {
    var start = info['start'] * this.pageSize;
    var end = math.min(start + this.pageSize * this.numPages, this.count);
    this._dataStart = start;
    this._dataEnd = end;
    this.fire('polymer-list-generate-data', detail: {
      'start': start,
      'end': end
    });
    // produce data window
    int l = end - start;
    for (var i = 0; i < l; i++) {
      this.updateDataAtIndex(start + i);
    }
    if (l < this.listData.length) {
      this.listData.removeRange(l, this.listData.length - l);
    }
  }

  /*
  TODO(sorvell): go to some trouble to re-use data objects rather than
  creating new ones. This allows mdv to avoid re-generating dom and is
  a massive speed improvement (4x) when items contain custom elements.
  There's an ongoing effort to make generating custom elements faster, but
  this approach may just be superior. However, if so, we need better
  support from mdv for this use case. By maintaining a copy of the user's
  data, we lose the live link to it, which is unacceptable. It's therefore
  currnetly necessary to call 'updateDataAtIndex' to cause the list's
  data to sync to the user's data. In addition, having to mutate data
  objects is cumbersome and slow.
  */
  /*
    auto-generate a scope:
    {root: template model, item: item data,
      page: list page, index: data index, selected: selectedClass if selected}
  */
  void updateDataAtIndex(int dataIndex) {
    int index = dataIndex - this._dataStart;
    if (index > this._dataEnd) {
      return;
    }
    Map<int, int> item = this.data[dataIndex];
    ListDataItem d;
    if (this._useFreshData) {
      d = this.listData[index] = new ListDataItem(item: item, root:
          this._rootData);
    } else {
      if (this.listData.length <= index || this.listData[index] == null) {
        d = new ListDataItem(item: extend({}, item), root: this._rootData);
      } else {
        d = this.listData[index];
        // clear previous value, ug
        for (var a in d.item) {
          d.item[a] = null;
        }
        extend(d.item, item);
      }
    }
    d.userItem = item;
    d.index = _dataIndex;
    d.page = 'page${(dataIndex / this.pageSize).floor()}';
    d.selected = (this.$['selection'] as PolymerSelection).isSelected(item) ?
        this.selectedClass : '';
  }

  void templateChanged(old) {
    // TODO: handle template changing
    if (this.template == null) {
      //return;
    }
    if (this.templateInstance != null) {
      this._rootData = this.templateInstance.model;
    }
    DocumentFragment content = this.template.content;
    //var listContent = ($['content'] as ContentElement).getDistributedNodes();
    // add 'page' element to template
    DivElement page = document.createElement('div');
    page.setAttribute('class', '{{page}}');
    //listContent.forEach((n) => page.append(n.clone(true)));
    while (content.firstChild != null) {
      page.append(content.firstChild);
    }
    content.append(page);
    this.template.setAttribute('repeat', '{{listData}}');
    this.template.model = this;

//    ($['repeat'] as TemplateElement).content.append(page);
//    ($['repeat'] as TemplateElement).append(page);
//    ($['repeat'] as TemplateElement).appendHtml(
//        """<div hidden="{{!item['header'] == null}}" class="header">{{item['header']}}: {{item['index']}}</div>
//      <div class="item {{selected}}">Index: {{index}}</div>"""
//        );
//    this.notifyPropertyChange(#listData, null, listData);
    // set template to repeat
    //var observer = new PathObserver(this, 'listData'); // TODO
    //this.template.bind('repeat', observer);
    //this.template.repeat = listData;
    //this.templateInstance.model = listData;
  }

  void listDataChanged(old) {
    /*if (this.template.templateInstance) {
      this.template.templateInstance.model.listData = this.listData;
    }*/
  }

  void invalidatePages(Map<String, int> info) {
    this.generateListData(info);
    super.invalidatePages(info);
    if (!this._fixedHeight || !this._rowHeight) {
      var self = this;
      new async.Future.microtask(() => self.invalidate(info));
      //Platform.endOfMicrotask(() { // TODO
      //self.invalidate(info);
      //});

      /*this.onMutation(this, function() {
        this.invalidate(info);
      });*/
    }
  }

  @override
  DivElement mutationNodeForPage(DivElement page) {
    return this;
  }

  @override
  DivElement findRowOnPage(DivElement page, index, Function callback) {
    return this.querySelectorAll('.page' + page.attributes['pageNum'])[index];
  }

  void tapAction(Event e, var details, HtmlElement target) {
    if (e.target != this) {
      var n = e.target;
      ListDataItem model = n.templateInstance != null ? (n.templateInstance.model as ListDataItem): null;
      if (model != null) {
        var item = model.userItem;
        (this.$['selection'] as PolymerSelection).select(item);
        this.asyncFire('polymer-activate', detail: {
          'item': item
        });
      }
    }
  }

  void selectedAction(Event e, detail, HtmlElement target) {
    this.updateDataAtIndex(this.indexOfItem(detail.item));
  }

  int indexOfItem(Map<int,int> dataItem) {
    return this.data.indexOf(dataItem);
  }

  /*
  TODO(sorvell): very similar to polymer-selector; consider refactoring
  the common bits.
  */
  dynamic get selection {
    return (this.$['selection'] as PolymerSelection).selection();
  }

  void selectedChanged(old) {
    (this.$['selection'] as PolymerSelection).select(this.selected);
  }

  void clearSelection() {
    var ps = ($['selection'] as PolymerSelection);
    if (this.multi) {
      var s = this.selection;
      for (var i = 0,
          l = s.length,
          s; (i < l) && (s = s[i]); i++) {
        ps.setItemSelected(s, false);
      }
    } else {
      ps.setItemSelected(this.selection, false);
    }
    ps.clear();
  }
}

class ListDataItem {
  Map<int, int> item;
  var root;
  Map<int, int> userItem;
  int index;
  String page;
  String selected;

  ListDataItem({this.item, this.root, this.userItem, this.index, this.page, this.selected});
}

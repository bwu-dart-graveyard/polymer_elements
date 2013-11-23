// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_media_query;

import 'dart:async';
import 'dart:html' show MediaQueryListListener, MediaQueryList, window, CustomEvent, EventStreamProvider;
import 'dart:js' show context;
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

/**
 * polymer-media-query can be used to data bind to a CSS media query.
 * The "query" property is a bare CSS media query.
 * The "queryMatches" property will be a boolean representing if the page matches that media query.
 *
 * polymer-media-query uses media query listeners to dynamically update the "queryMatches" property.
 * A "polymer-mediachange" event also fires when queryMatches changes.
 *
 * Example:
 *
 *      <polymer-media-query query="max-width: 640px" queryMatches="{{phoneScreen}}"></polymer-media-query>
 */
@CustomTag('polymer-media-query')
class PolymerMediaQuery extends PolymerElement {
  PolymerMediaQuery.created() : super.created();

  final _logger = new Logger('polymer-media-query');

  /**
   * The Boolean return value of the media query
   */
  @published bool queryMatches = false;

  /**
   * The CSS media query to evaulate
   */
  @published String mquery = ''; // renamed from query to mquery to avoid conflicts with super.query() method
  
  static const EventStreamProvider<CustomEvent> _mediaChange =
      const EventStreamProvider<CustomEvent>('polymer-mediachange');

  /**
   * Fires a custom event (polymer-mediachange) when the query matches.
   */
  Stream<CustomEvent> get onMediaChange =>
      PolymerMediaQuery._mediaChange.forTarget(this);
  
  var _mqHandler;
  var _mq;
  
  @override
  void enteredView() {
    this._mqHandler = queryHandler;
    super.enteredView();
    mqueryChanged(null);
  }

  void mqueryChanged(oldValue) {
    if (this._mq != null) {
      if(context['matchMedia'] != null) {
        _mq.callMethod('removeListener', [_mqHandler]);
      }
      // TODO not supported in Dart yet (#84)
      //this._mq.removeListener(this._mqHandler);
    }

    if (this.mquery == null || this.mquery.isEmpty) {
      return;
    }

    if(context['matchMedia'] != null) {
      this._mq = context.callMethod('matchMedia', ['(${this.mquery})']);
      this._mq.callMethod('addListener', [_mqHandler]);
      queryHandler(this._mq);
    }
    // TODO not supported in Dart yet (#84)
    // Listener hast to be as MediaQueryListListener but this is and abstract 
    // class and therefor it's not possible to create a listner
    // this._mq = window.matchMedia(q);
    // this._mq.addListener(queryHandler);
    // this.queryHandler(this._mq);
  }
  
  void queryHandler(mq) {
    this.queryMatches = mq['matches'];
    dispatchEvent(new CustomEvent('polymer-mediachange', detail: mq));
  }
}

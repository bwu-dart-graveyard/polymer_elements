// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see
// the AUTHORS file for details. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project,
// http://www.polymer-project.org/.


/**
 * polymer-ajax can be used to perform XMLHttpRequests.  The polymer-ajax
 * element fires three events: polymerresponse, polymererror,
 * and polymercomplete.
 *
 * Example:
 *
 *     <polymer-ajax auto url="http://gdata.youtube.com/feeds/api/videos/"
 *         params='{"alt":"json", "q":"chrome"}'
 *         handleAs="json"
 *         on-polymerresponse="{{handleResponse}}">
 *     </polymer-ajax>
 *
 *  polymerresponse: Fired with the response when it's received.
 *  polymererror: Fired with the error if one occurs.
 *  polymercomplete: Fired whenever a response or an error is recieved.
 */

library polymer_elements.polymer_ajax;

import 'dart:async';
import 'dart:convert';
import 'dart:html' show Element;
import 'package:polymer/polymer.dart';

@CustomTag('polymer-ajax')
class PolymerAjax extends PolymerElement {

  /**
   * The URL target of the request.
   */
  @published
  String url =  '';

  /**
   * Specifies what data to store in the 'response' property, and
   * to deliver as 'event.response' in 'response' events.
   *
   * One of:
   *
   *    `text`: uses XHR.responseText
   *
   *    `xml`: uses XHR.responseXML
   *
   *    `json`: uses XHR.responseText parsed as JSON
   */
  @published
  String handleAs = '';

  /**
   * If true, automatically performs an Ajax request when either url or params has changed.
   */
  @published
  bool auto = false;

  /**
   * Parameters to send to the specified URL, as JSON.
   */
  @published
  String params = '';

  /**
   * Returns the response object.
   */
  @published
  var response;

  /**
   * The HTTP method to use such as 'GET', 'POST', 'PUT', 'DELETE'.
   * Default is 'GET'.'
   */
  String method = '';

  /**
   * HTTP request headers to send.
  *
   * Example:
  *
   *     <polymer-ajax auto url="http://somesite.com"
   *         headers='{"X-Requested-With": "XMLHttpRequest"}'
   *         handleAs="json"
   *         on-polymer-response="{{handleResponse}}">
   *     </polymer-ajax>
   */
  @published
  var headers;

  /**
   * Default values for use with the underlying polymer-xhr object. Useful for
   * sending payloads other than the default URL encoded form values.
   *
   * Example:
   *
   *     querySelector('polymer-ajax')
   *       ..xhrArgs = {'body': JSON.encode(jsonData)};
   */
  @published
  Map xhrArgs = {};

  
  /**
   * Optional raw body content to send when method === "POST"
   *
   * Example:
   *
   *     <polymer-ajax method="POST" auto url="http://somesite.com"
   *         body='{"foo":1, "bar":2}'>
   *     </polymer-ajax>
   */
  Map body;
  
  Timer _goJob;

  //TODO Not sure why this is kept around
  var _xhr;

  PolymerAjax.created() : super.created();

  ready() {
    super.ready();
    this._xhr = new Element.tag('polymer-xhr');
  }

  _receive(response, xhr) {
    if (this._isSuccess(xhr)) {
      this._processResponse(xhr);
    } else {
      this._error(xhr);
    }
    this._complete(xhr);
  }

  _isSuccess(xhr) {
    var status = xhr.status != null ? xhr.status : 0;
    return status == null ? false : (status >= 200 && status < 300);
  }

  _processResponse(xhr) {
    var response = this._evalResponse(xhr);
    this.response = response;
    this.fire('polymer-response', detail: {'response': response, 'xhr': xhr});
  }

  _error(xhr) {
    var response = '${xhr.status}: ${xhr.responseText}';
    this.fire('polymer-error', detail: {'response': response, 'xhr': xhr});
  }

  _complete(xhr) {
    this.fire('polymer-complete', detail: {'response': xhr.status, 'xhr': xhr});
  }

  _evalResponse(xhr) {
    switch(this.handleAs) {
      case 'json':
        return _jsonHandler(xhr);
      case 'xml':
        return _xmlHandler(xhr);
      //case 'text':
        //return _textHandler(xhr);
      default:
        return _textHandler(xhr);;
    }
  }

  _xmlHandler(xhr){
    return xhr.responseXML;
  }

  _textHandler(xhr) {
    return xhr.responseText;
  }

  _jsonHandler(xhr) {
    var r = xhr.responseText;
    try {
      return JSON.decode(r);
    } catch (x) {
      return r;
    }
  }

  urlChanged(old){
    if (this.handleAs.isEmpty) {
      var split = this.url.split('.');
      var ext;
      if(split.isNotEmpty){
        ext = split.last;
      }else {
        ext = 'text';
      }
      switch (ext) {
        case 'json':
          this.handleAs = 'json';
          break;
        case 'xml':
          this.handleAs = 'xml';
          break;
        default:
          this.handleAs = 'text';
      }
    }
    this._autoGo();
  }

  paramsChanged(old) {
    this._autoGo();
  }

  autoChanged(old){
    this._autoGo();
  }

  // TODO(sorvell): multiple side-effects could call autoGo
  // during one micro-task, use a job to have only one action
  // occur
  _autoGo() {
    if(_goJob != null){
      _goJob.cancel();
    }
    _goJob = new Timer(Duration.ZERO, go);
  }

  /**
   * Performs an Ajax request to the url specified.
  *
   * @method go
   */
  go() {
    var args = xhrArgs;
    // TODO(sjmiles): alternatively, we could force POST if body is set
    if (this.method == 'POST') {
      if(this.body != null) {
        args['body'] = this.body;
      }
    }    
    args['params'] = this.params;
    if (args['params'] is String && args['params'].isNotEmpty) {
      args['params'] = JSON.decode(args['params']);
    }
    if(this.headers != null) {
      args['headers'] = this.headers;
    }
    if(args['headers'] is String && args['headers'].isNotEmpty) {
      args['headers'] = JSON.decode(args['headers']);
    }
    args['callback'] = this._receive;
    args['url'] = this.url;
    args['method'] = this.method;

    return args.containsKey('url') && this._xhr.request(args) != null;
  }
}

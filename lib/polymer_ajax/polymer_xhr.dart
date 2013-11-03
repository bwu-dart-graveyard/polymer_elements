// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

/**
 * polymer-xhr can be used to perform XMLHttpRequests.
 
 * Example:
 *
 *     <polymer-xhr id="xhr"></polymer-xhr>
 *     ...
 *     this.$.xhr.request({url: url, params: params, callback: callback});
 * 
 * (egrimes) TODO:  Match dart's HttpRequest naming?
 */

library polymer_elements.polymer_xhr;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('polymer-xhr')
class PolymerXhr extends PolymerElement {
  
  PolymerXhr.created() : super.created();
  
  _makeReadyStateHandler(xhr, callback) {
    var sub;
    sub = xhr.onReadyStateChange.listen((_) {
      if (xhr.readyState == 4 && callback != null) {
        callback(xhr.response, xhr);
        sub.cancel();
      }
    });
  }
  
  _setRequestHeaders(xhr, headers) {
    if (headers != null) {
      for (var name in headers.keys) {
        xhr.setRequestHeader(name, headers[name]);
      }
    }
  }
  
  _toQueryString(params) {
    var r = [];
    for (var n in params.keys) {
      var v = params[n];
      n = Uri.encodeComponent(n);
      r.add(v == null ? n : (n + '=' + Uri.encodeComponent(v)));
    }
    var buffer = new StringBuffer();
    r.forEach((i){
      buffer.write(i);
      buffer.write('&');
    });
    var qs = buffer.toString();
    if(qs.endsWith('&')){
      qs = qs.substring(0, qs.length - 1);
    }
    return qs;
  }
  
  /**
   * Sends a HTTP request to the server and returns the XHR object.
   */
  request(options) {
    var xhr = new HttpRequest();
    var url = options['url'];
    var method = _valueOrDefault(options['method'], 'GET');
    var async =  _valueOrDefault(options['sync'], true);
    var params = this._toQueryString(_valueOrDefault(options['params'],{}));
    if (params.isNotEmpty && method == 'GET') {
      url += (url.indexOf('?') > 0 ? '&' : '?') + params;
    }
    xhr.open(method, url, async: async);
    if (options.containsKey('responseType')) {
      xhr.responseType = options['responseType'];
    }
    this._makeReadyStateHandler(xhr, options['callback']);
    this._setRequestHeaders(xhr, options['headers']);
    xhr.send(method == 'POST' ? (options.containsKey('body') ? options['body'] : params) : null);
    
    /**
     * TODO Figure out what to do in the case of the polymer.js "synchronous" 
     * mode. 
     * if (!async) {
     *     xhr.onreadystatechange(xhr);
     *   }
     * 
     */
    
    return xhr;
  }

  _valueOrDefault(value, defaultValue){
    if(value == null) return defaultValue;
    if(value is String && value.isEmpty) return defaultValue;
    return value;
  }
  
}
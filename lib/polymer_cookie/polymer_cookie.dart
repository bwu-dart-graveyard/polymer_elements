// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_cookie;

import 'dart:html' show document;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, published,
    ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved  
// https://code.google.com/p/dart/issues/detail?id=13849
// (https://code.google.com/p/dart/issues/detail?id=15095)

var EXPIRE_NOW = 'Thu, 01 Jan 1970 00:00:00 GMT';
var FOREVER = 'Fri, 31 Dec 9999 23:59:59 GMT';

@CustomTag('polymer-cookie')
class PolymerCookie extends PolymerElement {
  
  @published
  String expires = FOREVER;
  
  @published
  String name;
  
  @published
  bool secure = false;
  
  @published
  String value;
  
  @published
  String maxAge;
  
  @published
  String domain;
  
  @published
  String path;
  
  String _expire;
  
  PolymerCookie.created() : super.created();
  
  void ready() {
    this.load();
  }
  
  Iterable<String> _parseCookie() {
    List pairs = document.cookie.split(new RegExp(r'\s*;\s*'));
    var map = pairs.map((kv) {
      var eq = kv.indexOf('=');
      if(eq == -1) {
        return {};
      } else {
        return {
          'name': Uri.decodeComponent(kv.substring(0, eq)),
          'value': Uri.decodeComponent(kv.substring(eq + 1, kv.length))
        };
      }
    });
    var nom = this.name;
    return map.where((kv) {return kv['name'] == nom;});
  }
  
  void load() {
    var kv = this._parseCookie();
    this.value = kv.isNotEmpty ? kv.first['value'] : null;
  }
  
  void valueChanged(old) {
    this._expire = FOREVER;
    this.save();
  }
  
  // TODO(dfreedman): collapse these when 'multiple props -> single change function' exists in Polymer
  void expiresChanged() {
    this.save();
  }
  
  void secureChanged() {
    this.save();
  }
  
  void domainChanged() {
    this.save();
  }
  
  void pathChanged() {
    this.save();
  }
  
  void maxAgeChanged() {
    this.save();
  }
  
  //TODO This isn't used anywhere.  Is it part of the public api? If so, what
  //does it do?
  // return Boolean(this.parseCookie())
  bool isCookieStored() {
    return this._parseCookie().isNotEmpty;
  }
  
  void deleteCookie() {
    this.expires = EXPIRE_NOW;
  }
  
  String prepareProperties() {
    var prepared = new StringBuffer();
    if(expires != null) {
      prepared.write('; expires=');
      prepared.write(expires);
    }
    
    if(secure) {
      prepared.write('; secure=');
      prepared.write(secure);
    }
    
    if(maxAge != null) {
      prepared.write('; max-age=');
      prepared.write(maxAge);
    }
    
    if(domain != null) {
      prepared.write('; domain=');
      prepared.write(domain);
    }
    
    if(path != null) {
      prepared.write('; path=');
      prepared.write(path);
    }
    
    return prepared.toString();
  }
  
  void save() {
    // omitting null check for value leads to an exception in JS
    document.cookie = Uri.encodeComponent(this.name) + '=' + 
        Uri.decodeComponent(this.value != null ? this.value : '') + 
        this.prepareProperties();
  }
}
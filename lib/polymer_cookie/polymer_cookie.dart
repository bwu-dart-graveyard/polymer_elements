// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_cookie;

import 'dart:html' show document;
import 'package:polymer/polymer.dart' show CustomTag, PolymerElement, published,
    ChangeNotifier, reflectable; // TODO remove ChangeNotifier, reflectable when bug is solved https://code.google.com/p/dart/issues/detail?id=15095

  var EXPIRE_NOW = 'Thu, 01 Jan 1970 00:00:00 GMT';
  var FOREVER = 'Fri, 31 Dec 9999 23:59:59 GMT';
  var cookieProps = ['expires', 'secure', 'max-age', 'domain', 'path'];
  
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
    
    ready() {
      this.load();
    }
    
    Iterable _parseCookie() {
     List pairs = document.cookie.split(new RegExp(r'\s*;\s*'));
      var map = pairs.map((kv) {
        
        var eq = kv.indexOf('=');
        if(eq == -1){
          return  {
            
          };
        }else {
        return {
          'name': Uri.decodeComponent(kv.substring(0, eq)),
          'value': Uri.decodeComponent(kv.substring(eq + 1, kv.length))
        };
        }
      });
      var nom = this.name;
      
      return map.where((kv) {return kv['name'] == nom;});
      
    }
    
    load() {
      var kv = this._parseCookie();
      this.value = kv.isNotEmpty ? kv.first['value'] : null;
    }
    
    valueChanged(old) {
      this._expire = FOREVER;
      this.save();
    }
    
    // TODO(dfreedman): collapse these when 'multiple props -> single change function' exists in Polymer
    expiresChanged() {
      this.save();
    }
    
    secureChanged() {
      this.save();
    }
    
    domainChanged() {
      this.save();
    }
    
    pathChanged() {
      this.save();
    }
    
    maxAgeChanged() {
      this.save();
    }
    
    //TODO This isn't used anywhere.  Is it part of the public api? If so, what
    //does it do?
    // return Boolean(this.parseCookie())
    isCookieStored() {
      return this._parseCookie().isNotEmpty;
    }
    
    deleteCookie() {
      this.expires = EXPIRE_NOW;
    }
    
    prepareProperties() {
      var prepared = new StringBuffer();
      var cookieProps = ['expires', 'secure', 'max-age', 'domain', 'path'];
      if(expires != null) {
        prepared.write('; '); 
        prepared.write('expires=');
        prepared.write(expires);
      }
      
      if(secure) {
        prepared.write('; '); 
        prepared.write('secure=');
        prepared.write(secure);
      }
      
      if(maxAge != null) {
        prepared.write('; '); 
        prepared.write('max-age=');
        prepared.write(maxAge);
      }
      
      if(domain != null) {
        prepared.write('; '); 
        prepared.write('domain=');
        prepared.write(domain);
      }
      
      if(path != null) {
        prepared.write('; '); 
        prepared.write('path=');
        prepared.write(path);
      }
      
      return prepared.toString();
    }
    
    save() {
      document.cookie = Uri.encodeComponent(this.name) + '=' + Uri.decodeComponent(this.value) + this.prepareProperties();
    }
  }
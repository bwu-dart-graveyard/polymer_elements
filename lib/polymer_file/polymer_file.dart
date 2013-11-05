// Copyright (c) 2013, the polymer_elements.dart project authors.  Please see 
// the AUTHORS file for details. All rights reserved. Use of this source code is 
// governed by a BSD-style license that can be found in the LICENSE file.
// This work is a port of the polymer-elements from the Polymer project, 
// http://www.polymer-project.org/. 

library polymer_elements.polymer_file;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'package:logging/logging.dart';

/**
 * polymer-file provides File API operations.
 *
 * Examples:
 *
 *     <polymer-file id="file" readas="dataurl" 
 *                   on-polymer-result="{{handleResult}}"></polymer-file>
 *     ...
 *     this.$.file.blob = new Blob(['abc'], {type: 'text/plain'});
 *     this.$.file.read();
 *
 *     ---
 *
 *     <polymer-file id="file" readas="arraybuffer" auto
 *                   result="{{result}}"></polymer-file>
 *     ...
 *     this.$.file.blob = new Blob(['abc'], {type: 'text/plain'});
 *
 * @class polymer-file
 */
@CustomTag('polymer-file')
class PolymerFile extends PolymerElement {
  PolymerFile.created() : super.created();

  final _logger = new Logger('PolymerAnchorPoint');

  /**
   * Contains the result of a read operation.
   * @type Blob|File
   */
  @published var result = null;
  
  /**
   * The Blob-like object to read.
   * @type Blob|File
   */
  @published var blob = null;

  /**
   * If true, automatically performs the file read (if a blob has been set).
   */
  @published bool auto = false;
  
  // TODO Dart reader doesn't support 'binarystring'. What is it anyway?
  /**
   * The format the result should be returned as. One of 'arraybuffer', 'text',
   * 'dataurl'. 
   */
  @published String readas = 'text';
  
  static const EventStreamProvider<CustomEvent> _fileReadResultEvent =
      const EventStreamProvider<CustomEvent>('polymer-result');
  
  /**
   * Fired when a file read has complete.
   * [detail] contains the result of the read.
   */
  Stream<CustomEvent> get onFileReadResult =>
      PolymerFile._fileReadResultEvent.forTarget(this);

  
  static const EventStreamProvider<CustomEvent> _fileReadErrorEvent =
      const EventStreamProvider<CustomEvent>('polymer-error');
  
  /**
   * Fired if there is an error in the file read.
   * [detail] contains information on the error.
   * @param {Object} detail.error Information on the error.
   */
  Stream<CustomEvent> get onFileReadError => 
      PolymerFile._fileReadErrorEvent.forTarget(this);

  
  void blobChanged(oldValue) {
    // result is set at end of microtask in read. This won't call resultChanged.
    this.result = null;
    if (this.auto) {
      this.read();
    }
  }
  
  
  void resultChanged(oldValue) {
    dispatchEvent(new CustomEvent('polymer-result', detail: this.result));
  }
  
  void read() {
    // Send back same result if blob hasn't changed.
    if (this.result != null || this.blob == null) {
      // Wrap in asyncMethod for situations where read() is called immediately.
      scheduleMicrotask(() => 
          dispatchEvent(new CustomEvent('polymer-result', detail: this.result)));
      return;
    }

    // TODO: reader.abort() a in-flight read.
    var reader = new FileReader();
    reader
    ..onLoadEnd.listen((e) => this.result = e.target.result)
    ..onError.listen((e) => 
        dispatchEvent(new CustomEvent('polymer-error', detail: e.target.error)));

    switch(this.readas) {
      case 'dataurl':
        reader.readAsDataUrl(this.blob);
        break;
      case 'arraybuffer':
        reader.readAsArrayBuffer(this.blob);
        break;
//  TODO    case 'binarystring':
//        reader.readAsBinaryString(this.blob);
//        break;
      case 'text':
        // Default to text.
      default:
        reader.readAsText(this.blob);
        break;
    }
  }
}



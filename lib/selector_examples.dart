// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library polymer.elements.selector_examples;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('selector-examples')
class SelectorExamples extends PolymerElement {
  
  final multiSelected = [1, 3];
  
  @observable
  String color = 'green';
  
  SelectorExamples.created() : super.created();
  
}
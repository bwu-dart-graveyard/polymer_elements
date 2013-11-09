library x_test1;

import 'package:polymer/polymer.dart';

@CustomTag('x-test1')
class XTest1 extends PolymerElement {
  @published String value = '';
  
  XTest1.created() : super.created();
}
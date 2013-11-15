library x_test2;

import 'package:polymer/polymer.dart';

@CustomTag('x-test2')
class XTest2 extends PolymerElement {
  XTest2.created() : super.created();
  
  @published bool mode = false;
}
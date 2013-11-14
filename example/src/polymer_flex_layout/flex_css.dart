library flex_css;

import 'package:polymer/polymer.dart';

@CustomTag('flex-css')
class FlexCss extends PolymerElement {
  FlexCss.created() : super.created();

  @override
  void ready() {
    super.ready();
    this.classes.add('flexbox');
  }
}
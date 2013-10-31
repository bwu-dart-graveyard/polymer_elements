library polymer_flex_panel;

import 'package:polymer/polymer.dart';
import 'polymer_flex_layout.dart';

@CustomTag('polymer-flex-panel')
class PolymerFlexPanel extends PolymerFlexLayout {
  PolymerFlexPanel.created() : super.created();

  @override
  void polymerCreated() {
    isContainer = true;
    super.polymerCreated();
  }
}

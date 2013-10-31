library flex_container;

//import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/polymer_flex_layout/polymer_flex_panel.dart';

// Polymer has problems with inheriance when noscript is used
@CustomTag('flex-container')
class FlexContainer extends PolymerFlexPanel {
  FlexContainer.created() : super.created();
}

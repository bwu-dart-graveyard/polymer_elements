library polymer_collapse_toggle;

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'polymer_collapse.dart';

import 'package:logging/logging.dart';

@CustomTag('polymer-collapse-toggle')
class PolymerCollapseToggle extends PolymerElement {
  PolymerCollapseToggle.created() : super.created();

  final _logger = new Logger('PolymerCollapseButton');

  /**
   * The selector for the target polymer-collapse element.
   */
  @published String target = '';
  
  bool get applyAuthorStyles => true;
  
  void handleClick([e]) {
    _logger.finest("handleClick '${target}'");
    var t = (document.querySelector(target) as PolymerCollapse);
    if (t != null) {
      t.toggle();
    }
  }
}

import 'package:polymer/builder.dart';

void main(args) {
  build(entryPoints: [
                      'example/ajax_example.html',
                      'example/polymer_ajax_demo.html',
                      'example/polymer_anchor_point.html',
                      'example/polymer_animation.html',
                      'example/polymer_collapse.html',
                      'example/polymer_flex_layout.html',
                      'example/polymer_selection_demo.html',
                      'example/polymer_selector_demo.html',
                      'example/selection_example.html',
                      'example/selector_examples.html',
                      
                      'test/polymer_collapse.html'
                      ],
                      options: parseOptions(args));
}
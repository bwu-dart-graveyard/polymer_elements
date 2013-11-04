import 'package:polymer/builder.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

var entryPoints = [
                      'web/polymer_ajax.html',
                      'web/polymer_anchor_point.html',
                      'web/polymer_animation.html',
                      'web/polymer_collapse.html',
                      'web/polymer_flex_layout.html',
                      'web/polymer_localstorage.html',
                      'web/polymer_media_query.html',
                      'web/polymer_selection.html',
                      'web/polymer_selector.html',

/*                      'example/polymer_ajax.html',
                      'example/polymer_anchor_point.html',
                      'example/polymer_animation.html',
                      'example/polymer_collapse.html',
                      'example/polymer_flex_layout.html',
                      'example/polymer_localstorage.html',
                      'example/polymer_media_query.html,
                      'example/polymer_selection.html',
                      'example/polymer_selector.html',
*/                      
                      'test/polymer_collapse.html'
                      'test/polymer_localstorage.html'
                      ];
void main(args) {
  var options = parseOptions(args);
  build(entryPoints: entryPoints, options: options);
//  lint(entryPoints: entryPoints, options: options)
//    .then((_) => deploy(entryPoints: entryPoints, options: options))
//    .then(compileToJs(entryPoints));
}

compileToJs(List<String> entryPoints) {
  print("Running dart2js");
  var dart2js = join(dirname(Platform.executable), 'dart2js');
  entryPoints.forEach((e) {
    var arguments = [//'--minify',
                     '-c', // checked mode
                     '-o', 'out/${e}_bootstrap.dart.js',
                     'out/${e}_bootstrap.dart']; 
    print('\n=== ${e} ===');
    print(">> ${dart2js} ${arguments.join(" ")}\n");
    var result =
      Process.runSync(dart2js, arguments, runInShell: true);
    print(result.stdout);
  });
  print("Done");
}
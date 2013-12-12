# Basic non-visual elements for Polymer.dart

A port of polymer.js' [polymer-elements](https://github.com/Polymer/polymer-elements) to Polymer.dart. 
The intent of the authors is to contribute the work to the Dart project itself (https://www.dartlang.org).

### Visual elements for Dart can be found in
* [polymer_ui_elements](https://github.com/ErikGrimes/polymer_ui_elements)

## Documentation
* The Dart source files of an element often contains some documentation (Dartdoc) how to use the element. You can find the documentation online at  
* [DartDoc](http://erikgrimes.github.io/polymer_elements/docs/index.html)
* Almost each element has an associated demo page which shows how to use the element. 
Open the 'demo' links below to take a look.
The source code of these demo pages can be found in the [example subdirectory of the package](https://github.com/ErikGrimes/polymer_elements/tree/master/example). 
The actual implementation of the demo page is often outsourced to files in the `example/src/element_name` subdirectory.

## Usage
* add the following to your pubspec.yaml file: 

```yaml
dependencies:
  polymer_elements:
```

* to import a polymer_element into your entry page HTML file, add the following line inside the `<head>` tag before any of the Dart and polymer `<script>` tags: 
  
```html  
<link rel="import" href="packages/polymer_elements/polymer_file/polymer_file.html">
```

* to import a polymer_element into any of your custom polymer elements, add the following line into your Polymer element HTML file before the `<polymer-element name="my-element">` start tag:
  
```html
<link rel="import" href="../../../packages/polymer_elements/polymer_selector/polymer_selector.html">
```

If you import a polymer_element into an HTML file that is not saved in the `package/web` directory  the import path must be relative to the `web` directory as shown above.
In this example we assume the HTML file is stored in `yourpackage/lib/your_element/your_element.html`.

## General notes

* Current development status requires Dart SDK Dart version 1.0.3.0_r30939 (DEV)

### Status
(A few demo pages (* aren't rendered properly as GitHub Pages or because they use unfinished elements. We are working on it.) 

Element name                    |   Status         | Comment      | Demo
------------------------------- | ---------------- | ------------ | ----
polymer-ajax                    | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_ajax.html)
polymer-anchor-point            | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_anchor_point.html)&nbsp;(*
polymer-collapse                | **ported**       | needs some additional stylesheet imports due to Polymer.dart limitations (see examples) | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_collapse.html)
polymer-cookie                  | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_cookie.html)
polymer-file                    | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_file.html)
polymer-flex-layout             | **ported**       | needs some additional stylesheet imports due to Polymer.dart limitations (see examples) | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_flex_layout.html)&nbsp;(*
polymer-google-jsapi            | not&nbsp;started |              | 
polymer-grid-layout             | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_grid_layout.html)
polymer-jsonp                   | not&nbsp;started |              |
polymer-key-helper              | not&nbsp;started |              |
polymer-layout                  | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_layout.html)
polymer-localstorage            | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_localstorage.html)&nbsp;
polymer-media-query             | **ported**       | small issue in Dart but works fine in JS  | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_media_query.html)
polymer-meta                    | ported           | doesn't work in JavaScript  |
polymer-mock-data               | not&nbsp;started |              |
polymer-overlay                 | started          |              |
polymer-page                    | **ported**       |              |
polymer-scrub                   | not&nbsp;started |              | (no demo)
polymer-selection               | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_selection.html)
polymer-selector                | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_selector.html)
polymer-shared-lib              | started          |              |
polymer-signals                 | **ported**       |              | [demo](http://erikgrimes.github.io/polymer_elements/build/polymer_signals.html)
polymer&#8209;view&#8209;source&#8209;link        | not&nbsp;started |              |


### License
BSD 3-clause license (see [LICENSE](https://github.com/ErikGrimes/polymer_elements/blob/master/LICENSE) file).

[![Build Status](https://drone.io/github.com/ErikGrimes/polymer_elements/status.png)](https://drone.io/github.com/ErikGrimes/polymer_elements/latest)


## 0.2.0

* upgrade to polymer 0.10.0
* fix drone.io build (activate download of content_shell)
* updating several elements fixed several issues 
* remove old css files (were kept for compatibitlity with older selectors)

* add polymer-overlay

* update polymer-ajax
* update polymer-anchor-point
* update polymer-collapse
  fix using transform on first expansion
* update polymer-flex-layout
  remove polymer-flex-area workaround
* update polymer-meta
* update polymer-selection
* update polymer-selector
  add onPolymerSelect getter
* update polmyer-signals
  fix concurrency exception issue when dynamicylly adding the element
* update polymer-grid-layout

* port tests for polymer-selector
* port tests for polymer-selection    
    

## 0.1.2

* add 'polymer-layout' event when layout is done

## 0.1.1+3 (2013-12-18)

* remove accidentally included unfinished fragments of polymer-list

## 0.1.1+2 (2013-12-18)

* temporary remove dependency on polymer_ui_elements to avoid pub build/serve problems due to circular dependency
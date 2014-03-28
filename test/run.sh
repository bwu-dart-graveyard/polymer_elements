#!/bin/bash
which content_shell
if [[ $? -ne 0 ]]; then
  $DART_SDK/../chromium/download_contentshell.sh
  unzip content_shell-linux-x64-release.zip

  cs_path=$(ls -d drt-*)
  PATH=$cs_path:$PATH
fi

content_shell --dump-render-tree polymer_ajax.html
content_shell --dump-render-tree polymer_collapse.html
content_shell --dump-render-tree polymer_file.html
content_shell --dump-render-tree polymer_localstorage.html
content_shell --dump-render-tree polymer_selection.html
content_shell --dump-render-tree polymer_selection_multi.html
content_shell --dump-render-tree polymer_selector_activate_event.html
content_shell --dump-render-tree polymer_selector_basic.html
content_shell --dump-render-tree polymer_selector_multi.html

#!/usr/bin/env bash

koopa_macos_link_homebrew() {
    local dict
    declare -A dict
    koopa_assert_has_no_args "$#"
    # BBEdit cask.
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    # Emacs cask.
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    # R cask.
    dict[r]="$(koopa_macos_r_prefix)"
    koopa_link_in_bin \
        "${dict[r]}/bin/R" 'R' \
        "${dict[r]}/bin/Rscript" 'Rscript'
    # Visual Studio Code cask.
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
}


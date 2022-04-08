#!/usr/bin/env bash

koopa_macos_link_homebrew() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [cask]="$(koopa_homebrew_cask_prefix)"
    )
    # BBEdit cask.
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    # Emacs cask.
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    # Google Cloud SDK cask.
    koopa_link_in_bin \
        "${dict[cask]}/google-cloud-sdk/latest/google-cloud-sdk/bin/gcloud" \
        'gcloud'
    # Julia cask.
    dict[julia]="$(koopa_macos_julia_prefix)"
    koopa_link_in_bin \
        "${dict[julia]}/bin/julia" \
        'julia'
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

koopa_macos_unlink_homebrew() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin \
        'R' \
        'Rscript' \
        'bbedit' \
        'code' \
        'emacs' \
        'gcloud' \
        'julia'
    return 0
}

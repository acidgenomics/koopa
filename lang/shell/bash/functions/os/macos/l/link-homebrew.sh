#!/usr/bin/env bash

koopa_macos_link_homebrew() {
    # """
    # Link additional Homebrew-managed CLI tools into koopa bin.
    # @note Updated 2022-08-02.
    # """
    local dict
    declare -A dict
    koopa_assert_has_no_args "$#"
    # BBEdit cask.
    koopa_link_in_bin \
        --name='bbedit' \
        --source='/Applications/BBEdit.app/Contents/Helpers/bbedit_tool'
    # Emacs cask.
    koopa_link_in_bin \
        --name='emacs' \
        --source='/Applications/Emacs.app/Contents/MacOS/Emacs'
    # R cask.
    dict[r]="$(koopa_macos_r_prefix)"
    koopa_link_in_bin \
        --name='R' \
        --source="${dict['r']}/bin/R"
    koopa_link_in_bin \
        --name='Rscript' \
        --source="${dict['r']}/bin/Rscript"
    # Visual Studio Code cask.
    koopa_link_in_bin \
        --name='code' \
        --source="/Applications/Visual Studio Code.app/Contents/Resources/\
app/bin/code"
}


#!/usr/bin/env bash

koopa::macos_install_xcode_clt() {
    # """
    # Install Xcode CLT.
    # @note Updated 2020-07-17.
    # @seealso
    # - https://apple.stackexchange.com/questions/93573/
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Xcode CLT'
    koopa::install_start "$name_fancy"
    prefix="$(xcode-select -p 2>/dev/null)"
    [[ -d "$prefix" ]] && koopa::rm -S "$prefix"
    xcode-select --install
    sudo xcodebuild -license accept
    sudo xcode-select -r
    xcode-select -p
    koopa::install_success "$name_fancy"
    return 0
}


#!/usr/bin/env bash

koopa::macos_install_xcode_clt() { # {{{1
    koopa:::install_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_xcode_clt() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa:::macos_install_xcode_clt() { # {{{1
    # """
    # Install Xcode CLT.
    # @note Updated 2021-10-30.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/93573/
    #
    # Alternative minimal approach (used previously for Homebrew):
    # > xcode-select --install &>/dev/null || true
    #
    # How to install non-interactively (currently a bit hacky):
    # - https://apple.stackexchange.com/questions/107307/
    # - https://github.com/Homebrew/install/blob/
    #     878b5a18b89ff73f2f221392ecaabd03c1e69c3f/install#L297
    # """
    local app prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [xcode_select]="$(koopa::locate_xcode_select)"
        [xcodebuild]="$(koopa::locate_xcodebuild)"
    )
    prefix="$("${app[xcode_select]}" -p 2>/dev/null || true)"
    if [[ -d "$prefix" ]]
    then
        koopa::rm --sudo "$prefix"
    fi
    # This step will prompt interactively, which is annoying. See above for
    # alternative workarounds that are more complicated, but may improve this.
    "${app[xcode_select]}" --install
    "${app[sudo]}" "${app[xcodebuild]}" -license 'accept'
    "${app[sudo]}" "${app[xcode_select]}" -r
    prefix="$("${app[xcode_select]}" -p)"
    koopa::assert_is_dir "$prefix"
    return 0
}

koopa:::macos_uninstall_xcode_clt() { # {{{1
    # """
    # Uninstall Xcode CLT.
    # @note Updated 2021-10-30.
    # @seealso
    # - https://apple.stackexchange.com/questions/308943
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    prefix='/Library/Developer/CommandLineTools'
    koopa::assert_is_dir "$prefix"
    koopa::rm --sudo "$prefix"
    return 0
}

#!/usr/bin/env bash

koopa::macos_install_xcode_clt() { # {{{1
    # """
    # Install Xcode CLT.
    # @note Updated 2021-06-11.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/93573/
    #
    # Alternative minimal approach (used previously for Homebrew):
    # > xcode-select --install &>/dev/null || true
    #
    # How to install non-interactively:
    # - https://apple.stackexchange.com/questions/107307/
    # - https://github.com/Homebrew/install/blob/
    #     878b5a18b89ff73f2f221392ecaabd03c1e69c3f/install#L297
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Xcode CLT'
    koopa::install_start "$name_fancy"
    prefix="$(xcode-select -p 2>/dev/null || true)"
    [[ -d "$prefix" ]] && koopa::rm --sudo "$prefix"
    # This step will prompt interactively, which is annoying. See above for
    # alternative workarounds that are more complicated, but may improve this.
    xcode-select --install
    sudo xcodebuild -license 'accept'
    sudo xcode-select -r
    prefix="$(xcode-select -p)"
    koopa::assert_is_dir "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::macos_uninstall_xcode_clt() { # {{{1
    # """
    # Uninstall Xcode CLT.
    # @note Updated 2021-06-11.
    # @seealso
    # - https://apple.stackexchange.com/questions/308943
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Xcode CLT'
    prefix='/Library/Developer/CommandLineTools'
    koopa::uninstall_start "$name_fancy" "$prefix"
    koopa::assert_is_dir "$prefix"
    koopa::rm --sudo "$prefix"
    koopa::uninstall_success "$name_fancy" "$prefix"
    return 0
}

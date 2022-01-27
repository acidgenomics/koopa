#!/usr/bin/env bash

koopa:::macos_uninstall_xcode_clt() { # {{{1
    # """
    # Uninstall Xcode CLT.
    # @note Updated 2021-10-30.
    # @seealso
    # - https://apple.stackexchange.com/questions/308943
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [prefix]='/Library/Developer/CommandLineTools'
    )
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::rm --sudo "${dict[prefix]}"
    return 0
}

#!/usr/bin/env bash

macos_uninstall_xcode_clt() { # {{{1
    # """
    # Uninstall Xcode CLT.
    # @note Updated 2021-10-30.
    # @seealso
    # - https://apple.stackexchange.com/questions/308943
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [prefix]='/Library/Developer/CommandLineTools'
    )
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_rm --sudo "${dict[prefix]}"
    return 0
}

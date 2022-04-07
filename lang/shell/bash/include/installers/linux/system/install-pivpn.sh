#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install PiVPN.
    # @note Updated 2022-01-31.
    #
    # @seealso
    # - https://www.pivpn.io
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [file]='pivpn.sh'
        [url]='https://install.pivpn.io'
    )
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "./${dict[file]}"
    return 0
}

#!/usr/bin/env bash

koopa:::linux_install_pivpn() { # {{{1
    # """
    # Install PiVPN.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://www.pivpn.io
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [file]='pivpn.sh'
        [url]='https://install.pivpn.io'
    )
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    "./${dict[file]}"
    return 0
}

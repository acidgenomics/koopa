#!/usr/bin/env bash

main() {
    # """
    # Install PiVPN.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.pivpn.io
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']='pivpn.sh'
    dict['url']='https://install.pivpn.io'
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    "./${dict['file']}"
    return 0
}

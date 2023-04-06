#!/usr/bin/env bash

main() {
    # """
    # Install Pi-hole.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://pi-hole.net
    # - https://github.com/pi-hole/pi-hole/#one-step-automated-install
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']='pihole.sh'
    dict['url']='https://install.pi-hole.net'
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    "./${dict['file']}"
    return 0
}

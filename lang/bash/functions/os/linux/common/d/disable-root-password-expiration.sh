#!/usr/bin/env bash

koopa_linux_disable_root_password_expiration() {
    # """
    # Disable root password expiration.
    # @note Updated 2025-04-17.
    #
    # @seealso
    # - https://access.redhat.com/solutions/4821441
    # """
    koopa_assert_has_no_args "$#"
    koopa_sudo -i chage -M 99999 root
    return 0
}

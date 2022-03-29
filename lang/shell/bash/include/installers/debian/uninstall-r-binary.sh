#!/usr/bin/env bash

debian_uninstall_r_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2022-01-28.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc'
    koopa_debian_apt_remove 'r-*'
    koopa_debian_apt_delete_repo 'r'
    return 0
}

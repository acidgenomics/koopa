#!/usr/bin/env bash

koopa:::debian_uninstall_r_cran_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2022-01-28.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc'
    koopa::debian_apt_remove 'r-*'
    koopa::debian_apt_delete_repo 'r'
    return 0
}

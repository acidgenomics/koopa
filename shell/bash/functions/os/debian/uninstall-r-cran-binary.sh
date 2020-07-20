#!/usr/bin/env bash

koopa::debian_uninstall_r_cran_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2020-07-16.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='R CRAN binary'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::rm -S '/etc/R' '/usr/lib/R/etc'
    koopa::apt_remove 'r-*'
    koopa::uninstall_success "$name_fancy"
    return 0
}

#!/usr/bin/env bash

koopa:::debian_uninstall_pandoc() { # {{{1
    # """
    # Uninstall Pandoc.
    # @note Updated 2021-11-02.
    # May not need (or want) to install 'pandoc-data' here.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_remove 'pandoc' 'pandoc-data'
    return 0
}

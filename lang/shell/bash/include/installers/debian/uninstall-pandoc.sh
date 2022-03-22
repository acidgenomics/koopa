#!/usr/bin/env bash

debian_uninstall_pandoc() { # {{{1
    # """
    # Uninstall Pandoc.
    # @note Updated 2021-11-02.
    # May not need (or want) to install 'pandoc-data' here.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_remove 'pandoc' 'pandoc-data'
    return 0
}

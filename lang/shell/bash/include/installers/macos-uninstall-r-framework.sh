#!/usr/bin/env bash

koopa:::macos_uninstall_r_framework() { # {{{1
    # """
    # Uninstall R framework.
    # @note Updated 2021-11-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    return 0
}

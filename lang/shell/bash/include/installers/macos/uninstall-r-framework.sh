#!/usr/bin/env bash

macos_uninstall_r_framework() { # {{{1
    # """
    # Uninstall R framework.
    # @note Updated 2021-11-04.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa_delete_broken_symlinks '/usr/local/bin'
    return 0
}

#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall R framework binary.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa_delete_broken_symlinks '/usr/local/bin'
    return 0
}

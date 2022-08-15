#!/usr/bin/env bash

main() {
    # """
    # Uninstall Python framework binary.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa_delete_broken_symlinks '/usr/local/bin'
    return 0
}

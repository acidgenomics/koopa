#!/usr/bin/env bash

macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2021-11-02.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa_delete_broken_symlinks '/usr/local/bin'
    return 0
}

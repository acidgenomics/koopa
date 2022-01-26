#!/usr/bin/env bash

koopa:::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    return 0
}

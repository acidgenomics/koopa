#!/usr/bin/env bash

main() {
    # """
    # Uninstall Python framework binary.
    # @note Updated 2022-04-11.
    # """
    koopa_rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework' \
        '/usr/local/lib/python'*
    koopa_delete_broken_symlinks '/usr/local/bin'
    return 0
}

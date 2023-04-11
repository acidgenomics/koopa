#!/usr/bin/env bash

main() {
    # """
    # Uninstall Python framework binary.
    # @note Updated 2022-04-11.
    # """
    local -a rm_files
    [[ -d '/Library/Frameworks/Python.framework' ]] || return 0
    rm_files=(
        '/Library/Frameworks/Python.framework'
        '/usr/local/bin/2to3'
        '/usr/local/bin/idle3'
        '/usr/local/bin/pip3'
        '/usr/local/bin/pydoc3'
        '/usr/local/bin/python'
        '/usr/local/bin/python3'
        '/usr/local/bin/python3-config'
    )
    koopa_rm --sudo "${rm_files[@]}"
    koopa_rm --sudo \
        '/Applications/Python'* \
        '/usr/local/bin/2to3-'* \
        '/usr/local/bin/idle3.'* \
        '/usr/local/bin/pip3.'* \
        '/usr/local/bin/pydoc3.'* \
        '/usr/local/bin/python3-'* \
        '/usr/local/bin/python3.'* \
        '/usr/local/lib/python'*
    return 0
}

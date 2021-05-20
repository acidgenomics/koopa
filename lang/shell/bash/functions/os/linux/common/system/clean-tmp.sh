#!/usr/bin/env bash

koopa::linux_clean_tmp() { # {{{1
    # """
    # Clean temporary directory.
    # @note Updated 2021-05-20.
    # """
    local dir dirs
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    koopa::assert_is_gnu 'find'
    dirs=('/tmp')
    if [[ "${TMPDIR:-}" != '/tmp' ]]
    then
        dirs+=("$TMPDIR")
    fi
    for dir in "${dirs[@]}"
    do
        sudo find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -ctime +30 \
            -exec rm -frv {} \;
    done
    return 0
}

#!/usr/bin/env bash

koopa::linux_clean_tmp() { # {{{1
    # """
    # Clean temporary directory.
    # @note Updated 2020-11-16.
    # """
    local dir dirs
    koopa::assert_has_no_args "$#"
    dirs=('/tmp')
    [[ "${TMPDIR:-}" != '/tmp' ]] && dirs+=("$TMPDIR")
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


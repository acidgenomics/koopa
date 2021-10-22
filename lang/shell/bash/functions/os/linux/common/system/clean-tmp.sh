#!/usr/bin/env bash

# FIXME Can we also extend this to macOS? May be generally useful.
koopa::linux_clean_tmp() { # {{{1
    # """
    # Clean temporary directory.
    # @note Updated 2021-05-21.
    # """
    local dir dirs find matches
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    find="$(koopa::locate_find)"
    dirs=('/tmp')
    if [[ "${TMPDIR:-}" != '/tmp' ]]
    then
        dirs+=("$TMPDIR")
    fi
    for dir in "${dirs[@]}"
    do
        # FIXME Rework using 'koopa::find'.
        readarray -t matches <<< "$( \
        sudo "$find" "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -ctime +30 \
            -print \
        )"
        koopa::rm --sudo "${matches[@]}"
    done
    return 0
}

#!/usr/bin/env bash

# FIXME Need to add support for '-ctime XXX' into our koopa::find function.
# FIXME Can we also extend this to macOS? May be generally useful.
# FIXME Need to add '--sudo' flag support to koopa::find.

koopa::linux_clean_tmp() { # {{{1
    # """
    # Clean temporary directory.
    # @note Updated 2021-11-01.
    # """
    local dir dirs find matches
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
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
        koopa::is_array_non_empty "${matches[@]:-}" || continue
        koopa::rm --sudo "${matches[@]}"
    done
    return 0
}

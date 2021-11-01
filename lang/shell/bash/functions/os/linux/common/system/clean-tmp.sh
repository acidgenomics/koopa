#!/usr/bin/env bash

koopa::linux_clean_tmp() { # {{{1
    # """
    # Clean temporary directory.
    # @note Updated 2021-11-01.
    # """
    local dir dirs matches
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    dirs=('/tmp')
    if [[ "${TMPDIR:-}" != '/tmp' ]]
    then
        dirs+=("$TMPDIR")
    fi
    for dir in "${dirs[@]}"
    do
        readarray -t matches <<< "$( \
        koopa::find \
            --max-depth=1 \
            --min-days-old=30 \
            --min-depth=1 \
            --prefix="$dir" \
            --sudo \
        )"
        koopa::is_array_non_empty "${matches[@]:-}" || continue
        koopa::rm --sudo "${matches[@]}"
    done
    return 0
}

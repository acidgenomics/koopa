#!/usr/bin/env bash

koopa_entab() {
    # """
    # Entab files.
    # @note Updated 2022-05-20.
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [vim]="$(koopa_locate_vim)"
    )
    [[ -x "${app[vim]}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app[vim]}" \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

#!/usr/bin/env bash

_koopa_entab() {
    # """
    # Entab files.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['vim']="$(_koopa_locate_vim)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

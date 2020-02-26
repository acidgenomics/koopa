#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {  # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-02-26.
    # """
    dir="${1:-"."}"
    dir="$(realpath "$dir")"
    mapfile -t arr <<< "$(find-broken-symlinks "$dir")"
    _koopa_is_array_non_empty "${arr[@]}" || return 0
    for file in "${arr[@]}"
    do
        [[ -z "$file" ]] && continue
        _koopa_rm "$file"
    done
    return 0
}

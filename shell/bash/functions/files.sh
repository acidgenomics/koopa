#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {  # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-02-19.
    # """
    dir="${1:-"."}"
    _koopa_assert_is_dir "$dir"
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

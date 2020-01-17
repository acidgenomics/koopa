#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {                                         # {{{1
    # """
    # Remove broken symlinks.
    # Updated 2020-01-17.
    # """
    dir="${1:-"."}"
    _koopa_assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    _koopa_message "Removing broken symlinks in '${dir}'."
    mapfile -t arr <<< "$(find-broken-symlinks "$dir")"
    _koopa_is_array_non_empty "${arr[@]}" || return 0
    for file in "${arr[@]}"
    do
        [[ -z "$file" ]] && continue
        rm -v "$file"
    done
    return 0
}

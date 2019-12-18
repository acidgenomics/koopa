#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {                                         # {{{1
    # """
    # Remove broken symlinks.
    # Updated 2019-11-16.
    # """
    dir="${1:-"."}"
    dir="$(realpath "$dir")"
    _koopa_message "Removing broken symlinks in '${dir}'."
    mapfile -t arr <<< "$(find-broken-symlinks "$dir")"
    _koopa_is_array_non_empty "${arr[@]}" || exit 0
    for file in "${arr[@]}"
    do
        [[ -z "$file" ]] && continue
        rm -v "$file"
    done
}

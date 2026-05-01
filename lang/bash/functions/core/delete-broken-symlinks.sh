#!/usr/bin/env bash

_koopa_delete_broken_symlinks() {
    # """
    # Delete broken symlinks.
    # @note Updated 2020-11-18.
    # """
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a files
        local file
        readarray -t files <<< "$(_koopa_find_broken_symlinks "$prefix")"
        _koopa_is_array_non_empty "${files[@]:-}" || continue
        _koopa_alert_note "Removing ${#files[@]} broken symlinks."
        # Don't pass single call to rm, as argument list can be too long.
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            _koopa_alert "Removing '${file}'."
            _koopa_rm "$file"
        done
    done
    return 0
}

#!/bin/sh

_koopa_remove_from_path() {
    # """
    # Force add to 'PATH' start.
    # @note Updated 2024-09-19.
    # """
    PATH="${PATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        PATH="$(_koopa_remove_from_path_string "$PATH" "$__kvar_dir")"
    done
    export PATH
    unset -v __kvar_dir
    return 0
}

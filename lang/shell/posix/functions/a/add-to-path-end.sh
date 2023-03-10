#!/bin/sh

_koopa_add_to_path_end() {
    # """
    # Force add to 'PATH' end.
    # @note Updated 2023-03-10.
    # """
    PATH="${PATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        PATH="$(_koopa_add_to_path_string_end "$PATH" "$__kvar_dir")"
    done
    export PATH
    unset -v __kvar_dir
    return 0
}

#!/bin/sh

_koopa_add_to_manpath_end() {
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2023-03-10.
    # """
    MANPATH="${MANPATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$__kvar_dir")"
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}

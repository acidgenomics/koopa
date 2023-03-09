#!/bin/sh

_koopa_add_to_manpath_end() {
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2023-03-09.
    # """
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

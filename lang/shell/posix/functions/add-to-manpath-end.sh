#!/bin/sh

koopa_add_to_manpath_end() {
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

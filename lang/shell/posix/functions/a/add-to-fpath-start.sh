#!/bin/sh

koopa_add_to_fpath_start() {
    # """
    # Force add to 'FPATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(__koopa_add_to_path_string_start "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

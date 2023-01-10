#!/bin/sh

koopa_add_to_manpath_start() {
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - /etc/manpath.config
    # """
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_start "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

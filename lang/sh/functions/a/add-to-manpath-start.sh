#!/bin/sh

_koopa_add_to_manpath_start() {
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2022-03-10.
    #
    # @seealso
    # - /etc/manpath.config
    # """
    MANPATH="${MANPATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_start "$MANPATH" "$__kvar_dir")"
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}

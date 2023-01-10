#!/bin/sh

koopa_add_to_path_end() {
    # """
    # Force add to 'PATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_end "$PATH" "$dir")"
    done
    export PATH
    return 0
}

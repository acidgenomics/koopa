#!/bin/sh

koopa_add_to_path_start() {
    # """
    # Force add to 'PATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

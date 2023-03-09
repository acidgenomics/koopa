#!/bin/sh

_koopa_add_to_path_start() {
    # """
    # Force add to 'PATH' start.
    # @note Updated 2023-03-09.
    # """
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(_koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

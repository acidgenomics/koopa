#!/usr/bin/env bash

_koopa_add_to_path_start() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PATH="$(_koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

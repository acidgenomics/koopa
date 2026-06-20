#!/usr/bin/env bash

_koopa_add_to_path_start() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        # Remove existing occurrence then prepend — no subshell needed.
        if [[ ":${PATH}:" == *":${dir}:"* ]]
        then
            PATH="${PATH//:${dir}:/:}"
            PATH="${PATH/#${dir}:/}"
            PATH="${PATH/%:${dir}/}"
        fi
        if [[ -z "$PATH" ]]
        then
            PATH="$dir"
        else
            PATH="${dir}:${PATH}"
        fi
    done
    export PATH
    return 0
}

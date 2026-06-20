#!/usr/bin/env bash

_koopa_add_to_path_end() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
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
            PATH="${PATH}:${dir}"
        fi
    done
    export PATH
    return 0
}

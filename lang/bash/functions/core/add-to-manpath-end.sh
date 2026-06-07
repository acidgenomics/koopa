#!/usr/bin/env bash

_koopa_add_to_manpath_end() {
    MANPATH="${MANPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        if [[ ":${MANPATH}:" == *":${dir}:"* ]]
        then
            MANPATH="${MANPATH//:${dir}:/:}"
            MANPATH="${MANPATH/#${dir}:/}"
            MANPATH="${MANPATH/%:${dir}/}"
        fi
        if [[ -z "$MANPATH" ]]
        then
            MANPATH="$dir"
        else
            MANPATH="${MANPATH}:${dir}"
        fi
    done
    export MANPATH
    return 0
}

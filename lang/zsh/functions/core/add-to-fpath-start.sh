#!/usr/bin/env zsh

_koopa_add_to_fpath_start() {
    FPATH="${FPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        local -a _parts
        _parts=("${(@s/:/)FPATH}")
        _parts=("${(@)_parts:#${dir}}")
        FPATH="${(j/:/)_parts}"
        if [[ -z "$FPATH" ]]
        then
            FPATH="$dir"
        else
            FPATH="${dir}:${FPATH}"
        fi
    done
    export FPATH
    return 0
}

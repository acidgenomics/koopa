#!/usr/bin/env zsh

_koopa_add_to_manpath_end() {
    MANPATH="${MANPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        local -a _parts
        _parts=("${(@s/:/)MANPATH}")
        _parts=("${(@)_parts:#${dir}}")
        MANPATH="${(j/:/)_parts}"
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

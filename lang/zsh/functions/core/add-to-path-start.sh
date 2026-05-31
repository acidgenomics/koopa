#!/usr/bin/env zsh

_koopa_add_to_path_start() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        # Remove existing occurrence then prepend — no subshell needed.
        local -a _parts
        _parts=("${(@s/:/)PATH}")
        _parts=("${(@)_parts:#${dir}}")
        PATH="${(j/:/)_parts}"
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

#!/usr/bin/env zsh

_koopa_add_to_path_end() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        local -a _parts
        _parts=("${(@s/:/)PATH}")
        _parts=("${(@)_parts:#${dir}}")
        PATH="${(j/:/)_parts}"
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

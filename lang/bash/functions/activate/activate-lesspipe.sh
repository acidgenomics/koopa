#!/usr/bin/env bash

_koopa_activate_lesspipe() {
    local lesspipe
    lesspipe="$(_koopa_bin_prefix)/lesspipe.sh"
    if [[ ! -x "$lesspipe" ]]
    then
        return 0
    fi
    export LESS='-R'
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    export LESSCHARSET='utf-8'
    export LESSCOLOR='yes'
    export LESSOPEN="|${lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    return 0
}

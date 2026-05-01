#!/usr/bin/env bash

_koopa_activate_path_helper() {
    local path_helper
    path_helper='/usr/libexec/path_helper'
    if [[ ! -x "$path_helper" ]]
    then
        return 0
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$path_helper" -s)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

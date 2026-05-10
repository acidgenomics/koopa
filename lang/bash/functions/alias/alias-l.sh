#!/usr/bin/env bash

_koopa_alias_l() {
    if [[ -x "$(_koopa_bin_prefix)/eza" ]]
    then
        "$(_koopa_bin_prefix)/eza" \
            --classify \
            --group \
            --group-directories-first \
            --numeric \
            --sort='Name' \
            "$@"
    elif [[ -x "$(_koopa_bin_prefix)/gls" ]]
    then
        "$(_koopa_bin_prefix)/gls" -BFhn "$@"
    else
        ls -BFhn "$@"
    fi
}

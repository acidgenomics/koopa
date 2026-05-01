#!/usr/bin/env bash

_koopa_activate_coreutils_aliases() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    if [[ -x "${bin_prefix}/gcp" ]]
    then
        alias gcp='gcp --interactive --recursive --verbose'
    fi
    if [[ -x "${bin_prefix}/gln" ]]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
    fi
    if [[ -x "${bin_prefix}/gmkdir" ]]
    then
        alias gmkdir='gmkdir --parents --verbose'
    fi
    if [[ -x "${bin_prefix}/gmv" ]]
    then
        alias gmv='gmv --interactive --verbose'
    fi
    if [[ -x "${bin_prefix}/grm" ]]
    then
        alias grm='grm --interactive=once --verbose'
    fi
    return 0
}

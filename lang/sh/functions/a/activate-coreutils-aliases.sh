#!/bin/sh

_koopa_activate_coreutils_aliases() {
    # """
    # Activate GNU coreutils aliases.
    # @note Updated 2023-04-07.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS can run into issues on NFS shares.
    # """
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    if [ -x "${__kvar_bin_prefix}/gcp" ]
    then
        alias gcp='gcp --interactive --recursive --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gln" ]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gmkdir" ]
    then
        alias gmkdir='gmkdir --parents --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gmv" ]
    then
        alias gmv='gmv --interactive --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/grm" ]
    then
        alias grm='grm --interactive=once --verbose'
    fi
    unset -v __kvar_bin_prefix
    return 0
}

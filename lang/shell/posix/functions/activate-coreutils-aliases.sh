#!/bin/sh

koopa_activate_coreutils_aliases() {
    # """
    # Activate GNU coreutils aliases.
    # @note Updated 2022-08-26.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS can run into issues on NFS shares.
    # """
    [ -x "$(koopa_bin_prefix)/gcp" ] || return 0
    alias gcp='gcp --interactive --recursive --verbose'
    alias gln='gln --interactive --no-dereference --symbolic --verbose'
    alias gmkdir='gmkdir --parents --verbose'
    alias gmv='gmv --interactive --verbose'
    alias grm='grm --interactive-once --verbose'
    # Ensure we mask system coreutils.
    alias cp='gcp'
    alias ln='gln'
    alias mkdir='gmkdir'
    alias mv='gmv'
    alias rm='grm'
    return 0
}

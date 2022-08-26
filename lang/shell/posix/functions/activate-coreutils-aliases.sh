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
    local gcp gcp_args gln gln_args gmkdir gmkdir_args gmv gmv_args grm grm_args
    gcp='gcp'
    gln='gln'
    gmkdir='gmkdir'
    gmv='gmv'
    grm='grm'
    gcp_args='-Riv' # '--interactive --recursive --verbose'.
    gln_args='-insv' # '--interactive --no-dereference --symbolic --verbose'.
    gmkdir_args='-pv' # '--parents --verbose'.
    gmv_args='-iv' # '--interactive --verbose'
    # Problematic on some file systems: '--dir', '--preserve-root'.
    # Don't enable '--recursive' here by default, to provide against
    # accidental deletion of an important directory.
    grm_args='-iv' # '--interactive=once --verbose'.
    # shellcheck disable=SC2139
    alias gcp="${gcp} ${gcp_args}"
    # shellcheck disable=SC2139
    alias gln="${gln} ${gln_args}"
    # shellcheck disable=SC2139
    alias gmkdir="${gmkdir} ${gmkdir_args}"
    # shellcheck disable=SC2139
    alias gmv="${gmv} ${gmv_args}"
    # shellcheck disable=SC2139
    alias grm="${grm} ${grm_args}"
    return 0
}

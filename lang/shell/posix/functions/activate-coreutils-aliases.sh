#!/bin/sh

koopa_activate_coreutils_aliases() {
    # """
    # Activate BSD/GNU coreutils aliases.
    # @note Updated 2022-08-12.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS currently has issues on NFS shares.
    # """
    [ -x "$(koopa_bin_prefix)/cp" ] || return 0
    local cp cp_args ln ln_args mkdir mkdir_args mv mv_args rm rm_args
    cp='cp'
    ln='ln'
    mkdir='mkdir'
    mv='mv'
    rm='rm'
    cp_args='-Riv' # '--interactive --recursive --verbose'.
    ln_args='-insv' # '--interactive --no-dereference --symbolic --verbose'.
    mkdir_args='-pv' # '--parents --verbose'.
    mv_args='-iv' # '--interactive --verbose'
    # Problematic on some file systems: '--dir', '--preserve-root'.
    # Don't enable '--recursive' here by default, to provide against
    # accidental deletion of an important directory.
    rm_args='-iv' # '--interactive=once --verbose'.
    # shellcheck disable=SC2139
    alias cp="${cp} ${cp_args}"
    # shellcheck disable=SC2139
    alias ln="${ln} ${ln_args}"
    # shellcheck disable=SC2139
    alias mkdir="${mkdir} ${mkdir_args}"
    # shellcheck disable=SC2139
    alias mv="${mv} ${mv_args}"
    # shellcheck disable=SC2139
    alias rm="${rm} ${rm_args}"
    return 0
}

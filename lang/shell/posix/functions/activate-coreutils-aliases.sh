#!/bin/sh

koopa_activate_coreutils_aliases() {
    # """
    # Activate GNU coreutils aliases.
    # @note Updated 2022-09-07.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS can run into issues on NFS shares.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    if [ -x "${bin_prefix}/gcat" ]
    then
        alias cat='gcat'
    fi
    if [ -x "${bin_prefix}/gcp" ]
    then
        alias gcp='gcp --interactive --recursive --verbose'
        alias cp='gcp'
    fi
    if [ -x "${bin_prefix}/gcut" ]
    then
        alias cut='gcut'
    fi
    if [ -x "${bin_prefix}/gdf" ]
    then
        alias df='gdf'
    fi
    if [ -x "${bin_prefix}/gdir" ]
    then
        alias dir='gdir'
    fi
    if [ -x "${bin_prefix}/gecho" ]
    then
        alias echo='gecho'
    fi
    if [ -x "${bin_prefix}/gegrep" ]
    then
        alias egrep='gegrep'
    fi
    if [ -x "${bin_prefix}/gfgrep" ]
    then
        alias fgrep='gfgrep'
    fi
    if [ -x "${bin_prefix}/gfind" ]
    then
        alias find='gfind'
    fi
    if [ -x "${bin_prefix}/ggrep" ]
    then
        alias grep='ggrep'
    fi
    if [ -x "${bin_prefix}/ghead" ]
    then
        alias head='ghead'
    fi
    if [ -x "${bin_prefix}/gln" ]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
        alias ln='gln'
    fi
    if [ -x "${bin_prefix}/gls" ]
    then
        alias ls='gls'
    fi
    if [ -x "${bin_prefix}/gmkdir" ]
    then
        alias gmkdir='gmkdir --parents --verbose'
        alias mkdir='gmkdir'
    fi
    if [ -x "${bin_prefix}/gmv" ]
    then
        alias gmv='gmv --interactive --verbose'
        alias mv='gmv'
    fi
    if [ -x "${bin_prefix}/greadlink" ]
    then
        alias readlink='greadlink'
    fi
    if [ -x "${bin_prefix}/grealpath" ]
    then
        alias realpath='grealpath'
    fi
    if [ -x "${bin_prefix}/grm" ]
    then
        alias grm='grm --interactive=once --verbose'
        alias rm='grm'
    fi
    if [ -x "${bin_prefix}/gsed" ]
    then
        alias sed='gsed'
    fi
    if [ -x "${bin_prefix}/gstat" ]
    then
        alias stat='gstat'
    fi
    if [ -x "${bin_prefix}/gtail" ]
    then
        alias tail='gtail'
    fi
    if [ -x "${bin_prefix}/gtar" ]
    then
        alias tar='gtar'
    fi
    if [ -x "${bin_prefix}/gtouch" ]
    then
        alias touch='gtouch'
    fi
    if [ -x "${bin_prefix}/gtr" ]
    then
        alias tr='gtr'
    fi
    if [ -x "${bin_prefix}/gwhich" ]
    then
        alias which='gwhich'
    fi
    if [ -x "${bin_prefix}/gxargs" ]
    then
        alias xargs='gxargs'
    fi
    return 0
}

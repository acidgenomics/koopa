#!/bin/sh

_koopa_activate_coreutils_aliases() {
    # """
    # Activate GNU coreutils aliases.
    # @note Updated 2023-03-09.
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
    if [ -x "${__kvar_bin_prefix}/gcat" ]
    then
        alias cat='gcat'
    fi
    if [ -x "${__kvar_bin_prefix}/gcp" ]
    then
        alias gcp='gcp --interactive --recursive --verbose'
        alias cp='gcp'
    fi
    if [ -x "${__kvar_bin_prefix}/gcut" ]
    then
        alias cut='gcut'
    fi
    if [ -x "${__kvar_bin_prefix}/gdf" ]
    then
        alias df='gdf'
    fi
    if [ -x "${__kvar_bin_prefix}/gdir" ]
    then
        alias dir='gdir'
    fi
    if [ -x "${__kvar_bin_prefix}/gecho" ]
    then
        alias echo='gecho'
    fi
    if [ -x "${__kvar_bin_prefix}/gegrep" ]
    then
        alias egrep='gegrep'
    fi
    if [ -x "${__kvar_bin_prefix}/gfgrep" ]
    then
        alias fgrep='gfgrep'
    fi
    if [ -x "${__kvar_bin_prefix}/gfind" ]
    then
        alias find='gfind'
    fi
    if [ -x "${__kvar_bin_prefix}/ggrep" ]
    then
        alias grep='ggrep'
    fi
    if [ -x "${__kvar_bin_prefix}/ghead" ]
    then
        alias head='ghead'
    fi
    if [ -x "${__kvar_bin_prefix}/gln" ]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
        alias ln='gln'
    fi
    if [ -x "${__kvar_bin_prefix}/gls" ]
    then
        alias ls='gls'
    fi
    if [ -x "${__kvar_bin_prefix}/gmd5sum" ]
    then
        alias md5sum='gmd5sum'
    fi
    if [ -x "${__kvar_bin_prefix}/gmkdir" ]
    then
        alias gmkdir='gmkdir --parents --verbose'
        alias mkdir='gmkdir'
    fi
    if [ -x "${__kvar_bin_prefix}/gmv" ]
    then
        alias gmv='gmv --interactive --verbose'
        alias mv='gmv'
    fi
    if [ -x "${__kvar_bin_prefix}/greadlink" ]
    then
        alias readlink='greadlink'
    fi
    if [ -x "${__kvar_bin_prefix}/grealpath" ]
    then
        alias realpath='grealpath'
    fi
    if [ -x "${__kvar_bin_prefix}/grm" ]
    then
        alias grm='grm --interactive=once --verbose'
        alias rm='grm'
    fi
    if [ -x "${__kvar_bin_prefix}/gsed" ]
    then
        alias sed='gsed'
    fi
    if [ -x "${__kvar_bin_prefix}/gsha256sum" ]
    then
        alias sha256sum='gsha256sum'
    fi
    if [ -x "${__kvar_bin_prefix}/gstat" ]
    then
        alias stat='gstat'
    fi
    if [ -x "${__kvar_bin_prefix}/gtail" ]
    then
        alias tail='gtail'
    fi
    if [ -x "${__kvar_bin_prefix}/gtar" ]
    then
        alias tar='gtar'
    fi
    if [ -x "${__kvar_bin_prefix}/gtouch" ]
    then
        alias touch='gtouch'
    fi
    if [ -x "${__kvar_bin_prefix}/gtr" ]
    then
        alias tr='gtr'
    fi
    if [ -x "${__kvar_bin_prefix}/gwhich" ]
    then
        alias which='gwhich'
    fi
    if [ -x "${__kvar_bin_prefix}/gxargs" ]
    then
        alias xargs='gxargs'
    fi
    unset -v __kvar_bin_prefix
    return 0
}

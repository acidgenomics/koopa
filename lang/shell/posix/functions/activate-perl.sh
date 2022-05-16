#!/bin/sh

koopa_activate_perl() {
    # """
    # Activate Perl, adding local library to 'PATH'.
    # @note Updated 2022-05-12.
    #
    # No longer querying Perl directly here, to speed up shell activation
    # (see commented legacy approach below).
    #
    # The legacy Perl eval approach may error/warn if new shell is activated
    # while Perl packages are installing.
    #
    # @seealso
    # - brew info perl
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/perl" ] || return 0
    prefix="$(koopa_perl_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export PERL5LIB="${prefix}/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$prefix"
    export PERL_MB_OPT="--install_base '${prefix}'"
    export PERL_MM_OPT="INSTALL_BASE=${prefix}"
    export PERL_MM_USE_DEFAULT=1
    return 0
}

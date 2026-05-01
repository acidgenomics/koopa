#!/usr/bin/env bash

main() {
    # """
    # Install Dash shell.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/dash.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'autoconf' 'automake'
    _koopa_activate_app 'libedit'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
        '--with-libedit'
    )
    if _koopa_is_arm64
    then
        export ac_cv_func_stat64='no'
    fi
    # NOTE Need to switch to HTTPS here.
# >     dict['url']="http://gondor.apana.org.au/~herbert/dash/files/\
# > dash-${dict['version']}.tar.gz"
    dict['url']="https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/\
dash-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    ./autogen.sh
    _koopa_make_build "${conf_args[@]}"
    return 0
}

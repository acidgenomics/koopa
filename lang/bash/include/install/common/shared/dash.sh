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
    koopa_activate_app --build-only 'autoconf' 'automake'
    koopa_activate_app 'libedit'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
        '--with-libedit'
    )
    if koopa_is_arm64
    then
        export ac_cv_func_stat64='no'
    fi
    # NOTE Need to switch to HTTPS here.
# >     dict['url']="http://gondor.apana.org.au/~herbert/dash/files/\
# > dash-${dict['version']}.tar.gz"
    dict['url']="https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/\
dash-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}

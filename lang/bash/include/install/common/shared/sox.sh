#!/usr/bin/env bash

# FIXME Currently failing to build with Xcode CLT 15.3:
# https://github.com/Homebrew/homebrew-core/blob/2fc9fa519f9dbcf9c973d5f60db164f491207f8d/Formula/s/sox.rb

# Likely need to apply this patch:
# https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff

main() {
    # """
    # Install SoX.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/sox.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'flac'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.sourceforge.net/project/sox/sox/\
${dict['version']}/sox-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

#!/usr/bin/env bash

# NOTE May need to address this:
# Package xorg-macros was not found in the pkg-config search path.
# Perhaps you should add the directory containing `xorg-macros.pc'
# to the PKG_CONFIG_PATH environment variable
# No package 'xorg-macros' found
# https://github.com/freedesktop/xorg-macros

main() {
    # """
    # Install xorg-libxau.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxau.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'xorg-xorgproto'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.x.org/archive/individual/lib/\
libXau-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

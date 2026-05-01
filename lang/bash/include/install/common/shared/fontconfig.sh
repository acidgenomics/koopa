#!/usr/bin/env bash

# NOTE Consider adding expat as a requirement here.

main() {
    # """
    # Install fontconfig.
    # @note Updated 2024-06-12.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/fontconfig/
    # - https://github.com/freedesktop/fontconfig/blob/master/INSTALL
    # - https://github.com/freedesktop/fontconfig
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/fontconfig.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/fontconfig/
    #     trunk/PKGBUILD
    # """
    local -A dict
    local -a conf_args deps
    deps+=(
        'gperf'
        'freetype'
        'icu4c' # libxml2
        'libxml2'
    )
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-libxml2'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.freedesktop.org/software/fontconfig/release/\
fontconfig-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}

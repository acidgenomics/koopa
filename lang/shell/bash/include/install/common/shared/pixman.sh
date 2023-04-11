#!/usr/bin/env bash

main() {
    # """
    # Install pixman.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/macports/macports-ports/blob/master/graphics/
    #     libpixman/Portfile
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pixman.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-gtk'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    if koopa_is_macos
    then
        # Disable NEON intrinsic support.
        # - https://gitlab.freedesktop.org/pixman/pixman/-/issues/59
        # - https://gitlab.freedesktop.org/pixman/pixman/-/issues/69
        conf_args+=('--disable-arm-a64-neon')
    fi
    dict['url']="https://cairographics.org/releases/\
pixman-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

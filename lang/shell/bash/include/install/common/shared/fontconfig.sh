#!/usr/bin/env bash

# NOTE Consider adding expat as a requirement here.

main() {
    # """
    # Install fontconfig.
    # @note Updated 2023-04-10.
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
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'gperf' \
        'freetype' \
        'libxml2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-libxml2'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.freedesktop.org/software/fontconfig/release/\
fontconfig-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

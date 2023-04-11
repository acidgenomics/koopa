#!/usr/bin/env bash

main() {
    # """
    # Install xcb-proto.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/xcb-proto.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config' 'python3.11'
    app['python']="$(koopa_locate_python311 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        "PYTHON=${app['python']}"
    )
    dict['url']="https://xorg.freedesktop.org/archive/individual/proto/\
xcb-proto-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

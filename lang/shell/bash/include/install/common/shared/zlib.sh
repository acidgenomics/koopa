#!/usr/bin/env bash

main() {
    # """
    # Install zlib.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.zlib.net/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zlib.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/zlib/
    #     trunk/PKGBUILD
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['name']='zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.zlib.net/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        # > '--enable-static=no'
        "--prefix=${dict['prefix']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" install
    return 0
}

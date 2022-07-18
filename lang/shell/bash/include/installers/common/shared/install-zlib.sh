#!/usr/bin/env bash

main() {
    # """
    # Install zlib.
    # @note Updated 2022-04-28.
    #
    # @seealso
    # - https://www.zlib.net/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zlib.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/zlib/
    #     trunk/PKGBUILD
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [name]='zlib'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.zlib.net/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        # > '--enable-static=no'
        "--prefix=${dict[prefix]}"
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" install
    return 0
}

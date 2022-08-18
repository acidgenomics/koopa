#!/usr/bin/env bash

main() {
    # """
    # Install expat.
    # @note Updated 2022-08-16.
    #
    # @seealso
    # - https://libexpat.github.io/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [name]='expat'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[version2]="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='_' \
            "${dict[version]}" \
    )"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/libexpat/libexpat/releases/download/\
R_${dict[version2]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=("--prefix=${dict[prefix]}")
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}"
    "${app[make]}" install
    return 0
}

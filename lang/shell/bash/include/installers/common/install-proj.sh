#!/usr/bin/env bash

install_proj() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2021-12-07.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='proj'
        [os]='linux-gnu'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=("--prefix=${dict[prefix]}")
    if koopa_is_macos
    then
        koopa_activate_homebrew_opt_prefix 'pkg-config' 'libtiff' 'sqlite3'
    fi
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/PROJ/releases/download/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

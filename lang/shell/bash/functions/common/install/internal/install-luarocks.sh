#!/usr/bin/env bash

koopa:::install_luarocks() { # {{{1
    # """
    # Install Luarocks.
    # @note Updated 2021-12-09.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [lua]="$(koopa::locate_lua)"
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [name]='luarocks'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[lua_version]="$(koopa::get_version "${app[lua]}")"
    dict[lua_maj_min_ver]="$(koopa::major_minor_version "${dict[lua_version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://luarocks.org/releases/${dict[file]}"
    koopa::activate_opt_prefix 'lua'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure \
        --prefix="${dict[prefix]}" \
        --lua-version="${dict[lua_min_maj_ver]}" \
        --versioned-rocks-dir
    "${app[make]}" build
    "${app[make]}" install
    return 0
}

#!/usr/bin/env bash

install_luarocks() { # {{{1
    # """
    # Install Luarocks.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [lua]="$(koopa_locate_lua)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='luarocks'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[lua_version]="$(koopa_get_version "${app[lua]}")"
    dict[lua_maj_min_ver]="$(koopa_major_minor_version "${dict[lua_version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://luarocks.org/releases/${dict[file]}"
    koopa_activate_opt_prefix 'lua'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure \
        --prefix="${dict[prefix]}" \
        --lua-version="${dict[lua_maj_min_ver]}" \
        --versioned-rocks-dir
    "${app[make]}" build
    "${app[make]}" install
    app[luarocks]="${dict[prefix]}/bin/luarocks"
    koopa_assert_is_installed "${app[luarocks]}"
    "${app[luarocks]}" install 'luaposix'
    "${app[luarocks]}" install 'luafilesystem'
    return 0
}

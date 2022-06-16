#!/usr/bin/env bash

main() {
    # """
    # Install Luarocks.
    # @note Updated 2022-06-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'lua'
    declare -A app=(
        [lua]="$(koopa_locate_lua)"
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[lua]}" ]] || return 1
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [name]='luarocks'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[lua_version]="$(koopa_get_version "${app[lua]}")"
    dict[lua_maj_min_ver]="$(koopa_major_minor_version "${dict[lua_version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://luarocks.org/releases/${dict[file]}"
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
    (
        koopa_cd "${dict[prefix]}"
        "${app[luarocks]}" install 'luaposix'
        "${app[luarocks]}" install 'luafilesystem'
    )
    return 0
}

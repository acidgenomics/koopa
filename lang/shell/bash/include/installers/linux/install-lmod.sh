#!/usr/bin/env bash

linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2022-01-30.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local app dict
    declare -A app=(
        [lua]="$(koopa_locate_lua)"
        [luarocks]="$(koopa_locate_luarocks)"
        [make]="$(koopa_locate_make)"
    )
    app[lua]="$(koopa_realpath "${app[lua]}")"
    app[luarocks]="$(koopa_realpath "${app[luarocks]}")"
    declare -A dict=(
        [make_prefix]="$(koopa_make_prefix)"
        [name2]='Lmod'
        [name]='lmod'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[apps_dir]="${dict[prefix]}/apps"
    dict[data_dir]="${dict[prefix]}/moduleData"
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/TACC/${dict[name2]}/archive/${dict[file]}"
    koopa_activate_prefix "${dict[make_prefix]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name2]}-${dict[version]}"
    koopa_dl \
        'LUA_PATH' "$("${app[lua]}" -e 'print(package.path)')" \
        'LUA_CPATH' "$("${app[lua]}" -e 'print(package.cpath)')"
    ./configure \
        --prefix="${dict[apps_dir]}" \
        --with-spiderCacheDir="${dict[data_dir]}/cacheDir" \
        --with-updateSystemFn="${dict[data_dir]}/system.txt"
    "${app[make]}"
    "${app[make]}" install
    if koopa_is_admin
    then
        koopa_linux_configure_lmod "${dict[prefix]}"
    fi
    return 0
}

#!/usr/bin/env bash

koopa:::linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2022-01-28.
    # """
    local app dict
    koopa::activate_opt_prefix 'lua' 'luarocks'
    declare -A app=(
        [lua]="$(koopa::locate_lua)"
        [luarocks]="$(koopa::locate_luarocks)"
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [name2]='Lmod'
        [name]='lmod'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[apps_dir]="${dict[prefix]}/apps"
    dict[data_dir]="${dict[prefix]}/moduleData"
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/TACC/${dict[name2]}/archive/${dict[file]}"
    "${app[luarocks]}" install 'luaposix'
    "${app[luarocks]}" install 'luafilesystem'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name2]}-${dict[version]}"
    ./configure \
        --prefix="${dict[apps_dir]}" \
        --with-spiderCacheDir="${dict[data_dir]}/cacheDir" \
        --with-updateSystemFn="${dict[data_dir]}/system.txt"
    "${app[make]}"
    "${app[make]}" install
    if koopa::is_admin
    then
        koopa::linux_configure_lmod "${dict[prefix]}"
    fi
    return 0
}

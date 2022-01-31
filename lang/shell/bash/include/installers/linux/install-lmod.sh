#!/usr/bin/env bash

# FIXME Can we get this to work without activating the lua and luarocks
# prefixes? What if we resolve to full path? How do we get the lua config
# to include the full path?
# FIXME Install these modules when we install luarocks...

koopa:::linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2022-01-30.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local app dict
    declare -A app=(
        [lua]="$(koopa::locate_lua)"
        [luarocks]="$(koopa::locate_luarocks)"
        [make]="$(koopa::locate_make)"
    )
    app[lua]="$(koopa::realpath "${app[lua]}")"
    app[luarocks]="$(koopa::realpath "${app[luarocks]}")"
    declare -A dict=(
        [make_prefix]="$(koopa::make_prefix)"
        [name2]='Lmod'
        [name]='lmod'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[apps_dir]="${dict[prefix]}/apps"
    dict[data_dir]="${dict[prefix]}/moduleData"
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/TACC/${dict[name2]}/archive/${dict[file]}"
    # > koopa::activate_opt_prefix 'lua' 'luarocks'
    koopa::activate_prefix "${dict[make_prefix]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name2]}-${dict[version]}"
    export LUAROCKS_PREFIX="${dict[make_prefix]}"
    koopa::dl \
        'LUAROCKS_PREFIX' "${LUAROCKS_PREFIX:?}" \
        'LUA_PATH' "$("${app[lua]}" -e 'print(package.path)')" \
        'LUA_CPATH' "$("${app[lua]}" -e 'print(package.cpath)')"
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

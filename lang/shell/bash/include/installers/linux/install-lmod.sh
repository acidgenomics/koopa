#!/usr/bin/env bash

# FIXME Rework using app and dict approach.
# FIXME Need to locate these programs directly.

koopa:::linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2022-01-28.
    # """
    local app dict
    declare -A app=(
        [lua]="$(koopa::locate_lua)"  # FIXME Does this exist?
        [luarocks]="$(koopa::locate_luarocks)"  # FIXME Does this exist?
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

    file="${version}.tar.gz"
    url="https://github.com/TACC/${name2}/archive/${file}"

    koopa::activate_opt_prefix 'lua' 'luarocks'
    "${app[luarocks]}" install 'luaposix'
    "${app[luarocks]}" install 'luafilesystem'
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    ./configure \
        --prefix="$apps_dir" \
        --with-spiderCacheDir="${data_dir}/cacheDir" \
        --with-updateSystemFn="${data_dir}/system.txt"
    "${app[make]}"
    "${app[make]}" install
    if koopa::is_admin
    then
        koopa::linux_configure_lmod "${dict[prefix]}"
    fi
    return 0
}

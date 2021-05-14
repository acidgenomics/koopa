#!/usr/bin/env bash

koopa::linux_configure_lmod() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2021-05-07.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    local etc_dir init_dir name_fancy
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    prefix="${1:-}"
    [[ -z "$prefix" ]] && prefix="$(koopa::lmod_prefix)"
    init_dir="${prefix}/apps/lmod/lmod/init"
    name_fancy='Lmod'
    if [[ ! -d "$init_dir" ]]
    then
        koopa::alert_not_installed "$name_fancy" "$init_dir"
        return 0
    fi
    etc_dir='/etc/profile.d'
    koopa::alert "Updating ${name_fancy} configuration in '${etc_dir}'."
    koopa::mkdir -S "$etc_dir"
    # bash, zsh
    koopa::ln -S "${init_dir}/profile" "${etc_dir}/z00_lmod.sh"
    # csh, tcsh
    koopa::ln -S "${init_dir}/cshrc" "${etc_dir}/z00_lmod.csh"
    # fish
    if koopa::is_installed fish
    then
        etc_dir='/etc/fish/conf.d'
        koopa::alert "Updating Fish configuration in '${etc_dir}'."
        koopa::mkdir -S "$etc_dir"
        koopa::ln -S "${init_dir}/profile.fish" "${etc_dir}/z00_lmod.fish"
    fi
    koopa::alert_success "${name_fancy} configuration was updated successfully."
    return 0
}

koopa::install_lmod() { # {{{1
    koopa::install_app \
        --name='lmod' \
        --name-fancy='Lmod' \
        --no-link \
        --platform='linux' \
        "$@"
}

koopa:::linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2021-05-07.
    # """
    set -x
    local apps_dir data_dir file name name2 prefix url version
    koopa::activate_opt_prefix lua luarocks
    koopa::assert_is_installed lua luarocks
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='lmod'
    name2="$(koopa::capitalize "$name")"
    apps_dir="${prefix}/apps"
    data_dir="${prefix}/moduleData"
    eval "$(luarocks path)"
    luarocks install luaposix
    luarocks install luafilesystem
    file="${version}.tar.gz"
    url="https://github.com/TACC/${name2}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    ./configure \
        --prefix="$apps_dir" \
        --with-spiderCacheDir="${data_dir}/cacheDir" \
        --with-updateSystemFn="${data_dir}/system.txt"
    make
    make install
    if koopa::is_admin
    then
        koopa::linux_configure_lmod "$prefix"
    fi
    return 0
}

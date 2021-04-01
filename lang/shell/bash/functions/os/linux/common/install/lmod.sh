#!/usr/bin/env bash

koopa::install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2021-01-20.
    # """
    local apps_dir data_dir file name name_fancy prefix tmp_dir url version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::assert_is_installed lua luarocks
    version=
    while (("$#"))
    do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    name='lmod'
    name_fancy='Lmod'
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::app_prefix)/${name}/${version}"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "${name_fancy} is already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$version" "$prefix"
    apps_dir="${prefix}/apps"
    data_dir="${prefix}/moduleData"
    # Install luarocks dependencies.
    eval "$(luarocks path)"
    luarocks install luaposix
    luarocks install luafilesystem
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${version}.tar.gz"
        url="https://github.com/TACC/Lmod/archive/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::cd "Lmod-${version}"
        ./configure \
            --prefix="$apps_dir" \
            --with-spiderCacheDir="${data_dir}/cacheDir" \
            --with-updateSystemFn="${data_dir}/system.txt"
        sudo make install
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::update_lmod_config
    koopa::link_into_opt "$prefix" "$name"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_lmod_config() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2021-01-20.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    local etc_dir init_dir
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    init_dir="$(koopa::lmod_prefix)/apps/lmod/lmod/init"
    [[ -d "$init_dir" ]] || return 0
    etc_dir='/etc/profile.d'
    koopa::alert "Updating Lmod configuration in ${etc_dir}."
    koopa::mkdir -S "$etc_dir"
    # bash, zsh
    koopa::ln -S "${init_dir}/profile" "${etc_dir}/z00_lmod.sh"
    # csh, tcsh
    koopa::ln -S "${init_dir}/cshrc" "${etc_dir}/z00_lmod.csh"
    # fish
    if koopa::is_installed fish
    then
        etc_dir='/etc/fish/conf.d'
        koopa::alert "Updating Fish Lmod configuration in ${etc_dir}."
        koopa::mkdir -S "$etc_dir"
        koopa::ln -S "${init_dir}/profile.fish" "${etc_dir}/z00_lmod.fish"
    fi
    return 0
}

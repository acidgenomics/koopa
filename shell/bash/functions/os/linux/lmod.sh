#!/usr/bin/env bash

koopa::install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2020-07-30.
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
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    name='lmod'
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::app_prefix)/${name}"
    [[ -d "$prefix" ]] && return 0
    name_fancy='Lmod'
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
    koopa::install_success "$name_fancy"
    return 0
}


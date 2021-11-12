#!/usr/bin/env bash

# FIXME Need to wrap this.
koopa::debian_install_node() { # {{{1
    # """
    # Install Node.js for Debian using NodeSource.
    # @note Updated 2021-09-20.
    #
    # This will configure apt at '/etc/apt/sources.list.d/nodesource.list'.
    # """
    local file name_fancy tmp_dir url version
    name_fancy='Node.js'
    koopa::install_start "$name_fancy"
    version="$(koopa::get_version 'node')"
    version="$(koopa::major_version "$version")"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url="https://deb.nodesource.com/setup_${version}.x"
        file='setup.sh'
        koopa::download "$url" "$file"
        koopa::chmod 'u+x' "$file"
        sudo "./${file}"
    )
    koopa::rm "$tmp_dir"
    koopa::debian_apt_install 'nodejs'
    koopa::install_success "$name_fancy"
    return 0
}

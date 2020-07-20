#!/usr/bin/env bash

koopa::debian_install_pandoc() {
    # """
    # Install Pandoc.
    # @note Updated 2020-07-20.
    # """
    local name name_fancy tmp_dir version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed dpkg sudo
    name='pandoc'
    name_fancy='Pandoc'
    koopa::install_start "$name_fancy"
    version="$(koopa::variable "$name")"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}-1-amd64.deb"
        url="https://github.com/jgm/${name}/releases/download/${version}/${file}"
        koopa::download "$url"
        sudo dpkg -i "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}


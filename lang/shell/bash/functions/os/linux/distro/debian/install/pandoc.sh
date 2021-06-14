#!/usr/bin/env bash

koopa::debian_install_pandoc() { # {{{1
    # """
    # Install Pandoc.
    # @note Updated 2021-03-30.
    # """
    local arch name name_fancy tmp_dir version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'dpkg' 'sudo'
    name='pandoc'
    name_fancy='Pandoc'
    koopa::install_start "$name_fancy"
    version="$(koopa::variable "$name")"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        arch="$(koopa::arch2)"
        file="${name}-${version}-1-${arch}.deb"
        url="https://github.com/jgm/${name}/releases/download/\
${version}/${file}"
        koopa::download "$url"
        sudo dpkg -i "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_uninstall_pandoc() { # {{{1
    # """
    # Uninstall Pandoc.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'pandoc' 'pandoc-data'
    return 0
}

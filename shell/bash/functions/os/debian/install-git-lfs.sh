#!/usr/bin/env bash

koopa::debian_install_git_lfs() { # {{{1
    # """
    # Install Git LFS.
    # @note Updated 2020-07-20.
    # """
    local file name name_fancy server tmp_dir url
    koopa::assert_has_no_args "$#"
    name='git-lfs'
    name_fancy='Git LFS'
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='script.deb.sh'
        server='packagecloud.io'
        url="https://${server}/install/repositories/github/${name}/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::apt_install git "$name"
    git lfs install
    koopa::install_success "$name_fancy"
    return 0
}

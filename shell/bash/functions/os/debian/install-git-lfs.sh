#!/usr/bin/env bash

koopa::debian_install_git_lfs() {
    local file name_fancy tmp_dir url
    koopa::assert_has_no_args "$#"
    name_fancy='Git LFS'
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='script.deb.sh'
        url="https://packagecloud.io/install/repositories/github/git-lfs/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::apt_install git git-lfs
    git lfs install
    koopa::install_success "$name_fancy"
    return 0
}


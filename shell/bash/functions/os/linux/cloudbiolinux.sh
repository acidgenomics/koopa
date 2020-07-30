#!/usr/bin/env bash

koopa::install_cloudbiolinux() { # {{{1
    local dir name_fancy
    koopa::assert_has_args_le "$#" 1
    dir="${1:-cloudbiolinux}"
    koopa::exit_if_dir "$dir"
    name_fancy='CloudBioLinux'
    koopa::install_start "$name_fancy"
    # Using our forked repo, to control for unexpected upstream changes.
    git clone 'https://github.com/acidgenomics/cloudbiolinux.git' "$dir"
    koopa::install_success "$name_fancy"
    return 0
}

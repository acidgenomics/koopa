#!/usr/bin/env bash

# FIXME This needs to call 'install_linux_app'.

koopa::linux_install_cloudbiolinux() { # {{{1
    # """
    # Install CloudBioLinux.
    # @note Updated 2020-11-16.
    # """
    local name_fancy prefix
    koopa::assert_has_args_le "$#" 1
    prefix="${1:-cloudbiolinux}"
    [[ -d "$prefix" ]] && return 0
    name_fancy='CloudBioLinux'
    koopa::install_start "$name_fancy"
    # Using our forked repo, to control for unexpected upstream changes.
    git clone 'https://github.com/acidgenomics/cloudbiolinux.git' "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

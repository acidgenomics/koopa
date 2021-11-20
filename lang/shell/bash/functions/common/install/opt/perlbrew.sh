#!/usr/bin/env bash

koopa:::install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2021-05-25.
    #
    # Available releases:
    # > perlbrew available
    # """
    local file prefix url
    prefix="${INSTALL_PREFIX:?}"
    koopa::mkdir "$prefix"
    koopa::rm "${HOME:?}/.perlbrew"
    file='install.sh'
    url='https://install.perlbrew.pl'
    koopa::download "$url" "$file"
    koopa::chmod 'u+x' "$file"
    export PERLBREW_ROOT="$prefix"
    "./${file}"
}

# FIXME Need to locate perlbrew.
koopa:::update_perlbrew() { # {{{1
    # """
    # Update Perlbrew.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa::activate_perlbrew
    koopa::assert_is_installed 'perlbrew'
    perlbrew self-upgrade
    return 0
}

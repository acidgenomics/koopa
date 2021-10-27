#!/usr/bin/env bash

koopa::install_rbenv() { # {{{1
    koopa:::install_app \
        --name='rbenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa:::install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-09-18.
    # """
    local name prefix
    prefix="${INSTALL_PREFIX:?}"
    name='rbenv'
    koopa::git_clone \
        "https://github.com/sstephenson/${name}.git" \
        "$prefix"
    koopa::mkdir "${prefix}/plugins"
    koopa::git_clone \
        'https://github.com/sstephenson/ruby-build.git' \
        "${prefix}/plugins/ruby-build"
    return 0
}

koopa::uninstall_rbenv() { # {{{1
    koopa:::uninstall_app \
        --name='rbenv' \
        --no-link \
        "$@"
}

koopa::update_rbenv() { # {{{1
    koopa:::update_app \
        --name='rbenv' \
        "$@"
}

koopa:::update_rbenv() { # {{{1
    # """
    # Update rbenv.
    # @note Updated 2021-09-18.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="${UPDATE_PREFIX:?}"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    return 0
}

#!/usr/bin/env bash

koopa::install_rbenv() { # {{{1
    koopa::install_app \
        --name='rbenv' \
        "$@"
}

koopa:::install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-04-27.
    # """
    local prefix
    prefix="${INSTALL_PREFIX:?}"
    koopa::mkdir "$prefix"
    git clone \
        'https://github.com/sstephenson/rbenv.git' \
        "$prefix"
    koopa::mkdir "${prefix}/plugins"
    git clone \
        'https://github.com/sstephenson/ruby-build.git' \
        "${prefix}/plugins/ruby-build"
    return 0
}

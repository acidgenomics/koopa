#!/usr/bin/env bash

koopa::install_pyenv() { # {{{1
    koopa::install_app \
        --name='pyenv' \
        "$@"
}

koopa:::install_pyenv() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2021-04-27.
    # """
    local prefix url
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/pyenv/pyenv.git'
    koopa::mkdir "$prefix"
    git clone "$url" "$prefix"
    return 0
}

koopa::update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2021-05-07.
    # """
    local name_fancy
    if ! koopa::is_installed pyenv
    then
        koopa::alert_not_installed 'pyenv'
        return 0
    fi
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    name_fancy='pyenv'
    koopa::update_start "$name_fancy"
    (
        koopa::cd "$(pyenv root)"
        git pull
    )
    koopa::update_success "$name_fancy"
    return 0
}

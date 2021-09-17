#!/usr/bin/env bash

koopa::install_pyenv() { # {{{1
    koopa:::install_app \
        --name='pyenv' \
        --no-link \
        "$@"
}

koopa:::install_pyenv() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2021-06-02.
    # """
    local prefix url
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/pyenv/pyenv.git'
    koopa::mkdir "$prefix"
    koopa::git_clone "$url" "$prefix"
    return 0
}

koopa::uninstall_pyenv() { # {{{1
    koopa:::uninstall_app \
        --name='pyenv' \
        --no-link \
        "$@"
}

# FIXME This doesn't handle permissions correctly.
# FIXME Need to rethink using an internal function.
koopa::update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2021-05-07.
    # """
    local name_fancy
    name_fancy='pyenv'
    if ! koopa::is_installed 'pyenv'
    then
        koopa::alert_is_not_installed "$name_fancy"
        return 0
    fi
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::update_start "$name_fancy"
    (
        koopa::cd "$(pyenv root)"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy"
    return 0
}

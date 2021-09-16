#!/usr/bin/env bash

koopa::install_rbenv() { # {{{1
    koopa:::install_app \
        --name='rbenv' \
        --no-link \
        "$@"
}

koopa:::install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-05-05.
    # """
    local name prefix
    prefix="${INSTALL_PREFIX:?}"
    name='rbenv'
    koopa::mkdir "$prefix"
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
    # """
    # Update rbenv.
    # @note Updated 2021-06-03.
    # """
    local exe name name_fancy prefix
    koopa::assert_has_no_args "$#"
    name='rbenv'
    name_fancy="$name"
    prefix="$(koopa::rbenv_prefix)"
    exe="${prefix}/bin/${name}"
    if ! koopa::is_installed "$exe"
    then
        koopa::alert_is_not_installed "$name"
        return 0
    fi
    koopa::update_start "$name_fancy"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy"
    return 0
}

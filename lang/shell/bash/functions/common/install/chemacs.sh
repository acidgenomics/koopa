#!/usr/bin/env bash

koopa::install_chemacs() { # {{{1
    koopa:::install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa:::install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2021-06-07.
    # """
    local prefix repo
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/plexus/chemacs2'
    koopa::git_clone "$repo" "$prefix"
    return 0
}

koopa::uninstall_chemacs() { # {{{1
    # """
    # Uninstall Chemacs2.
    # @note Updated 2021-06-07.
    # """
    koopa:::uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa::update_chemacs() { # {{{1
    # """
    # Update Chemacs2.
    # @note Updated 2021-06-07.
    # """
    local name_fancy prefix
    name_fancy='Chemacs'
    prefix="$(koopa::opt_prefix)/chemacs"
    koopa::assert_is_dir "$prefix"
    koopa::update_start "$name_fancy" "$prefix"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy" "$prefix"
    return 0
}

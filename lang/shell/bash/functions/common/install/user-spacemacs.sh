#!/usr/bin/env bash

koopa::install_spacemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
}

koopa:::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-06-08.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local prefix repo
    koopa::assert_has_no_args "$#"
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/syl20bnr/spacemacs.git'
    koopa::git_clone --branch='develop' "$repo" "$prefix"
    return 0
}

koopa::uninstall_spacemacs() { # {{{1
    # """
    # Uninstall Spacemacs.
    # @note Updated 2021-06-08.
    # """
    koopa::uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --no-shared \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::update_spacemacs() { # {{{1
    # """
    # Update Spacemacs.
    # @note Updated 2021-07-29.
    #
    # Note that fully non-interactive  '--batch' argument doesn't work with
    # Chemacs2 configuration currently.
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Spacemacs'
    prefix="$(koopa::spacemacs_prefix)"
    koopa::assert_is_dir "$prefix"
    koopa::update_start "$name_fancy" "$prefix"
    (
        koopa::cd "$prefix"
        git checkout -B 'develop' 'origin/develop'
        koopa::git_pull
    )
    # Attempt to update spacemacs packages inside of chemacs2 configuration.
    # NOTE Can't use '--batch' here with chemacs.
    # > local emacs
    # > emacs="$(koopa::locate_emacs)"
    # > if [[ -f "${HOME}/.emacs.d/chemacs.el" ]]
    # > then
    # >     "$emacs" \
    # >         --no-window-system \
    # >         --with-profile 'spacemacs' \
    # >         --eval='(configuration-layer/update-packages t)'
    # > fi
    koopa::update_success "$name_fancy" "$prefix"
    return 0
}

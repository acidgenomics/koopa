#!/usr/bin/env bash

# FIXME Need to support installation of both Doom Emacs and Spacemacs
# at the same time...
# FIXME Also need to support updating of both Doom and Spacemacs...
# FIXME '--reinstall' is not supported.
# FIXME Need to use something like 'koopa::install_local_app' here.
# FIXME Need to link Spacemacs dynamically for commands here.

koopa::install_spacemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
    return 0
}

koopa:::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-06-07.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        koopa::add_to_path_start "${brew_prefix}/bin"
    fi
    koopa::assert_is_installed 'emacs'
    prefix="${INSTALL_PREFIX:?}"
    repo="https://github.com/syl20bnr/spacemacs.git"
    koopa::git_clone "$repo" "$prefix"
    return 0
}

koopa::uninstall_spacemacs() { # {{{1
    echo "FIXME need to add support."
}

koopa::update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2021-06-07.
    #
    # Potentially useful: 'emacs --no-window-system'.
    #
    # How to update packages from command line:
    # > emacs \
    # >     --batch -l "${prefix}/init.el" \
    # >     --eval='(configuration-layer/update-packages t)'
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'emacs'
    name_fancy='Spacemacs'
    koopa::update_start "$name_fancy"
    prefix="$(koopa::spacemacs_prefix)"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy"
    return 0
}

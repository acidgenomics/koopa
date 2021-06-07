#!/usr/bin/env bash

koopa::install_prelude_emacs() { # {{{1
    koopa::install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa::prelude_emacs_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
    return 0
}


koopa:::install_prelude_emacs() { # {{{1
    # """
    # Install Prelude Emacs.
    # @note Updated 2021-06-07.
    #
    # @seealso
    # - https://prelude.emacsredux.com/en/latest/
    # """
    local prefix repo
    koopa::assert_has_no_args "$#"
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/bbatsov/prelude.git'
    koopa::git_clone "$repo" "$prefix"
    return 0
}

koopa::uninstall_prelude_emacs() { # {{{1
    echo "FIXME need to add support."
}

koopa::update_prelude_emacs() { # {{{1
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

#!/usr/bin/env bash

koopa::_update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2020-11-25.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed doom
    koopa::h1 'Updating Doom Emacs.'
    doom upgrade --force
    doom sync
    return 0
}

koopa::_update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2020-11-25.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    koopa::h1 'Updating Spacemacs.'
    prefix="$(koopa::emacs_prefix)"
    (
        koopa::cd "$prefix"
        git pull
    )
    emacs \
        --batch -l "${prefix}/init.el" \
        --eval='(configuration-layer/update-packages t)'
    return 0
}

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::note 'Emacs is not installed.'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa::_update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa::_update_doom_emacs
    else
        koopa::note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}

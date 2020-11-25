#!/usr/bin/env bash

# FIXME MAKE THIS ACCESSIBLE UNDER KOOPA LINK-EMACS?
koopa::link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-11-24.
    #
    # Currently supports Doom, Spacemacs, and minimal ESS config.
    # """
    local custom_prefix default_prefix name
    koopa::assert_has_args "$#"
    name="${1:?}"
    default_prefix="$(koopa::emacs_prefix)"
    custom_prefix="${default_prefix}-${name}"
    koopa::assert_is_dir "$custom_prefix"
    if [[ -d "$default_prefix" ]] && [[ ! -L "$default_prefix" ]]
    then
        koopa::stop "Emacs directory detected at '${default_prefix}'."
    fi
    if [[ "$name" != 'minimal' ]]
    then
        koopa::rm "${HOME}/.emacs"
    elif [[ "$name" != 'spacemacs' ]]
    then
        koopa::rm "${HOME}/.spacemacs"
    fi
    case "$name" in
        doom)
            link-dotfile \
                --force \
                'app/emacs/doom' \
                'doom.d'
            ;;
        minimal)
            link-dotfile \
                --force \
                'app/emacs/minimal/emacs.el'
            ;;
        spacemacs)
            link-dotfile \
                --force \
                'app/emacs/spacemacs/spacemacs.el' \
                'spacemacs'
            ;;
        *)
            koopa::stop 'Invalid Emacs config name.'
            ;;
    esac
    koopa::ln "$custom_prefix" "$default_prefix"
    return 0
}

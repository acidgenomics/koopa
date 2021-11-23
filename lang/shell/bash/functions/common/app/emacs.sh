#!/usr/bin/env bash

# FIXME Consider moving this function / reworking?
# FIXME Need to rework using dict approach.
koopa::link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-12-31.
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
        'doom')
            koopa::link_dotfile \
                --force \
                'app/emacs/doom' \
                'doom.d'
            ;;
        'minimal')
            koopa::link_dotfile \
                --force \
                'app/emacs/minimal/emacs.el'
            ;;
        'spacemacs')
            koopa::link_dotfile \
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

#!/usr/bin/env bash

koopa::link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-06-30.
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
        rm -fv "${HOME}/.emacs"
    elif [[ "$name" != 'spacemacs' ]]
    then
        rm -fv "${HOME}/.spacemacs"
    fi
    case "$name" in
        doom)
            link-dotfile \
                --force \
                --config \
                'app/emacs/doom/config.d' \
                'doom'
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
    ln -fnsv "$custom_prefix" "$default_prefix"
    return 0
}

koopa::is_spacemacs_installed() { # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    local init_file prefix
    prefix="$(koopa::emacs_prefix)"
    # Check for 'Spacemacs' inside 'init.el' file.
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    grep -q 'Spacemacs' "$init_file" || return 1
    return 0
}

koopa::update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2020-06-29.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if ! koopa::is_spacemacs_installed
    then
        koopa::note 'Spacemacs is not installed.'
        return 0
    fi
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

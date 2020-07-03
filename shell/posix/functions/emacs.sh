#!/bin/sh
# shellcheck disable=SC2039

_koopa_link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-06-30.
    #
    # Currently supports Doom, Spacemacs, and minimal ESS config.
    # """
    _koopa_assert_has_args "$#"
    local custom_prefix default_prefix name
    name="${1:?}"
    default_prefix="$(_koopa_emacs_prefix)"
    custom_prefix="${default_prefix}-${name}"
    _koopa_assert_is_dir "$custom_prefix"
    if [ -d "$default_prefix" ] && [ ! -L "$default_prefix" ]
    then
        _koopa_stop "Emacs directory detected at '${default_prefix}'."
    fi
    if [ "$name" != "minimal" ]
    then
        rm -fv "${HOME}/.emacs"
    elif [ "$name" != "spacemacs" ]
    then
        rm -fv "${HOME}/.spacemacs"
    fi
    case "$name" in
        doom)
            link-dotfile \
                --force \
                --config \
                "app/emacs/doom/config.d" \
                "doom"
            ;;
        minimal)
            link-dotfile \
                --force \
                "app/emacs/minimal/emacs.el"
            ;;
        spacemacs)
            link-dotfile \
                --force \
                "app/emacs/spacemacs/spacemacs.el" \
                "spacemacs"
            ;;
        *)
            _koopa_stop "Invalid Emacs config name."
            ;;
    esac
    ln -fnsv "$custom_prefix" "$default_prefix"
    return 0
}

_koopa_is_spacemacs_installed() { # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2020-06-29.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed emacs || return 1
    local init_file prefix
    prefix="$(_koopa_emacs_prefix)"
    # Check for 'Spacemacs' inside 'init.el' file.
    init_file="${prefix}/init.el"
    [ -s "$init_file" ] || return 1
    grep -q "Spacemacs" "$init_file" || return 1
    return 0
}

_koopa_update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2020-06-29.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    _koopa_assert_has_no_args "$#"
    local prefix
    if ! _koopa_is_spacemacs_installed
    then
        _koopa_note "Spacemacs is not installed."
        return 0
    fi
    prefix="$(_koopa_emacs_prefix)"
    (
        _koopa_cd "$prefix"
        git pull
    )
    emacs \
        --batch -l "${prefix}/init.el" \
        --eval="(configuration-layer/update-packages t)"
    return 0
}

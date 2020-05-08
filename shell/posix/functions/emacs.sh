#!/bin/sh
# shellcheck disable=SC2039

_koopa_emacs_prefix() {  # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-03-06.
    # """
    _koopa_print "${HOME}/.emacs.d"
}

_koopa_link_emacs() {  # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-03-06.
    #
    # Currently supports Doom, Spacemacs, and minimal ESS config.
    # """
    _koopa_assert_has_args "$@"

    local name
    name="${1:?}"

    local default_prefix
    default_prefix="$(_koopa_emacs_prefix)"

    local custom_prefix
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

_koopa_is_spacemacs_installed() {  # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2020-03-06.
    # """
    _koopa_is_installed emacs || return 1

    local prefix
    prefix="$(_koopa_emacs_prefix)"

    # Check for 'Spacemacs' inside 'init.el' file.
    local init_file
    init_file="${prefix}/init.el"
    [ -s "$init_file" ] || return 1
    grep -q "Spacemacs" "$init_file" || return 1

    return 0
}

_koopa_update_spacemacs() {  # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2020-03-06.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    if ! _koopa_is_spacemacs_installed
    then
        _koopa_note "Spacemacs is not installed."
        return 0
    fi

    local prefix
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

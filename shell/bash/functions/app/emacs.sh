#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2020-07-30.
    # """
    local doom emacs_prefix install_dir name repo
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed git tee
    name='doom'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    [[ -d "$install_dir" ]] && return 0
    koopa::install_start "$name" "$install_dir"
    (
        repo='https://github.com/hlissner/doom-emacs'
        git clone "$repo" "$install_dir"
        doom="${install_dir}/bin/doom"
        "$doom" quickstart
        "$doom" refresh
        "$doom" doctor
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::install_success "$name"
    return 0
}

koopa::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2020-07-30.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local emacs_prefix install_dir name
    name='spacemacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    [[ -d "$install_dir" ]] && return 0
    koopa::h1 "Installing ${name} at '${install_dir}."
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    (
        repo="https://github.com/syl20bnr/${name}.git"
        git clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        git checkout -b develop origin/develop
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::update_spacemacs
    koopa::install_success "$name"
    return 0
}

koopa::link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-07-20.
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
    koopa::ln "$custom_prefix" "$default_prefix"
    return 0
}

koopa::is_spacemacs_installed() { # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2020-06-29.
    # """
    local init_file prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
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
    local prefix
    koopa::assert_has_no_args "$#"
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

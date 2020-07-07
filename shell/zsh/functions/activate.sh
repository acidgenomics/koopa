#!/usr/bin/env zsh

koopa::activate_zsh_aliases() { # {{{1
    # """
    # Activate Zsh aliases.
    # @note Updated 2020-06-30.
    # """
    local user_aliases
    user_aliases="${HOME}/.zsh_aliases"
    if [[ -f "$user_aliases" ]]
    then
        # shellcheck source=/dev/null
        source "$user_aliases"
    fi
    return 0
}

koopa::activate_zsh_bashcompinit() { # {{{1
    # """
    # Activate Bash completions for Zsh.
    # @note Updated 2020-06-30.
    # """
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
    return 0
}

koopa::activate_zsh_colors() { # {{{1
    # """
    # Enable colors in terminal.
    # @note Updated 2020-06-30.
    # """
    autoload -Uz colors && colors 2>/dev/null
    return 0
}

koopa::activate_zsh_compinit() { # {{{1
    # """
    # Activate Zsh compinit (completion system).
    # @note Updated 2020-06-30.
    # #
    # Suppressing warning for KOOPA_TEST mode:
    # compinit:141: parse error: condition expected: $1
    # """
    autoload -Uz compinit && compinit 2>/dev/null
    return 0
}

koopa::activate_zsh_editor() { # {{{1
    # """
    # Activate Zsh editor.
    # @note Updated 2020-06-30.
    # """
    case "${EDITOR:-}" in
        emacs)
            bindkey -e
            ;;
        vi|vim)
            bindkey -v
            ;;
    esac
    return 0
}

koopa::activate_zsh_extras() { # {{{1
    # """
    # Activate Zsh extras.
    # @note Updated 2020-06-30.
    #
    # Note on path (and also fpath) arrays in Zsh:
    # https://www.zsh.org/mla/users/2012/msg00785.html
    #
    # At startup, zsh ties the array variable 'path' to the environment string
    # 'PATH' (colon-delimited). If you see only the first element of 'PATH' when
    # printing 'path', you have the ksharrays option set.
    #
    # What's the difference between 'autoload' and 'autoload -Uz'?
    # https://unix.stackexchange.com/questions/214296
    # https://stackoverflow.com/questions/30840651/what-does-autoload-do-in-zsh
    # """
    koopa::activate_zsh_fpath
    koopa::activate_zsh_compinit
    koopa::activate_zsh_bashcompinit
    koopa::activate_zsh_colors
    koopa::activate_zsh_editor
    koopa::activate_zsh_plugins
    koopa::activate_zsh_aliases
    koopa::activate_zsh_prompt
    return 0
}

koopa::activate_zsh_fpath() { # {{{1
    # """
    # Activate Zsh FPATH.
    # @note Updated 2020-06-30.
    # """
    local koopa_fpath koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    koopa_fpath="${koopa_prefix}/shell/zsh/functions"
    if [[ ! -d "$koopa_fpath" ]]
    then
        koopa::warning "FPATH directory is missing: '${koopa_fpath}'."
        return 1
    fi
    koopa::force_add_to_fpath_start "$koopa_fpath"
    return 0
}

koopa::activate_zsh_plugins() { # {{{1
    # """
    # Activate Zsh plugins.
    # Updated 2020-06-30.
    #
    # Debug plugins via:
    # > zsh -df
    # 
    # Lines to array in Zsh:
    # https://unix.stackexchange.com/questions/29724/
    # Alternatively, can use '<<<' herestring, which also works in Bash.
    # """
    local dotfiles_prefix plugin plugins zsh_plugins_dir
    dotfiles_prefix="$(koopa::dotfiles_prefix)"
    zsh_plugins_dir="${dotfiles_prefix}/shell/zsh/plugins"
    [[ -d "$zsh_plugins_dir" ]] || return 0
    plugins=("${(@f)$( \
        find "$zsh_plugins_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -print0 \
        | sort -z \
        | xargs -0 -n1 basename \
    )}")
    for plugin in "${plugins[@]}"
    do
        source "${zsh_plugins_dir}/${plugin}/${plugin}.zsh"
    done
    return 0
}

koopa::activate_zsh_prompt() { # {{{1
    # """
    # Activate Zsh prompt.
    # Updated 2020-06-30.
    #
    # See also:
    # - https://github.com/sindresorhus/pure
    # - https://github.com/sindresorhus/pure/wiki
    #
    # This won't work if an oh-my-zsh theme is enabled.
    # This step must be sourced after oh-my-zsh.
    # """
    [[ "${KOOPA_TEST:-}" -eq 1 ]] && set +u
    setopt promptsubst
    autoload -U promptinit
    promptinit
    prompt koopa
    [[ "${KOOPA_TEST:-}" -eq 1 ]] && set -u
    return 0
}

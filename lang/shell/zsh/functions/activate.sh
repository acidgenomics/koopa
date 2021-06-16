#!/usr/bin/env zsh

_koopa_activate_zsh_aliases() { # {{{1
    # """
    # Activate Zsh aliases.
    # @note Updated 2020-11-24.
    # """
    local user_aliases
    [[ "$#" -eq 0 ]] || return 1
    user_aliases="${HOME}/.zsh_aliases"
    if [[ -f "$user_aliases" ]]
    then
        # shellcheck source=/dev/null
        source "$user_aliases"
    fi
    return 0
}

_koopa_activate_zsh_bashcompinit() { # {{{1
    # """
    # Activate Bash completions for Zsh.
    # @note Updated 2020-11-24.
    # """
    [[ "$#" -eq 0 ]] || return 1
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
    return 0
}

_koopa_activate_zsh_colors() { # {{{1
    # """
    # Enable colors in terminal.
    # @note Updated 2020-11-24.
    # """
    [[ "$#" -eq 0 ]] || return 1
    autoload -Uz colors && colors 2>/dev/null
    return 0
}

_koopa_activate_zsh_compinit() { # {{{1
    # """
    # Activate Zsh compinit (completion system).
    # @note Updated 2020-11-24.
    # """
    [[ "$#" -eq 0 ]] || return 1
    autoload -Uz compinit && compinit 2>/dev/null
    return 0
}

_koopa_activate_zsh_editor() { # {{{1
    # """
    # Activate Zsh editor.
    # @note Updated 2020-11-24.
    # """
    [[ "$#" -eq 0 ]] || return 1
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

_koopa_activate_zsh_extras() { # {{{1
    # """
    # Activate Zsh extras.
    # @note Updated 2021-05-26.
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
    [[ "$#" -eq 0 ]] || return 1
    _koopa_is_interactive || return 0
    _koopa_activate_zsh_fpath
    _koopa_activate_zsh_compinit
    _koopa_activate_zsh_bashcompinit
    _koopa_activate_zsh_colors
    _koopa_activate_zsh_editor
    _koopa_activate_zsh_plugins
    _koopa_activate_zsh_aliases
    _koopa_activate_zsh_prompt
    _koopa_activate_completion
    bindkey '^R' history-incremental-search-backward
    return 0
}

_koopa_activate_zsh_fpath() { # {{{1
    # """
    # Activate Zsh FPATH.
    # @note Updated 2021-01-19.
    # """
    local koopa_fpath koopa_prefix
    [[ "$#" -eq 0 ]] || return 1
    koopa_prefix="$(_koopa_koopa_prefix)"
    koopa_fpath="${koopa_prefix}/lang/shell/zsh/functions"
    if [[ ! -d "$koopa_fpath" ]]
    then
        _koopa_warning "FPATH directory is missing: '${koopa_fpath}'."
        return 1
    fi
    _koopa_add_to_fpath_start "$koopa_fpath"
    return 0
}

_koopa_activate_zsh_plugins() { # {{{1
    # """
    # Activate Zsh plugins.
    # Updated 2021-05-25.
    #
    # Debug plugins via:
    # > zsh -df
    #
    # Lines to array in Zsh:
    # https://unix.stackexchange.com/questions/29724/
    # Alternatively, can use '<<<' herestring, which also works in Bash.
    # """
    local dotfiles_prefix plugin plugins zsh_plugins_dir
    [[ "$#" -eq 0 ]] || return 1
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"
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

_koopa_activate_zsh_prompt() { # {{{1
    # """
    # Activate Zsh prompt.
    # Updated 2021-05-25.
    #
    # See also:
    # - https://github.com/sindresorhus/pure
    # - https://github.com/sindresorhus/pure/wiki
    #
    # This won't work if an oh-my-zsh theme is enabled.
    # This step must be sourced after oh-my-zsh.
    # """
    local nounset
    [[ "$#" -eq 0 ]] || return 1
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +u
    setopt promptsubst
    autoload -U promptinit
    promptinit
    prompt koopa
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}

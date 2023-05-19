#!/usr/bin/env zsh

_koopa_activate_zsh_aliases() {
    # """
    # Activate Zsh aliases.
    # @note Updated 2020-11-24.
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

_koopa_activate_zsh_bashcompinit() {
    # """
    # Activate Bash completions for Zsh.
    # @note Updated 2020-11-24.
    # """
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
    return 0
}

_koopa_activate_zsh_colors() {
    # """
    # Enable colors in terminal.
    # @note Updated 2020-11-24.
    # """
    autoload -Uz colors && colors 2>/dev/null
    return 0
}

_koopa_activate_zsh_compinit() {
    # """
    # Activate Zsh compinit (completion system).
    # @note Updated 2020-11-24.
    # """
    autoload -Uz compinit && compinit 2>/dev/null
    return 0
}

_koopa_activate_zsh_editor() {
    # """
    # Activate Zsh editor.
    # @note Updated 2020-11-24.
    # """
    case "${EDITOR:-}" in
        'emacs')
            bindkey -e
            ;;
        'vi' | \
        'vim')
            bindkey -v
            ;;
    esac
    return 0
}

_koopa_activate_zsh_extras() {
    # """
    # Activate Zsh extras.
    # @note Updated 2021-06-16.
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
    _koopa_is_interactive || return 0
    _koopa_activate_zsh_fpath
    _koopa_activate_zsh_compinit
    _koopa_activate_zsh_bashcompinit
    _koopa_activate_zsh_colors
    _koopa_activate_zsh_editor
    _koopa_activate_zsh_plugins
    _koopa_activate_zsh_aliases
    _koopa_activate_zsh_prompt
    _koopa_activate_zsh_reverse_search
    _koopa_activate_completion
    return 0
}

_koopa_activate_zsh_fpath() {
    # """
    # Activate Zsh FPATH.
    # @note Updated 2023-05-18.
    # """
    local koopa_fpath koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    koopa_fpath="${koopa_prefix}/lang/zsh/functions"
    if [[ ! -d "$koopa_fpath" ]]
    then
        _koopa_warn "FPATH directory is missing: '${koopa_fpath}'."
        return 1
    fi
    _koopa_add_to_fpath_start "$koopa_fpath"
    return 0
}

_koopa_activate_zsh_plugins() {
    # """
    # Activate Zsh plugins.
    # Updated 2022-05-10.
    #
    # Debug plugins via:
    # > zsh -df
    #
    # Lines to array in Zsh:
    # https://unix.stackexchange.com/questions/29724/
    # Alternatively, can use '<<<' herestring, which also works in Bash.
    # """
    local dotfiles_prefix plugin plugins zsh_plugins_dir
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"
    zsh_plugins_dir="$(_koopa_xdg_data_home)/zsh/plugins"
    [[ -d "$zsh_plugins_dir" ]] || return 0
    plugins=("${(@f)$( \
        find "$zsh_plugins_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type 'd' \
        | sort \
        | xargs basename \
    )}")
    for plugin in "${plugins[@]}"
    do
        source "${zsh_plugins_dir}/${plugin}/${plugin}.zsh"
    done
    return 0
}

_koopa_activate_zsh_prompt() {
    # """
    # Activate Zsh prompt.
    # Updated 2023-03-09.
    #
    # See also:
    # - https://github.com/sindresorhus/pure
    # - https://github.com/sindresorhus/pure/wiki
    #
    # This won't work if an oh-my-zsh theme is enabled.
    # This step must be sourced after oh-my-zsh.
    # """
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    setopt promptsubst
    autoload -U promptinit
    promptinit
    prompt koopa
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_zsh_reverse_search() {
    # """
    # Activate reverse search using Ctrl+R in Zsh.
    # @note Updated 2023-02-01.
    #
    # > bindkey '^R' 'history-incremental-search-backward'
    # """
    _koopa_activate_mcfly
}

_koopa_add_to_fpath_start() {
    # """
    # Force add to 'FPATH' start.
    # @note Updated 2023-03-09.
    # """
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(_koopa_add_to_path_string_start "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

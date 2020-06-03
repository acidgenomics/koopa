#!/usr/bin/env zsh

_koopa_activate_zsh_extras() {  # {{{1
    # """
    # Activate Zsh extras.
    # Updated 2020-04-13.
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
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"

    local koopa_fpath
    koopa_fpath="${koopa_prefix}/shell/zsh/functions"
    if [[ ! -d "$koopa_fpath" ]]
    then
        _koopa_warning "FPATH directory is missing: '${koopa_fpath}'."
        return 1
    fi
    _koopa_force_add_to_fpath_start "$koopa_fpath"

    # Enable colors in terminal.
    autoload -Uz colors && colors

    # Enable completion system.
    # Suppressing warning for KOOPA_TEST mode:
    # compinit:141: parse error: condition expected: $1
    autoload -Uz compinit && compinit 2>/dev/null

    _koopa_activate_zsh_options
    _koopa_activate_zsh_plugins
    _koopa_activate_zsh_prompt
    return 0
}

_koopa_activate_zsh_options() {  # {{{1
    # """
    # Activate Zsh shell options.
    # Updated 2020-06-03.
    #
    # Debug with:
    # - bindkey
    # - setopt
    #
    # See also:
    # - http://zsh.sourceforge.net/Doc/Release/Completion-System.html
    # - http://zsh.sourceforge.net/Doc/Release/Options.html
    # - http://zsh.sourceforge.net/Doc/Release/Options.html#index-MARKDIRS
    # - http://zsh.sourceforge.net/Doc/Release/Options.html#index-NOMARKDIRS
    # - http://zsh.sourceforge.net/Guide/zshguide06.html
    # - https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/completion.zsh
    # """

    # Map key bindings to default editor.
    # Note that Bash currently uses Emacs by default.
    case "${EDITOR:-}" in
        emacs)
            bindkey -e
            ;;
        vi|vim)
            bindkey -v
            ;;
    esac

    # Fix the delete key.
    bindkey "\e[3~" delete-char

    local setopt_array
    setopt_array=(
        # auto_menu                 # completion
        # auto_name_dirs            # dirs
        # complete_aliases          # completion
        # extended_glob             # glob
        always_to_end               # completion
        append_history              # history
        auto_cd                     # dirs
        auto_pushd                  # dirs
        complete_in_word            # completion
        extended_history            # history
        hist_expire_dups_first      # history
        hist_ignore_dups            # history
        hist_ignore_space           # history
        hist_verify                 # history
        inc_append_history          # history
        interactive_comments        # misc
        long_list_jobs              # jobs
        pushd_ignore_dups           # dirs
        pushd_minus                 # dirs
        share_history               # history
    )
    setopt "${setopt_array[@]}"

    local unsetopt_array
    unsetopt_array=(
        bang_hist
        flow_control
    )
    unsetopt "${unsetopt_array[@]}"

    return 0
}

_koopa_activate_zsh_plugins() {  # {{{1
    # """
    # Activate Zsh plugins.
    # Updated 2020-06-03.
    #
    # Debug plugins via:
    # > zsh -df
    # """
    local dotfiles_prefix
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"

    local zsh_plugins_dir
    zsh_plugins_dir="${dotfiles_prefix}/shell/zsh/plugins"
    [[ -d "$zsh_plugins_dir" ]] || return 0

    if [[ -d "${zsh_plugins_dir}/zsh-autosuggestions" ]]
    then
        source "${zsh_plugins_dir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
        # Set the autosuggest text color.
        # Define using xterm-256 color code.
        #
        # 'fg=240' also works well with Dracula theme.
        #
        # See also:
        # - https://stackoverflow.com/questions/47310537
        # - https://upload.wikimedia.org/wikipedia/
        #       commons/1/15/Xterm_256color_chart.svg
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=005"
    fi

    return 0
}

_koopa_activate_zsh_prompt() {  # {{{1
    # """
    # Activate Zsh prompt.
    # Updated 2020-06-03.
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


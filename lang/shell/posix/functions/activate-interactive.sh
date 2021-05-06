#!/bin/sh

_koopa_activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2021-05-04.
    # """
    local file
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    # > alias perl='unalias perl && _koopa_activate_perl_packages && perl'
    alias br='unalias br && _koopa_activate_broot && br'
    alias conda='unalias conda && _koopa_activate_conda && conda'
    alias fzf='unalias fzf && _koopa_activate_fzf && fzf'
    alias perlbrew='unalias perlbrew && _koopa_activate_perlbrew && perlbrew'
    alias pipx='unalias pipx && _koopa_activate_pipx && pipx'
    alias pyenv='unalias pyenv && _koopa_activate_pyenv && pyenv'
    alias rbenv='unalias rbenv && _koopa_activate_rbenv && rbenv'
    alias z='unalias z && _koopa_activate_zoxide && z'
    file="${HOME}/.aliases"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    file="${HOME}/.aliases-private"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    return 0
}

_koopa_activate_broot() { # {{{1
    # """
    # Activate broot directory tree utility.
    # @note Updated 2021-01-01.
    #
    # The br function script must be sourced for activation.
    # See 'broot --install' for details.
    #
    # Configuration file gets saved at '${prefs_dir}/conf.toml'.
    # Fish: launcher/fish/br.sh (also saved in Fish functions)
    #
    # Note that for macOS, we're assuming installation via Homebrew.
    # If installed as crate, it will use the same path as for Linux.
    #
    # @seealso
    # https://github.com/Canop/broot
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local br_script config_dir nounset
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    config_dir="${HOME}/.config/broot"
    [ -d "$config_dir" ] || return 0
    # This is supported for Bash and Zsh.
    br_script="${config_dir}/launcher/bash/br"
    [ -f "$br_script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$br_script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_completion() { # {{{1
    # """
    # Activate completion (with TAB key).
    # @note Updated 2020-11-14.
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local file
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    for file in "$(_koopa_prefix)/etc/completion/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    return 0
}

_koopa_activate_dircolors() { # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2020-11-14.
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local dircolors_file dotfiles_prefix
    _koopa_is_installed dircolors || return 0
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"
    # This will set the 'LD_COLORS' environment variable.
    dircolors_file="${dotfiles_prefix}/app/coreutils/dircolors"
    if [ -f "$dircolors_file" ]
    then
        eval "$(dircolors "$dircolors_file")"
    else
        eval "$(dircolors -b)"
    fi
    unset -v dircolors_file
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
    return 0
}

_koopa_activate_fzf() { # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2021-04-12.
    #
    # Currently Bash and Zsh are supported.
    #
    # Shell lockout has been observed on Ubuntu unless we disable 'set -e'.
    #
    # @seealso
    # - https://github.com/junegunn/fzf
    # - https://dev.to/iggredible/how-to-search-faster-in-vim-with-fzf-vim-36ko
    # Customization:
    # - https://github.com/ngynLk/dotfiles/blob/master/.bashrc
    # - Dracula palette:
    #   https://gist.github.com/umayr/8875b44740702b340430b610b52cd182
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local nounset prefix script shell
    if [ -z "${FZF_DEFAULT_COMMAND:-}" ]
    then
        export FZF_DEFAULT_COMMAND='rg --files'
    fi
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        # On multi-select mode (-m/--multi), TAB and Shift-TAB to mark
        # multiple items.
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    prefix="$(_koopa_fzf_prefix)/latest"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    nounset="$(_koopa_boolean_nounset)"
    shell="$(_koopa_shell)"
    # Relax hardened shell temporarily, if necessary.
    if [ "$nounset" -eq 1 ]
    then
        set +e
        set +u
    fi
    # Auto-completion.
    script="${prefix}/shell/completion.${shell}"
    if [ -f "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    # Key bindings.
    script="${prefix}/shell/key-bindings.${shell}"
    if [ -f "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    # Reset hardened shell, if necessary.
    if [ "$nounset" -eq 1 ]
    then
        set -e
        set -u
    fi
    return 0
}

_koopa_activate_starship() { # {{{1
    # """
    # Activate starship prompt.
    # @note Updated 2020-11-16.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local nounset shell
    _koopa_is_installed starship || return 0
    shell="$(_koopa_shell)"
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$(starship init "$shell")"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_zoxide() { # {{{1
    # """
    # Activate zoxide.
    # @note Updated 2020-11-14.
    #
    # Highly recommended to use along with fzf.
    #
    # POSIX option:
    # eval "$(zoxide init posix --hook prompt)"
    #
    # @seealso
    # - https://github.com/ajeetdsouza/zoxide
    # """
    [ "${KOOPA_INTERACTIVE:-1}" -eq 1 ] || return 0
    local shell nounset
    shell="$(_koopa_shell)"
    case "$shell" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    _koopa_is_installed zoxide || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$(zoxide init "$shell")"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_macos_activate_cli_colors() { # {{{1
    # """
    # Activate macOS-specific extra settings.
    # @note Updated 2020-07-05.
    # """
    # Improve terminal colors.
    if [ -z "${CLICOLOR:-}" ]
    then
        export CLICOLOR=1
    fi
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. #Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    if [ -z "${LSCOLORS:-}" ]
    then
        export LSCOLORS='Gxfxcxdxbxegedabagacad'
    fi
    return 0
}

_koopa_macos_color_mode() { # {{{1
    # """
    # Return the color mode (dark/light) value.
    # @note Updated 2021-05-06.
    # """
    local x
    if _koopa_macos_is_dark_mode
    then
        x='dark'
    else
        x='light'
    fi
    _koopa_print "$x"
}

_koopa_macos_activate_color_mode() { # {{{1
    # """
    # Activate macOS color mode.
    # @note Updated 2021-05-06.
    # """
    KOOPA_COLOR_MODE="$(_koopa_macos_color_mode)"
    export KOOPA_COLOR_MODE
    return 0
}

_koopa_macos_activate_iterm() { # {{{1
    # """
    # Activate iTerm2 configuration.
    # @note Updated 2021-05-06.
    #
    # Only attempt to dynamically set dark/light theme if the current iTerm2
    # theme is named either 'dark' or 'light'.
    #
    # @seealso
    # - https://apas.gr/2018/11/dark-mode-macos-safari-iterm-vim/
    # """
    local iterm_theme koopa_theme
    [ "${TERM_PROGRAM:-}" = 'iTerm.app' ] || return 0
    iterm_theme="${ITERM_PROFILE:-}"
    koopa_theme="${KOOPA_COLOR_MODE:-}"
    [ -n "$koopa_theme" ] || return 0
    if [ "$iterm_theme" != "$koopa_theme" ] && \
        { [ "$iterm_theme" = 'dark' ] || [ "$iterm_theme" = 'light' ]; }
    then
        _koopa_alert "Attempting to switch iTerm profile from \
'${iterm_theme}' to non-default '${koopa_theme}'."
        _koopa_print "\033]50;SetProfile=${koopa_theme}\a"
        ITERM_PROFILE="$koopa_theme"
    fi
    export ITERM_PROFILE
    return 0
}

#!/bin/sh
# shellcheck disable=SC2032

_koopa_activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2021-05-07.
    # """
    local file
    _koopa_is_interactive || return 0
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
    # @note Updated 2021-05-07.
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
    local br_script config_dir nounset shell
    _koopa_is_interactive || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
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
    # @note Updated 2021-05-06.
    # """
    local file koopa_prefix shell
    _koopa_is_interactive || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    koopa_prefix="$(_koopa_prefix)"
    for file in "${koopa_prefix}/etc/completion/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    return 0
}

_koopa_activate_dircolors() { # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2021-05-10.
    #
    # This will set the 'LD_COLORS' environment variable.
    # """
    local dir dircolors dircolors_file dotfiles_prefix egrep fgrep grep ls vdir
    _koopa_is_interactive || return 0
    [ -n "${SHELL:-}" ] || return 0
    export SHELL  # RStudio shell config edge case.
    dir='dir'
    dircolors='dircolors'
    egrep='egrep'
    fgrep='fgrep'
    grep='grep'
    ls='ls'
    vdir='vdir'
    if _koopa_is_macos && _koopa_is_installed gdircolors
    then
        dir='gdir'
        dircolors='gdircolors'
        egrep='gegrep'
        fgrep='gfgrep'
        grep='ggrep'
        ls='gls'
        vdir='gvdir'
    fi
    _koopa_is_installed "$dircolors" || return 0
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"
    dircolors_file="${dotfiles_prefix}/app/coreutils/dircolors"
    if _koopa_is_macos
    then
        if _koopa_macos_is_dark_mode
        then
            # e.g. dracula
            dircolors_file="${dircolors_file}-dark"
        elif _koopa_macos_is_light_mode
        then
            # e.g. solarized light
            dircolors_file="${dircolors_file}-light"
        fi
    fi
    if [ -f "$dircolors_file" ]
    then
        eval "$("$dircolors" "$dircolors_file")"
    else
        eval "$("$dircolors" -b)"
    fi
    # shellcheck disable=SC2139
    alias dir="${dir} --color=auto"
    # shellcheck disable=SC2139
    alias egrep="${egrep} --color=auto"
    # shellcheck disable=SC2139
    alias fgrep="${fgrep} --color=auto"
    # shellcheck disable=SC2139
    alias grep="${grep} --color=auto"
    # shellcheck disable=SC2139
    alias ls="${ls} --color=auto"
    # shellcheck disable=SC2139
    alias vdir="${vdir} --color=auto"
    return 0
}

_koopa_activate_fzf() { # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2021-05-07.
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
    local nounset prefix script shell
    _koopa_is_interactive || return 0
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
    shell="$(_koopa_shell_name)"
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
    # @note Updated 2021-05-24.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    local nounset shell
    _koopa_is_interactive || return 0
    _koopa_is_installed starship || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    nounset="$(_koopa_boolean_nounset)"
    # FIXME When KOOPA_TEST=1, hitting this unbound variable error with Bash
    # STARSHIP_PREEXEC_READY
    [ "$nounset" -eq 1 ] && echo 'FIXME 1' && set +u
    eval "$(starship init "$shell")"
    [ "$nounset" -eq 1 ] && echo 'FIXME 2' && set -u
    return 0
}

_koopa_activate_tmux_sessions() { # {{{1
    # """
    # Show active tmux sessions.
    # @note Updated 2021-05-21.
    # """
    local x
    _koopa_is_installed tmux || return 0
    _koopa_is_tmux && return 0
    cut="$(_koopa_locate_cut)"
    tr="$(_koopa_locate_tr)"
    # shellcheck disable=SC2033
    x="$(tmux ls 2>/dev/null || true)"
    [ -n "$x" ] || return 0
    x="$( \
        _koopa_print "$x" \
        | "$cut" -d ':' -f 1 \
        | "$tr" '\n' ' ' \
    )"
    _koopa_dl 'tmux' "$x"
    return 0
}

_koopa_activate_today_bucket() { # {{{1
    # """
    # Create a dated file today bucket.
    # @note Updated 2021-05-24.
    #
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    # """
    local bucket_dir date ln mkdir readlink today_bucket today_link
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    [ -d "$bucket_dir" ] || return 0
    date="$(_koopa_locate_date)"
    ln="$(_koopa_locate_ln)"
    mkdir="$(_koopa_locate_mkdir)"
    readlink="$(_koopa_locate_readlink)"
    today_bucket="$("$date" '+%Y/%m/%d')"
    today_link="${HOME:?}/today"
    # Early return if we've already updated the symlink.
    _koopa_str_match "$("$readlink" "$today_link")" "$today_bucket" && return 0
    "$mkdir" -p "${bucket_dir}/${today_bucket}"
    "$ln" -fns "${bucket_dir}/${today_bucket}" "$today_link"
    return 0
}

_koopa_activate_zoxide() { # {{{1
    # """
    # Activate zoxide.
    # @note Updated 2021-05-07.
    #
    # Highly recommended to use along with fzf.
    #
    # POSIX option:
    # eval "$(zoxide init posix --hook prompt)"
    #
    # @seealso
    # - https://github.com/ajeetdsouza/zoxide
    # """
    local nounset shell
    _koopa_is_interactive || return 0
    shell="$(_koopa_shell_name)"
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
    # Activate macOS-specific terminal color settings.
    # @note Updated 2020-07-05.
    #
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    # """
    _koopa_is_interactive || return 0
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

_koopa_macos_activate_color_mode() { # {{{1
    # """
    # Activate macOS color mode.
    # @note Updated 2021-05-07.
    # """
    _koopa_is_interactive || return 0
    KOOPA_COLOR_MODE="$(_koopa_macos_color_mode)"
    export KOOPA_COLOR_MODE
    return 0
}

_koopa_macos_activate_iterm() { # {{{1
    # """
    # Activate iTerm2 configuration.
    # @note Updated 2021-05-07.
    #
    # Only attempt to dynamically set dark/light theme if the current iTerm2
    # theme is named either 'dark' or 'light'.
    #
    # @seealso
    # - https://apas.gr/2018/11/dark-mode-macos-safari-iterm-vim/
    # """
    local iterm_theme koopa_theme
    _koopa_is_interactive || return 0
    [ "${TERM_PROGRAM:-}" = 'iTerm.app' ] || return 0
    iterm_theme="${ITERM_PROFILE:-}"
    koopa_theme="${KOOPA_COLOR_MODE:-}"
    [ -n "$koopa_theme" ] || return 0
    if [ "$iterm_theme" != "$koopa_theme" ] && \
        { [ "$iterm_theme" = 'dark' ] || [ "$iterm_theme" = 'light' ]; }
    then
        _koopa_alert "🌗 Switching iTerm '${iterm_theme}' to \
non-default '${koopa_theme}' profile."
        _koopa_print "\033]50;SetProfile=${koopa_theme}\a"
        ITERM_PROFILE="$koopa_theme"
    fi
    export ITERM_PROFILE
    return 0
}

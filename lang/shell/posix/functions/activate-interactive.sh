#!/bin/sh
# shellcheck disable=SC2032

_koopa_activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2021-09-16.
    # """
    local file
    [ "$#" -eq 0 ] || return 1
    alias br='_koopa_alias_broot'
    alias bucket='_koopa_alias_bucket'
    # > alias conda='_koopa_alias_conda'
    alias doom-emacs='_koopa_alias_doom_emacs'
    alias emacs-vanilla='_koopa_alias_emacs_vanilla'
    alias emacs='_koopa_alias_emacs'
    alias fzf='_koopa_alias_fzf'
    alias j='z'
    alias k='_koopa_alias_k'
    # > alias mcfly='_koopa_alias_mcfly'
    alias nvim-fzf='_koopa_alias_nvim_fzf'
    alias nvim-vanilla='_koopa_alias_nvim_vanilla'
    # > alias perl='_koopa_alias_perl'
    alias perlbrew='_koopa_alias_perlbrew'
    alias pipx='_koopa_alias_pipx'
    alias pyenv='_koopa_alias_pyenv'
    alias rbenv='_koopa_alias_rbenv'
    alias sha256='_koopa_alias_sha256'
    alias spacemacs='_koopa_alias_spacemacs'
    alias spacevim='_koopa_alias_spacevim'
    alias tar-c='_koopa_alias_tar_c'
    alias tar-x='_koopa_alias_tar_x'
    alias today='_koopa_alias_today'
    alias vim-fzf='_koopa_alias_vim_fzf'
    alias vim-vanilla='_koopa_alias_vim_vanilla'
    alias week='_koopa_alias_week'
    alias z='_koopa_alias_zoxide'
    file="${HOME:?}/.aliases"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    file="${HOME:?}/.aliases-private"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    return 0
}

_koopa_activate_broot() { # {{{1
    # """
    # Activate broot directory tree utility.
    # @note Updated 2021-06-16.
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
    local config_dir nounset script shell
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    config_dir="${HOME}/.config/broot"
    [ -d "$config_dir" ] || return 0
    # This is supported for Bash and Zsh.
    script="${config_dir}/launcher/bash/br"
    [ -f "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_completion() { # {{{1
    # """
    # Activate completion (with TAB key).
    # @note Updated 2021-05-06.
    # """
    local file koopa_prefix shell
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    koopa_prefix="$(_koopa_koopa_prefix)"
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
    [ "$#" -eq 0 ] || return 1
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
    # @note Updated 2021-06-02.
    #
    # Currently Bash and Zsh are supported.
    # Shell lockout has been observed on Ubuntu unless we disable 'set -e'.
    # """
    local fzfrc nounset prefix script shell
    [ "$#" -eq 0 ] || return 1
    fzfrc="$(_koopa_dotfiles_prefix)/app/fzf/fzfrc"
    # shellcheck source=/dev/null
    [ -f "$fzfrc" ] && . "$fzfrc"
    prefix="$(_koopa_fzf_prefix)"
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

_koopa_activate_gcc_colors() { # {{{1
    # """
    # Activate GCC colors.
    # @note Updated 2020-06-30.
    # @seealso
    # - https://gcc.gnu.org/onlinedocs/gcc-10.1.0/gcc/
    #     Diagnostic-Message-Formatting-Options.html
    # """
    [ "$#" -eq 0 ] || return 1
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

_koopa_activate_gnu_aliases() { # {{{1
    # """
    # Activate GNU aliases.
    # @note Updated 2021-08-18.
    #
    # Creates hardened interactive aliases for GNU coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # """
    local cp harden_coreutils ln mkdir mv opt_prefix rm
    [ "$#" -eq 0 ] || return 1
    if _koopa_is_linux
    then
        harden_coreutils=1
        cp='cp'
        ln='ln'
        mkdir='mkdir'
        mv='mv'
        rm='rm'
    elif _koopa_is_macos
    then
        _koopa_is_installed 'brew' || return 0
        opt_prefix="$(_koopa_homebrew_prefix)/opt"
        # > if [ -d "${opt_prefix}/bc" ]
        # > then
        # >     # shellcheck disable=SC2139
        # >     alias bc="${opt_prefix}/bc/bin/bc"
        # > fi
        if [ -d "${opt_prefix}/coreutils" ]
        then
            harden_coreutils=1
            cp='gcp'
            ln='gln'
            mkdir='gmkdir'
            mv='gmv'
            rm='grm'
            # Standardize using GNU variants by default.
            # > alias base64='gbase64'
            # > alias basename='gbasename'
            # > alias cat='gcat'
            # > alias chgrp='gchgrp'
            # > alias chmod='gchmod'
            # > alias chown='gchown'
            # > alias chroot='gchroot'
            # > alias cut='gcut'
            # > alias date='gdate'
            # > alias dirname='gdirname'
            # > alias du='gdu'
            # > alias head='ghead'
            # > alias readlink='greadlink'
            # > alias realpath='grealpath'
            # > alias sort='gsort'
            # > alias stat='gstat'
            # > alias tail='gtail'
            # > alias tee='gtee'
            # > alias tr='gtr'
            # > alias uname='guname'
            # > alias uniq='guniq'
            # > alias whoami='gwhoami'
            # > alias yes='gyes'
        else
            _koopa_alert_is_not_installed 'Homebrew coreutils'
            harden_coreutils=0
        fi
        # > if [ -d "${opt_prefix}/findutils" ]
        # > then
        # >     alias find='gfind'
        # >     alias xargs='gxargs'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew findutils'
        # > fi
        # > if [ -d "${opt_prefix}/gawk" ]
        # > then
        # >     alias awk='gawk'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew gawk'
        # > fi
        # > if [ -d "${opt_prefix}/gnu-sed" ]
        # > then
        # >     alias sed='gsed'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew gnu-sed'
        # > fi
        # > if [ -d "${opt_prefix}/gnu-tar" ]
        # > then
        # >     alias tar='gtar'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew gnu-tar'
        # > fi
        # > if [ -d "${opt_prefix}/grep" ]
        # > then
        # >     alias grep='ggrep'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew grep'
        # > fi
        # > if [ -d "${opt_prefix}/make" ]
        # > then
        # >     alias make='gmake'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew make'
        # > fi
        # > if [ -d "${opt_prefix}/man-db" ]
        # > then
        # >     alias man='gman'
        # > else
        # >     _koopa_alert_is_not_installed 'Homebrew man-db'
        # > fi
    fi
    if [ "$harden_coreutils" -eq 1 ]
    then
        # The '--archive' flag seems to have issues on some file systems.
        # shellcheck disable=SC2139
        alias cp="${cp} --interactive --recursive" # -i
        # shellcheck disable=SC2139
        alias ln="${ln} --interactive --no-dereference --symbolic" # -ins
        # shellcheck disable=SC2139
        alias mkdir="${mkdir} --parents" # -p
        # shellcheck disable=SC2139
        alias mv="${mv} --interactive" # -i
        # Problematic on some file systems: --dir --preserve-root
        # Don't enable '--recursive' here by default, so we don't accidentally
        # nuke an important directory.
        # shellcheck disable=SC2139
        alias rm="${rm} --interactive=once" # -I
    fi
    return 0
}

_koopa_activate_lesspipe() { # {{{1
    # """
    # Activate lesspipe.
    # @note Updated 2021-07-22.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://manned.org/lesspipe
    # - brew info lesspipe
    # """
    _koopa_is_installed 'lesspipe.sh' || return 0
    export LESS_ADVANCED_PREPROCESSOR=1
    export LESSOPEN="|lesspipe.sh %s"
    return 0
}

_koopa_activate_mcfly() { #{{{1
    # """
    # Activate mcfly.
    # @note Updated 2021-09-16.
    #
    # Use 'mcfly search XXX' to query directly.
    # """
    local nounset shell
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'mcfly' || return 1
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    # > export MCFLY_LIGHT=true
    case "${EDITOR:-}" in
        'emacs' | \
        'vim')
            export MCFLY_KEY_SCHEME="${EDITOR:?}"
        ;;
    esac
    export MCFLY_FUZZY=true
    export MCFLY_HISTORY_LIMIT=10000
    export MCFLY_KEY_SCHEME='vim'
    export MCFLY_RESULTS=50
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$(mcfly init "$shell")"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_starship() { # {{{1
    # """
    # Activate starship prompt.
    # @note Updated 2021-07-28.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    local nounset shell
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed starship || return 0
    unset -v STARSHIP_SESSION_KEY STARSHIP_SHELL
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && return 0
    eval "$(starship init "$shell")"
    return 0
}

_koopa_activate_tealdeer() { # {{{1
    # """
    # Activate Rust tealdeer (tldr).
    # @note Updated 2021-08-31.
    #
    # This helps standardization the configuration across Linux and macOS.
    # """
    _koopa_is_installed 'tldr' || return 0
    if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    then
        TEALDEER_CACHE_DIR="${XDG_CACHE_HOME:?}/tealdeer"
    fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME:?}/tealdeer"
    fi
    if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    then
        mkdir -p "${TEALDEER_CACHE_DIR:?}"
    fi
    export TEALDEER_CACHE_DIR TEALDEER_CONFIG_DIR
    return 0
}

_koopa_activate_tmux_sessions() { # {{{1
    # """
    # Show active tmux sessions.
    # @note Updated 2021-05-26.
    # """
    local cut tr x
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed tmux || return 0
    _koopa_is_tmux && return 0
    cut='cut'
    tr='tr'
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
    # @note Updated 2021-05-26.
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
    local brew_prefix bucket_dir date ln mkdir readlink today_bucket today_link
    [ "$#" -eq 0 ] || return 1
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    [ -d "$bucket_dir" ] || return 0
    date='date'
    ln='ln'
    mkdir='mkdir'
    readlink='readlink'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        date="${brew_prefix}/opt/coreutils/bin/gdate"
        ln="${brew_prefix}/opt/coreutils/bin/gln"
        mkdir="${brew_prefix}/opt/coreutils/bin/gmkdir"
        readlink="${brew_prefix}/opt/coreutils/bin/greadlink"
    fi
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
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
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
    [ "$#" -eq 0 ] || return 1
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

_koopa_macos_activate_color_mode() { # {{{1
    # """
    # Activate macOS color mode.
    # @note Updated 2021-05-07.
    # """
    [ "$#" -eq 0 ] || return 1
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
    [ "$#" -eq 0 ] || return 1
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

#!/bin/sh

__koopa_add_to_path_string_end() { # {{{1
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2022-04-17.
    # """
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if koopa_str_detect_posix "$str" ":${dir}"
    then
        str="$(__koopa_remove_from_path_string "$str" ":${dir}")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${str}:${dir}"
    fi
    koopa_print "$str"
    return 0
}

__koopa_add_to_path_string_start() { # {{{1
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2022-04-17.
    # """
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if koopa_str_detect_posix "$str" "${dir}:"
    then
        str="$(__koopa_remove_from_path_string "$str" "${dir}:")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${dir}:${str}"
    fi
    koopa_print "$str"
    return 0
}

__koopa_id() { # {{{1
    # """
    # Return ID string.
    # @note Updated 2022-02-25.
    # """
    local str
    str="$(id "$@")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

__koopa_packages_prefix() { # {{{1
    # """
    # Packages prefix for a specific language.
    # @note Updated 2022-02-25.
    #
    # @usage __koopa_packages_prefix NAME [VERSION]
    # """
    local name str version
    name="${1:?}-packages"
    version="${2:-}"
    if [ -n "$version" ]
    then
        version="$(koopa_major_minor_version "$version")"
        str="$(koopa_app_prefix)/${name}/${version}"
    else
        str="$(koopa_opt_prefix)/${name}"
    fi
    koopa_print "$str"
    return 0
}

__koopa_remove_from_path_string() { # {{{1
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2022-04-17.
    #
    # Alternative non-POSIX approach that works on Bash and Zsh:
    # > PATH="${PATH//:$dir/}"
    # """
    koopa_print "${1:?}" | sed "s|${2:?}||g"
    return 0
}

koopa_activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2022-04-13.
    # """
    local file
    koopa_activate_coreutils_aliases
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias R='R --no-restore --no-save --quiet'
    alias black='black --line-length=79'
    alias br-size='br --sort-by-size'
    alias br='koopa_alias_broot'
    alias bucket='koopa_alias_bucket'
    alias c='clear'
    alias cls='koopa_alias_colorls'
    alias d='clear; cd -; l'
    alias doom-emacs='koopa_alias_doom_emacs'
    alias e='exit'
    alias emacs-vanilla='koopa_alias_emacs_vanilla'
    alias emacs='koopa_alias_emacs'
    alias fd='fd --case-sensitive --no-ignore'
    alias fvim='vim "$(fzf)"'
    alias fzf='koopa_alias_fzf'
    alias h='history'
    alias j='z'
    alias k='koopa_alias_k'
    alias l.='l -d .*'
    alias l1='l -1'
    alias l='koopa_alias_l'
    alias la='l -a'
    alias lh='l | head'
    alias ll='la -l'
    alias lt='l | tail'
    alias mamba='koopa_alias_mamba'
    alias nvim-fzf='koopa_alias_nvim_fzf'
    alias nvim-vanilla='koopa_alias_nvim_vanilla'
    alias perlbrew='koopa_alias_perlbrew'
    alias prelude-emacs='koopa_alias_prelude_emacs'
    alias pyenv='koopa_alias_pyenv'
    alias python='python3'
    alias q='exit'
    alias rbenv='koopa_alias_rbenv'
    alias rg='rg --case-sensitive' # '--no-ignore'
    alias ronn='ronn --roff'
    alias sha256='koopa_alias_sha256'
    alias spacemacs='koopa_alias_spacemacs'
    alias spacevim='koopa_alias_spacevim'
    alias tmux-vanilla='koopa_alias_tmux_vanilla'
    alias today='koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias vim-fzf='koopa_alias_vim_fzf'
    alias vim-vanilla='koopa_alias_vim_vanilla'
    alias week='koopa_alias_week'
    alias z='koopa_alias_zoxide'
    # Keep these at the end to allow the user to override our defaults.
    file="${HOME:?}/.aliases"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    file="${HOME:?}/.aliases-private"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    return 0
}

koopa_activate_bat() { # {{{1
    # """
    # Activate bat configuration.
    # @note Updated 2022-03-28.
    #
    # Ensure this follows 'koopa_activate_color_mode'.
    # """
    local conf_file dotfiles_prefix
    dotfiles_prefix="$(koopa_dotfiles_prefix)"
    conf_file="${dotfiles_prefix}/app/bat/config"
    case "$(koopa_color_mode)" in
        'dark')
            conf_file="${conf_file}-dark"
            ;;
        'light')
            conf_file="${conf_file}-light"
            ;;
    esac
    [ -f "$conf_file" ] || return 0
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}

koopa_activate_bcbio_nextgen() { # {{{1
    # """
    # Activate bcbio-nextgen tool binaries.
    # @note Updated 2022-03-22.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    #
    # @seealso
    # - https://bcbio-nextgen.readthedocs.io/en/latest/contents/
    #     installation.html
    # """
    local prefix
    prefix="$(koopa_bcbio_nextgen_prefix)"
    [ -d "$prefix" ] || return 0
    # Only enable this when debugging.
    # > koopa_add_to_path_end "${prefix}/install/anaconda/bin"
    koopa_add_to_path_end "${prefix}/tools/bin"
    return 0
}

koopa_activate_broot() { # {{{1
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
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    config_dir="${HOME:?}/.config/broot"
    [ -d "$config_dir" ] || return 0
    # This is supported for Bash and Zsh.
    script="${config_dir}/launcher/bash/br"
    [ -f "$script" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_color_mode() { # {{{1
    # """
    # Activate dark / light color mode.
    # @note Updated 2022-04-13.
    # """
    if [ -z "${KOOPA_COLOR_MODE:-}" ]
    then
        KOOPA_COLOR_MODE="$(koopa_color_mode)"
    fi
    if [ -n "${KOOPA_COLOR_MODE:-}" ]
    then
        export KOOPA_COLOR_MODE
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}

koopa_activate_completion() { # {{{1
    # """
    # Activate completion (with TAB key).
    # @note Updated 2021-05-06.
    # """
    local file koopa_prefix shell
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    koopa_prefix="$(koopa_koopa_prefix)"
    for file in "${koopa_prefix}/etc/completion/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    return 0
}

koopa_activate_conda() { # {{{1
    # """
    # Activate conda using 'activate' script.
    # @note Updated 2022-02-02.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba/issues/984
    # """
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(koopa_conda_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_is_alias 'mamba' && unalias 'mamba'
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$script"
    # Ensure the base environment is deactivated by default.
    if [ "${CONDA_DEFAULT_ENV:-}" = 'base' ] && \
        [ "${CONDA_SHLVL:-0}" -eq 1 ]
    then
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -o nounset
    # Suppress mamba ASCII banner.
    [ -z "${MAMBA_NO_BANNER:-}" ] && export MAMBA_NO_BANNER=1
    return 0
}

koopa_activate_coreutils_aliases() { # {{{1
    # """
    # Activate BSD/GNU coreutils aliases.
    # @note Updated 2022-04-10.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS currently has issues on NFS shares.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    if [ ! -x "${bin_prefix}/cp" ] || \
        [ ! -x "${bin_prefix}/cp" ] || \
        [ ! -x "${bin_prefix}/ln" ] || \
        [ ! -x "${bin_prefix}/mkdir" ] || \
        [ ! -x "${bin_prefix}/mv" ] || \
        [ ! -x "${bin_prefix}/rm" ]
    then
        return 0
    fi
    local cp cp_args ln ln_args mkdir mkdir_args mv mv_args rm rm_args
    cp='cp'
    ln='ln'
    mkdir='mkdir'
    mv='mv'
    rm='rm'
    cp_args='-R -i' # '--interactive --recursive'.
    ln_args='-ins' # '--interactive --no-dereference --symbolic'.
    mkdir_args='-p' # '--parents'.
    mv_args='-i' # '--interactive'
    # Problematic on some file systems: '--dir', '--preserve-root'.
    # Don't enable '--recursive' here by default, to provide against
    # accidental deletion of an important directory.
    rm_args='-i' # '--interactive=once'.
    # shellcheck disable=SC2139
    alias cp="${cp} ${cp_args}"
    # shellcheck disable=SC2139
    alias ln="${ln} ${ln_args}"
    # shellcheck disable=SC2139
    alias mkdir="${mkdir} ${mkdir_args}"
    # shellcheck disable=SC2139
    alias mv="${mv} ${mv_args}"
    # shellcheck disable=SC2139
    alias rm="${rm} ${rm_args}"
    return 0
}

koopa_activate_dircolors() { # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2022-04-13.
    #
    # This will set the 'LS_COLORS' environment variable.
    #
    # Ensure this follows 'koopa_activate_color_mode'.
    # """
    local bin_prefix
    [ -n "${SHELL:-}" ] || return 0
    bin_prefix="$(koopa_bin_prefix)"
    [ -x "${bin_prefix}/dircolors" ] || return 0
    local dir dircolors dircolors_file dotfiles_prefix egrep fgrep grep ls vdir
    dir='dir'
    dircolors='dircolors'
    egrep='egrep'
    fgrep='fgrep'
    grep='grep'
    ls='ls'
    vdir='vdir'
    dotfiles_prefix="$(koopa_dotfiles_prefix)"
    dircolors_file="${dotfiles_prefix}/app/coreutils/dircolors"
    case "$(koopa_color_mode)" in
        'dark')
            dircolors_file="${dircolors_file}-dark"
            ;;
        'light')
            dircolors_file="${dircolors_file}-light"
            ;;
    esac
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
    # shellcheck disable=SC2032,SC2139
    alias ls="${ls} --color=auto"
    # shellcheck disable=SC2139
    alias vdir="${vdir} --color=auto"
    return 0
}

koopa_activate_fzf() { # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2021-06-02.
    #
    # Currently Bash and Zsh are supported.
    # Shell lockout has been observed on Ubuntu unless we disable 'set -e'.
    # """
    local fzfrc nounset prefix script shell
    fzfrc="$(koopa_dotfiles_prefix)/app/fzf/fzfrc"
    # shellcheck source=/dev/null
    [ -f "$fzfrc" ] && . "$fzfrc"
    prefix="$(koopa_fzf_prefix)"
    [ -d "$prefix" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    shell="$(koopa_shell_name)"
    # Relax hardened shell temporarily, if necessary.
    if [ "$nounset" -eq 1 ]
    then
        set +o errexit
        set +o nounset
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
        set -o errexit
        set -o nounset
    fi
    return 0
}

koopa_activate_gcc_colors() { # {{{1
    # """
    # Activate GCC colors.
    # @note Updated 2020-06-30.
    # @seealso
    # - https://gcc.gnu.org/onlinedocs/gcc-10.1.0/gcc/
    #     Diagnostic-Message-Formatting-Options.html
    # """
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

koopa_activate_go() { # {{{1
    # """
    # Activate Go.
    # @note Updated 2022-03-30.
    # """
    local prefix
    prefix="$(koopa_go_packages_prefix)"
    [ -d "$prefix" ] || return 0
    GOPATH="$(koopa_go_packages_prefix)"
    export GOPATH
    return 0
}

koopa_activate_homebrew() { # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2022-04-10.
    #
    # Don't activate 'binutils' here. Can mess up R package compilation.
    # """
    local prefix
    prefix="$(koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_PREFIX="$prefix"
    if koopa_is_macos
    then
        export HOMEBREW_CASK_OPTS='--no-binaries --no-quarantine'
    fi
    return 0
}

koopa_activate_julia() { # {{{1
    # """
    # Activate Julia.
    # @note Updated 2022-03-31.
    # """
    local prefix
    prefix="$(koopa_julia_packages_prefix)"
    if [ -d "$prefix" ]
    then
        export JULIA_DEPOT_PATH="$prefix"
    fi
    return 0
}

koopa_activate_lesspipe() { # {{{1
    # """
    # Activate lesspipe.
    # @note Updated 2022-03-01.
    #
    # Preferentially uses 'bat' when installed.
    #
    # @seealso
    # - man lesspipe
    # - https://github.com/wofr06/lesspipe/
    # - https://manned.org/lesspipe/
    # - https://superuser.com/questions/117841/
    # - brew info lesspipe
    # - To list available styles (requires pygments):
    #   'pygmentize -L styles'
    # """
    koopa_is_installed 'lesspipe.sh' || return 0
    export LESS='-R'
    export LESSCOLOR='yes'
    export LESSOPEN='|lesspipe.sh %s'
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    [ -z "${LESSCHARSET:-}" ] && export LESSCHARSET='utf-8'
    return 0
}

koopa_activate_make_paths() { # {{{1
    # """
    # Activate standard Makefile paths.
    # @note Updated 2022-04-08.
    #
    # Note that here we're making sure local binaries are included.
    # Inspect '/etc/profile' if system PATH appears misconfigured.
    #
    # Note that macOS Big Sur includes '/usr/local/bin' automatically now,
    # resulting in a duplication. This is OK.
    # Refer to '/etc/paths.d' for other system paths.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    # """
    local make_prefix_1 make_prefix_2
    make_prefix_1='/usr/local'
    make_prefix_2="$(koopa_make_prefix)"
    if [ -d "$make_prefix_1" ]
    then
        koopa_add_to_path_start \
            "${make_prefix_1}/bin" \
            "${make_prefix_1}/sbin"
        koopa_add_to_manpath_start \
            "${make_prefix_1}/man" \
            "${make_prefix_1}/share/man"
    fi
    if [ "$make_prefix_2" != "$make_prefix_1" ] && [ -d "$make_prefix_2" ]
    then
        koopa_add_to_path_start \
            "${make_prefix_2}/bin" \
            "${make_prefix_2}/sbin"
        koopa_add_to_manpath_start \
            "${make_prefix_2}/man" \
            "${make_prefix_2}/share/man"
    fi
    return 0
}

koopa_activate_mcfly() { #{{{1
    # """
    # Activate mcfly.
    # @note Updated 2022-02-01.
    #
    # Use "mcfly search 'query'" to query directly.
    # """
    local nounset shell
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    koopa_is_root && return 0
    koopa_is_installed 'mcfly' || return 1
    shell="$(koopa_shell_name)"
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
    export MCFLY_FUZZY=2
    export MCFLY_HISTORY_LIMIT=10000
    export MCFLY_INTERFACE_VIEW='TOP' # or 'BOTTOM'
    export MCFLY_KEY_SCHEME='vim'
    export MCFLY_RESULTS=50
    export MCFLY_RESULTS_SORT='RANK' # or 'LAST_RUN'
    if koopa_is_macos
    then
        if koopa_macos_is_light_mode
        then
            export MCFLY_LIGHT=true
        fi
    fi
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$(mcfly init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_nextflow() { # {{{1
    # """
    # Activate Nextflow configuration.
    # @note Updated 2020-07-21.
    # @seealso
    # - https://github.com/nf-core/smrnaseq/blob/master/docs/usage.md
    # """
    [ -z "${NXF_OPTS:-}" ] || return 0
    export NXF_OPTS='-Xms1g -Xmx4g'
    return 0
}

koopa_activate_nim() { # {{{1
    # """
    # Activate Nim.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_nim_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NIMBLE_DIR="$prefix"
    return 0
}

koopa_activate_node() { # {{{1
    # """
    # Activate Node.js (and NPM).
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_node_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NPM_CONFIG_PREFIX="$prefix"
    return 0
}

koopa_activate_path_helper() { # {{{1
    # """
    # Activate 'path_helper'.
    # @note Updated 2022-04-13.
    #
    # This will source '/etc/paths.d' on supported platforms (e.g. BSD/macOS).
    [ -x '/usr/libexec/path_helper' ] || return 0
    eval "$('/usr/libexec/path_helper' -s)"
    return 0
}

koopa_activate_perl() { # {{{1
    # """
    # Activate Perl, adding local library to 'PATH'.
    # @note Updated 2022-04-08.
    #
    # No longer querying Perl directly here, to speed up shell activation
    # (see commented legacy approach below).
    #
    # The legacy Perl eval approach may error/warn if new shell is activated
    # while Perl packages are installing.
    #
    # @seealso
    # - brew info perl
    # """
    local prefix
    prefix="$(koopa_perl_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export PERL5LIB="${prefix}/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$prefix"
    export PERL_MB_OPT="--install_base '${prefix}'"
    export PERL_MM_OPT="INSTALL_BASE=${prefix}"
    export PERL_MM_USE_DEFAULT=1
    return 0
}

koopa_activate_perlbrew() { # {{{1
    # """
    # Activate Perlbrew.
    # @note Updated 2022-04-04.
    #
    # Only attempt to autoload for bash or zsh.
    # Delete '~/.perlbrew' directory if you see errors at login.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    local nounset prefix script shell
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    prefix="$(koopa_perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_pipx() { # {{{1
    # """
    # Activate pipx for Python.
    # @note Updated 2022-03-30.
    #
    # Customize pipx location with environment variables.
    # https://pipxproject.github.io/pipx/installation/
    # """
    local prefix
    prefix="$(koopa_pipx_prefix)"
    [ -d "$prefix" ] || return 0
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}

koopa_activate_prefix() { # {{{1
    # """
    # Automatically configure 'PATH' and 'MANPATH' for a
    # specified prefix.
    # @note Updated 2022-04-11.
    # """
    local prefix
    for prefix in "$@"
    do
        [ -d "$prefix" ] || continue
        koopa_add_to_path_start \
            "${prefix}/bin" \
            "${prefix}/sbin"
        koopa_add_to_manpath_start \
            "${prefix}/man" \
            "${prefix}/share/man"
    done
    return 0
}

koopa_activate_pyenv() { # {{{1
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2022-04-08.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    local nounset prefix script
    [ -n "${PYENV_ROOT:-}" ] && return 0
    prefix="$(koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_python() { # {{{1
    # """
    # Activate Python, including custom installed packages.
    # @note Updated 2022-04-19.
    #
    # Configures:
    # - Site packages library.
    # - Custom startup file, defined in our 'dotfiles' repo.
    #
    # This ensures that 'bin' will be added to PATH, which is useful when
    # installing via pip with '--target' flag.
    #
    # Check path configuration with:
    # > python3 -c "import sys; print('\n'.join(sys.path))"
    #
    # Check which pip with:
    # > python3 -m pip show pip
    #
    # @seealso
    # - https://docs.python.org/3/tutorial/modules.html#the-module-search-path
    # - https://stackoverflow.com/questions/33683744/
    # - https://twitter.com/sadhlife/status/1450459992419622920
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # """
    local startup_file
    startup_file="${HOME:?}/.pyrc"
    # > local prefix prefix_real
    # > prefix="$(koopa_python_packages_prefix)"
    # > if [ -d "$prefix" ]
    # > then
    # >     prefix_real="$(koopa_realpath "$prefix")"
    # >     koopa_add_to_pythonpath_start "$prefix_real"
    # > fi
    if [ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [ -z "${PYTHONDONTWRITEBYTECODE:-}" ]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    if [ -z "${PYTHONSTARTUP:-}" ] && [ -f "$startup_file" ]
    then
        export PYTHONSTARTUP="$startup_file"
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

koopa_activate_rbenv() { # {{{1
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2022-04-08.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    # """
    local nounset prefix script
    [ -n "${RBENV_ROOT:-}" ] && return 0
    prefix="$(koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_ruby() { # {{{1
    # """
    # Activate Ruby gems.
    # @note Updated 2022-04-04.
    # """
    local prefix
    prefix="$(koopa_ruby_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export GEM_HOME="$prefix"
    return 0
}

koopa_activate_secrets() { # {{{1
    # """
    # Source secrets file.
    # @note Updated 2020-07-07.
    # """
    local file
    file="${1:-}"
    [ -z "$file" ] && file="${HOME:?}/.secrets"
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

koopa_activate_ssh_key() { # {{{1
    # """
    # Import an SSH key automatically.
    # @note Updated 2021-05-26.
    #
    # NOTE: SCP will fail unless this is interactive only.
    # ssh-agent will prompt for password if there's one set.
    #
    # To change SSH key passphrase:
    # > ssh-keygen -p
    #
    # List currently loaded keys:
    # > ssh-add -L
    # """
    local key
    koopa_is_linux || return 0
    key="${1:-}"
    if [ -z "$key" ] && [ -n "${SSH_KEY:-}" ]
    then
        key="$SSH_KEY"
    else
        key="${HOME:?}/.ssh/id_rsa"
    fi
    [ -r "$key" ] || return 0
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$key" >/dev/null 2>&1
    return 0
}

koopa_activate_starship() { # {{{1
    # """
    # Activate starship prompt.
    # @note Updated 2022-04-04.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    local nounset shell
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    koopa_is_installed 'starship' || return 0
    unset -v STARSHIP_SESSION_KEY STARSHIP_SHELL
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && return 0
    eval "$(starship init "$shell")"
    return 0
}

koopa_activate_tealdeer() { # {{{1
    # """
    # Activate Rust tealdeer (tldr).
    # @note Updated 2022-02-15.
    #
    # This helps standardization the configuration across Linux and macOS.
    # """
    koopa_is_installed 'tldr' || return 0
    if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    then
        TEALDEER_CACHE_DIR="$(koopa_xdg_cache_home)/tealdeer"
    fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="$(koopa_xdg_config_home)/tealdeer"
    fi
    if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    then
        mkdir -p "${TEALDEER_CACHE_DIR:?}"
    fi
    export TEALDEER_CACHE_DIR TEALDEER_CONFIG_DIR
    return 0
}

koopa_activate_today_bucket() { # {{{1
    # """
    # Create a dated file today bucket.
    # @note Updated 2022-04-10.
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
    local bucket_dir today_bucket today_link
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    [ -d "$bucket_dir" ] || return 0
    today_bucket="$(date '+%Y/%m/%d')"
    today_link="${HOME:?}/today"
    # Early return if we've already updated the symlink.
    if koopa_str_detect_posix \
        "$(koopa_realpath "$today_link")" \
        "$today_bucket"
    then
        return 0
    fi
    mkdir -p "${bucket_dir}/${today_bucket}"
    ln -fns "${bucket_dir}/${today_bucket}" "$today_link"
    return 0
}

koopa_activate_xdg() { # {{{1
    # """
    # Activate XDG base directory specification.
    # @note Updated 2022-04-04.
    #
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://specifications.freedesktop.org/basedir-spec/
    #     basedir-spec-latest.html#variables
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # - https://unix.stackexchange.com/questions/476963/
    # """
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="$(koopa_xdg_cache_home)"
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="$(koopa_xdg_config_dirs)"
    fi
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="$(koopa_xdg_config_home)"
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="$(koopa_xdg_data_dirs)"
    fi
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="$(koopa_xdg_data_home)"
    fi
    export XDG_CACHE_HOME XDG_CONFIG_DIRS XDG_CONFIG_HOME \
        XDG_DATA_DIRS XDG_DATA_HOME
    return 0
}

koopa_activate_zoxide() { # {{{1
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
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    koopa_is_installed 'zoxide' || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$(zoxide init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_add_koopa_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2022-04-10.
    # """
    local config_prefix dest_file dest_name source_file
    config_prefix="$(koopa_config_prefix)"
    while [ "$#" -ge 2 ]
    do
        source_file="${1:?}"
        dest_name="${2:?}"
        shift 2
        dest_file="${config_prefix}/${dest_name}"
        if [ -L "$dest_file" ] && [ -e "$dest_file" ]
        then
            continue
        fi
        mkdir -p "$config_prefix"
        rm -fr "$dest_file"
        ln -s "$source_file" "$dest_file"
    done
    return 0
}

koopa_add_to_fpath_end() { # {{{1
    # """
    # Force add to 'FPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(__koopa_add_to_path_string_end "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

koopa_add_to_fpath_start() { # {{{1
    # """
    # Force add to 'FPATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(__koopa_add_to_path_string_start "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

koopa_add_to_manpath_end() { # {{{1
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

koopa_add_to_manpath_start() { # {{{1
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - /etc/manpath.config
    # """
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_start "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

koopa_add_to_path_end() { # {{{1
    # """
    # Force add to 'PATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_end "$PATH" "$dir")"
    done
    export PATH
    return 0
}

koopa_add_to_path_start() { # {{{1
    # """
    # Force add to 'PATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

koopa_add_to_pythonpath_end() { # {{{1
    # """
    # Force add to 'PYTHONPATH' end.
    # @note Updated 2022-03-11.
    # """
    local dir
    PYTHONPATH="${PYTHONPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PYTHONPATH="$(__koopa_add_to_path_string_end "$PYTHONPATH" "$dir")"
    done
    export PYTHONPATH
    return 0
}

koopa_add_to_pythonpath_start() { # {{{1
    # """
    # Force add to 'PYTHONPATH' start.
    # @note Updated 2022-03-11.
    # """
    local dir
    PYTHONPATH="${PYTHONPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PYTHONPATH="$(__koopa_add_to_path_string_start "$PYTHONPATH" "$dir")"
    done
    export PYTHONPATH
    return 0
}

koopa_alias_broot() { # {{{1
    # """
    # Broot 'br' alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'br' && unalias 'br'
    koopa_activate_broot
    br "$@"
}

koopa_alias_bucket() { # {{{1
    # """
    # Today bucket alias.
    # @note Updated 2021-06-08.
    # """
    local prefix
    prefix="${HOME:?}/today"
    [ -d "$prefix" ] || return 1
    cd "$prefix" || return 1
    ls
}

koopa_alias_colorls() { # {{{1
    # """
    # colorls alias.
    # @note Updated 2022-04-14.
    #
    # Use of '--git-status' is slow for large directories / monorepos.
    # """
    local color_flag color_mode
    color_mode="$(koopa_color_mode)"
    case "$color_mode" in
        'dark')
            color_flag='--dark'
            ;;
        'light')
            color_flag='--light'
            ;;
    esac
    colorls \
        "$color_flag" \
        --group-directories-first \
            "$@"
    return 0
}

koopa_alias_conda() { # {{{1
    # """
    # Conda alias.
    # @note Updated 2022-02-02.
    # """
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_activate_conda
    conda "$@"
}

koopa_alias_doom_emacs() { # {{{1
    # """
    # Doom Emacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'doom' "$@"
}

koopa_alias_emacs() { # {{{1
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="${HOME:?}/.emacs.d"
    [ -f "${prefix}/chemacs.el" ] || return 1
    if [ -f "${HOME:?}/.terminfo/78/xterm-24bit" ] && koopa_is_macos
    then
        TERM='xterm-24bit' emacs --no-window-system "$@"
    else
        emacs --no-window-system "$@"
    fi
}

koopa_alias_emacs_vanilla() { # {{{1
    # """
    # Vanilla Emacs alias.
    # @note Updated 2022-04-07.
    # """
    emacs --no-init-file --no-window-system "$@"
}

koopa_alias_fzf() { # {{{1
    # """
    # FZF alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'fzf' && unalias 'fzf'
    koopa_activate_fzf
    fzf "$@"
}

koopa_alias_k() { # {{{1
    # """
    # Koopa 'k' shortcut alias.
    # @note Updated 2021-06-08.
    # """
    cd "$(koopa_koopa_prefix)" || return 1
}

koopa_alias_l() { # {{{1
    # """
    # List files alias that uses 'exa' instead of 'ls', when possible.
    # @note Updated 2022-04-14.
    #
    # Use exa instead of ls, when possible.
    # https://the.exa.website/docs/command-line-options
    #
    # @secton Useful exa flags:
    # * -F, --classify
    #         Displays file type indicators by file names.
    # * -a, --all
    #         Shows hidden and ‘dot’ files.
    #         Use this twice to also show the . and .. directories.
    # * -g, --group
    #         Lists each file’s group.
    # * -l, --long
    #         Displays files in a table along with their metadata.
    # * -s, --sort=SORT_FIELD
    #         Configures which field to sort by.
    # *     --git-ignore
    #         Ignores files mentioned in .gitignore.
    # *     --group-directories-first
    #         Lists directories before other files when sorting.
    # @section Useful ls flags:
    # * -B, --ignore-backups
    #         do not list implied entries ending with ~
    # * -F, --classify
    #         append indicator (one of */=>@|) to entries
    # * -h, --human-readable
    #         with -l and -s, print sizes like 1K 234M 2G etc.
    # """
    if koopa_is_installed 'exa'
    then
        exa \
            --classify \
            --group \
            --group-directories-first \
            --sort='Name' \
            "$@"
    else
        ls -BFh "$@"
    fi
}

koopa_alias_mamba() { # {{{1
    # """
    # Mamba alias.
    # @note Updated 2022-01-21.
    # """
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_is_alias 'mamba' && unalias 'mamba'
    koopa_activate_conda
    mamba "$@"
}

koopa_alias_nvim_fzf() { # {{{1
    # """
    # Pipe FZF output to Neovim.
    # @note Updated 2022-04-08.
    # """
    nvim "$(fzf)"
}

koopa_alias_nvim_vanilla() { # {{{1
    # """
    # Vanilla Neovim.
    # @note Updated 2022-04-08.
    # """
    nvim -u 'NONE' "$@"
}

koopa_alias_perlbrew() { # {{{1
    # """
    # Perlbrew alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'perlbrew' && unalias 'perlbrew'
    koopa_activate_perlbrew
    perlbrew "$@"
}

koopa_alias_prelude_emacs() { # {{{1
    # """
    # Prelude Emacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_prelude_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'prelude' "$@"
}

koopa_alias_pyenv() { # {{{1
    # """
    # pyenv alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'pyenv' && unalias 'pyenv'
    koopa_activate_pyenv
    pyenv "$@"
}

koopa_alias_rbenv() { # {{{1
    # """
    # rbenv alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'rbenv' && unalias 'rbenv'
    koopa_activate_rbenv
    rbenv "$@"
}

koopa_alias_sha256() { # {{{1
    # """
    # sha256 alias.
    # @note Updated 2021-06-08.
    # """
    koopa_is_installed 'shasum' || return 1
    shasum -a 256 "$@"
}

koopa_alias_spacemacs() { # {{{1
    # """
    # Spacemacs.
    # @note Updated 2022-04-08.
    # """
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'spacemacs' "$@"
}

koopa_alias_spacevim() { # {{{1
    # """
    # SpaceVim alias.
    # @note Updated 2022-04-08.
    # """
    local gvim prefix vim vimrc
    vim='vim'
    if koopa_is_macos
    then
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        if [ -x "$gvim" ]
        then
            vim="$gvim"
        fi
    fi
    prefix="$(koopa_spacevim_prefix)"
    vimrc="${prefix}/vimrc"
    [ -f "$vimrc" ] || return 1
    koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
}

koopa_alias_tmux_vanilla() { # {{{1
    # """
    # Vanilla tmux.
    # @note Updated 2022-04-13.
    # """
    tmux -f '/dev/null'
}

koopa_alias_today() { # {{{1
    # """
    # Today alias.
    # @note Updated 2021-06-08.
    # """
    date '+%Y-%m-%d'
}

koopa_alias_vim_fzf() { # {{{1
    # """
    # Pipe FZF output to Vim.
    # @note Updated 2021-06-08.
    # """
    vim "$(fzf)"
}

koopa_alias_vim_vanilla() { # {{{1
    # """
    # Vanilla Vim.
    # @note Updated 2022-04-08.
    # """
    vim -i 'NONE' -u 'NONE' -U 'NONE' "$@"
}

koopa_alias_week() { # {{{1
    # """
    # Numerical week alias.
    # @note Updated 2021-06-08.
    # """
    date '+%V'
}

koopa_alias_zoxide() { # {{{1
    # """
    # Zoxide alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'z' && unalias 'z'
    koopa_activate_zoxide
    z "$@"
}

koopa_anaconda_prefix() { # {{{1
    # """
    # Anaconda prefix.
    # @note Updated 2021-10-26.
    # """
    koopa_print "$(koopa_opt_prefix)/anaconda"
    return 0
}

koopa_app_prefix() { # {{{1
    # """
    # Application prefix.
    # @note Updated 2021-06-11.
    # """
    koopa_print "$(koopa_koopa_prefix)/app"
    return 0
}

koopa_arch() { # {{{1
    # """
    # Platform architecture.
    # @note Updated 2022-01-21.
    #
    # e.g. Intel: x86_64; ARM: aarch64.
    # """
    local x
    x="$(uname -m)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_aspera_connect_prefix() { # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2021-02-27.
    # """
    koopa_print "$(koopa_opt_prefix)/aspera-connect"
    return 0
}

koopa_bcbio_nextgen_prefix() { # {{{1
    # """
    # bcbio-nextgen tools prefix.
    # @note Updated 2022-03-22.
    # """
    koopa_print "$(koopa_opt_prefix)/bcbio-nextgen"
    return 0
}

koopa_bin_prefix() { # {{{1
    # """
    # Koopa binary prefix.
    # @note Updated 2022-04-04.
    # """
    koopa_print "$(koopa_koopa_prefix)/bin"
    return 0
}

koopa_boolean_nounset() { # {{{1
    # """
    # Return 0 (false) / 1 (true) boolean whether nounset mode is enabled.
    # @note Updated 2020-07-05.
    #
    # Intended for [ "$x" -eq 1 ] (true) checks.
    #
    # This approach is the opposite of POSIX shell status codes, where 0 is
    # true and 1 is false.
    # """
    local bool
    if koopa_is_set_nounset
    then
        bool=1
    else
        bool=0
    fi
    koopa_print "$bool"
    return 0
}

koopa_color_mode() { # {{{1
    # """
    # macOS color mode (dark/light) value.
    # @note Updated 2022-04-13.
    # """
    local str
    str="${KOOPA_COLOR_MODE:-}"
    if [ -n "$str" ]
    then
        koopa_print "$str"
        return 0
    fi
    if [ -z "$str" ]
    then
        if koopa_is_macos
        then
            if koopa_macos_is_dark_mode
            then
                str='dark'
            else
                str='light'
            fi
        fi
    fi
    [ -n "$str" ] || return 0
    # Optionally, here's how to write the config to a file:
    # > local conf_file
    # > conf_file="$(koopa_config_prefix)/color-mode"
    # > koopa_print "$str" > "$conf_file"
    koopa_print "$str"
    return 0
}

koopa_conda_env_name() { # {{{1
    # """
    # Conda environment name.
    # @note Updated 2020-08-17.
    #
    # Alternate approach:
    # > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
    # > export CONDA_PROMPT_MODIFIER
    # > conda="$CONDA_PROMPT_MODIFIER"
    #
    # See also:
    # - https://stackoverflow.com/questions/42481726
    # """
    local x
    x="${CONDA_DEFAULT_ENV:-}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_conda_prefix() { # {{{1
    # """
    # Conda prefix.
    # @note Updated 2021-05-25.
    # @seealso conda info --base
    # """
    koopa_print "$(koopa_opt_prefix)/conda"
    return 0
}

koopa_config_prefix() { # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    koopa_print "$(koopa_xdg_config_home)/koopa"
    return 0
}

koopa_debian_os_codename() { # {{{1
    # """
    # Debian operating system codename.
    # @note Updated 2021-06-02.
    # """
    local x
    koopa_is_installed 'lsb_release' || return 0
    x="$(lsb_release -cs)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_distro_prefix() { # {{{1
    # """
    # Operating system distro prefix.
    # @note Updated 2022-01-27.
    # """
    local koopa_prefix os_id prefix
    koopa_prefix="$(koopa_koopa_prefix)"
    os_id="$(koopa_os_id)"
    if koopa_is_linux
    then
        prefix="${koopa_prefix}/os/linux/${os_id}"
    else
        prefix="${koopa_prefix}/os/${os_id}"
    fi
    koopa_print "$prefix"
    return 0
}

koopa_docker_prefix() { # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/docker"
    return 0
}

koopa_docker_private_prefix() { # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    koopa_print "$(koopa_config_prefix)/docker-private"
    return 0
}

koopa_doom_emacs_prefix() { # {{{1
    # """
    # Doom Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/doom"
    return 0
}

koopa_dotfiles_prefix() { # {{{1
    # """
    # Dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    koopa_print "$(koopa_opt_prefix)/dotfiles"
    return 0
}

koopa_dotfiles_private_prefix() { # {{{1
    # """
    # Private dotfiles prefix.
    # @note Updated 2021-11-24.
    # """
    koopa_print "$(koopa_config_prefix)/dotfiles-private"
    return 0
}

koopa_duration_start() { # {{{1
    # """
    # Start activation duration timer.
    # @note Updated 2022-04-10.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    [ -x "${bin_prefix}/date" ] || return 0
    KOOPA_DURATION_START="$(date -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

koopa_duration_stop() { # {{{1
    # """
    # Stop activation duration timer.
    # @note Updated 2022-04-10.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    if [ ! -x "${bin_prefix}/bc" ] || \
        [ ! -x "${bin_prefix}/date" ]
    then
        return 0
    fi
    local duration key start stop
    key="${1:-}"
    if [ -z "$key" ]
    then
        key='duration'
    else
        key="[${key}] duration"
    fi
    start="${KOOPA_DURATION_START:?}"
    stop="$(date -u '+%s%3N')"
    duration="$(koopa_print "${stop}-${start}" | bc)"
    [ -n "$duration" ] || return 1
    koopa_dl "$key" "${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

koopa_emacs_prefix() { # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    koopa_print "${HOME:?}/.emacs.d"
    return 0
}

koopa_ensembl_perl_api_prefix() { # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2021-05-04.
    # """
    koopa_print "$(koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

koopa_export_editor() { # {{{1
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2021-05-07.
    # """
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR='vim'
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

koopa_export_git() { # {{{1
    # """
    # Export git configuration.
    # @note Updated 2021-05-14.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        GIT_MERGE_AUTOEDIT='no'
    fi
    export GIT_MERGE_AUTOEDIT
    return 0
}

koopa_export_gnupg() { # {{{1
    # """
    # Export GnuPG settings.
    # @note Updated 2022-04-08.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    [ -z "${GPG_TTY:-}" ] || return 0
    koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}

koopa_export_history() { # {{{1
    # """
    # Export history.
    # @note Updated 2021-01-31.
    #
    # See bash(1) for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    local shell
    shell="$(koopa_shell_name)"
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.${shell}_history"
    fi
    export HISTFILE
    # Create the history file, if necessary.
    # Note that the HOME check here hardens against symlinked data disk failure.
    if [ ! -f "$HISTFILE" ] \
        && [ -e "${HOME:-}" ] \
        && koopa_is_installed 'touch'
    then
        touch "$HISTFILE"
    fi
    # Don't keep duplicate lines in the history.
    # Alternatively, set 'ignoreboth' to also ignore lines starting with space.
    if [ -z "${HISTCONTROL:-}" ]
    then
        HISTCONTROL='ignoredups'
    fi
    export HISTCONTROL
    if [ -z "${HISTIGNORE:-}" ]
    then
        HISTIGNORE='&:ls:[bf]g:exit'
    fi
    export HISTIGNORE
    # Set the default history size.
    if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
    then
        HISTSIZE=1000
    fi
    export HISTSIZE
    # Add the date/time to 'history' command output.
    # Note that on macOS Bash will fail if 'set -e' is set.
    if [ -z "${HISTTIMEFORMAT:-}" ]
    then
        HISTTIMEFORMAT='%Y%m%d %T  '
    fi
    export HISTTIMEFORMAT
    # Ensure that HISTSIZE and SAVEHIST values match.
    if [ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]
    then
        SAVEHIST="$HISTSIZE"
    fi
    export SAVEHIST
    return 0
}

koopa_export_koopa_shell() { # {{{1
    # """
    # Export 'KOOPA_SHELL' variable.
    # @note Updated 2022-02-02.
    # """
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(koopa_locate_shell)"
    export KOOPA_SHELL
    return 0
}

koopa_export_pager() { # {{{1
    # """
    # Export 'PAGER' variable.
    # @note Updated 2022-01-18.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    [ -n "${PAGER:-}" ] && return 0
    if koopa_is_installed 'less'
    then
        export PAGER='less -R'
    fi
    return 0
}

koopa_expr() { # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

koopa_fzf_prefix() { # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/fzf"
    return 0
}

koopa_git_branch() { # {{{1
    # """
    # Current git branch name.
    # @note Updated 2022-02-23.
    #
    # Currently used in prompt, so be careful with assert checks.
    #
    # Correctly handles detached HEAD state.
    #
    # Approaches:
    # > git branch --show-current
    # > git name-rev --name-only 'HEAD'
    # > git rev-parse --abbrev-ref 'HEAD'
    # > git symbolic-ref --short -q 'HEAD'
    #
    # @seealso
    # - https://stackoverflow.com/questions/6245570/
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    local branch
    koopa_is_git_repo || return 0
    branch="$(git branch --show-current 2>/dev/null)"
    # Keep track of detached HEAD state, similar to starship.
    if [ -z "$branch" ]
    then
        branch="$( \
            git branch 2>/dev/null \
            | head -n 1 \
            | cut -c '3-' \
        )"
    fi
    [ -n "$branch" ] || return 0
    koopa_print "$branch"
    return 0
}

koopa_git_repo_has_unstaged_changes() { # {{{1
    # """
    # Are there unstaged changes in current git repo?
    # @note Updated 2021-08-19.
    #
    # Don't use '--quiet' flag here, as it can cause shell to exit if 'set -e'
    # mode is enabled.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624/
    # - https://stackoverflow.com/questions/28296130/
    # """
    local x
    git update-index --refresh >/dev/null 2>&1
    x="$(git diff-index 'HEAD' -- 2>/dev/null)"
    [ -n "$x" ]
}

koopa_git_repo_needs_pull_or_push() { # {{{1
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2021-08-19.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local rev_1 rev_2
    rev_1="$(git rev-parse 'HEAD' 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}

koopa_go_packages_prefix() { # {{{1
    # """
    # Go packages 'GOPATH', for building from source.
    # @note Updated 2021-06-11.
    #
    # This must be different from 'go root' value.
    #
    # @usage koopa_go_packages_prefix [VERSION]
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    __koopa_packages_prefix 'go' "$@"
}

koopa_go_prefix() { # {{{1
    # """
    # Go prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/go"
    return 0
}

koopa_group() { # {{{1
    # """
    # Current user's default group.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -gn
    return 0
}

koopa_group_id() { # {{{1
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -g
    return 0
}

koopa_homebrew_cellar_prefix() { # {{{1
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    koopa_print "$(koopa_homebrew_prefix)/Cellar"
    return 0
}

koopa_homebrew_cask_prefix() { # {{{1
    # """
    # Homebrew cask prefix.
    # @note Updated 2022-04-04.
    # """
    koopa_print "$(koopa_homebrew_prefix)/Caskroom"
    return 0
}

koopa_homebrew_prefix() { # {{{1
    # """
    # Homebrew prefix.
    # @note Updated 2022-04-07.
    #
    # @seealso https://brew.sh/
    # """
    local arch x
    x="${HOMEBREW_PREFIX:-}"
    if [ -z "$x" ]
    then
        if koopa_is_installed 'brew'
        then
            x="$(brew --prefix)"
        elif koopa_is_macos
        then
            arch="$(koopa_arch)"
            case "$arch" in
                'arm'*)
                    x='/opt/homebrew'
                    ;;
                'x86'*)
                    x='/usr/local'
                    ;;
            esac
        elif koopa_is_linux
        then
            x='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -d "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_homebrew_opt_prefix() { # {{{1
    # """
    # Homebrew opt prefix.
    # @note Updated 2022-04-04.
    # """
    koopa_print "$(koopa_homebrew_prefix)/opt"
    return 0
}

koopa_hostname() { # {{{1
    # """
    # Host name.
    # @note Updated 2022-01-21.
    # """
    local x
    x="$(uname -n)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_host_id() { # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2022-01-20.
    #
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: aws, azure.
    # - HPCs: harvard-o2, harvard-odyssey.
    #
    # Returns empty for local machines and/or unsupported types.
    #
    # Alternatively, can use 'hostname -d' for reverse lookups.
    # """
    local id
    if [ -r '/etc/hostname' ]
    then
        id="$(cat '/etc/hostname')"
    elif koopa_is_installed 'hostname'
    then
        id="$(hostname -f)"
    else
        return 0
    fi
    case "$id" in
        # VMs {{{2
        # ----------------------------------------------------------------------
        *'.ec2.internal')
            id='aws'
            ;;
        # HPCs {{{2
        # ----------------------------------------------------------------------
        *'.o2.rc.hms.harvard.edu')
            id='harvard-o2'
            ;;
        *'.rc.fas.harvard.edu')
            id='harvard-odyssey'
            ;;
    esac
    [ -n "$id" ] || return 1
    koopa_print "$id"
    return 0
}

koopa_include_prefix() { # {{{1
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-07-30.
    # """
    koopa_print "$(koopa_koopa_prefix)/include"
    return 0
}

koopa_is_aarch64() { # {{{1
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "arm64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'aarch64' ]
}

koopa_is_alias() { # {{{1
    # """
    # Is the specified argument an alias?
    # @note Updated 2022-01-10.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # > koopa_is_alias 'R'
    # """
    local cmd str
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        # Bash convention.
        koopa_str_detect_posix "$str" ' is aliased to ' && continue
        # Zsh convention.
        koopa_str_detect_posix "$str" ' is an alias for ' && continue
        return 1
    done
    return 0
}

koopa_is_alpine() { # {{{1
    # """
    # Is the operating system Alpine Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'alpine'
}

koopa_is_amzn() { # {{{1
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'amzn'
}

koopa_is_arch() { # {{{1
    # """
    # Is the operating system Arch Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'arch'
}

koopa_is_aws() { # {{{1
    # """
    # Is the current session running on AWS?
    # @note Updated 2020-08-06.
    # """
    koopa_is_host 'aws'
}

koopa_is_azure() { # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2020-08-06.
    # """
    koopa_is_host 'azure'
}

koopa_is_centos() { # {{{1
    # """
    # Is the operating system CentOS?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'centos'
}

koopa_is_centos_like() { # {{{1
    # """
    # Is the operating system CentOS-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'centos'
}

koopa_is_conda_active() { # {{{1
    # """
    # Is there a Conda environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

koopa_is_conda_env_active() { # {{{1
    # """
    # Is a Conda environment (other than base) active?
    # @note Updated 2021-08-17.
    # """
    [ "${CONDA_SHLVL:-1}" -gt 1 ] && return 0
    [ "${CONDA_DEFAULT_ENV:-base}" != 'base' ] && return 0
    return 1
}

koopa_is_debian() { # {{{1
    # """
    # Is the operating system Debian?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'debian'
}

koopa_is_debian_like() { # {{{1
    # """
    # Is the operating system Debian-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'debian'
}

koopa_is_docker() { # {{{1
    # """
    # Is the current session running inside Docker?
    # @note Updated 2022-01-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/23513045/
    # - https://stackoverflow.com/questions/20010199/
    # """
    [ -f '/.dockerenv' ]
}

koopa_is_fedora() { # {{{1
    # """
    # Is the operating system Fedora?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'fedora'
}

koopa_is_fedora_like() { # {{{1
    # """
    # Is the operating system Fedora-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'fedora'
}

koopa_is_git_repo() { # {{{1i
    # """
    # Is the working directory a git repository?
    # @note Updated 2022-02-23.
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    koopa_is_git_repo_top_level '.' && return 0
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}

koopa_is_git_repo_clean() { # {{{1
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2022-01-20.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    koopa_is_git_repo || return 1
    koopa_git_repo_has_unstaged_changes && return 1
    koopa_git_repo_needs_pull_or_push && return 1
    return 0
}

koopa_is_git_repo_top_level() { # {{{1
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2021-08-19.
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

koopa_is_host() { # {{{1
    # """
    # Does the current host match?
    # @note Updated 2020-08-06.
    # """
    [ "$(koopa_host_id)" = "${1:?}" ]
}

koopa_is_installed() { # {{{1
    # """
    # Is the requested program name installed?
    # @note Updated 2020-07-05.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

koopa_is_interactive() { # {{{1
    # """
    # Is the current shell interactive?
    # @note Updated 2021-05-27.
    # Consider checking for tmux or subshell here.
    # """
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    koopa_str_detect_posix "$-" 'i' && return 0
    koopa_is_tty && return 0
    return 1
}

koopa_is_linux() { # {{{1
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = 'Linux' ]
}

koopa_is_local_install() { # {{{1
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2022-02-15.
    # """
    koopa_str_detect_posix "$(koopa_koopa_prefix)" "${HOME:?}"
}

koopa_is_macos() { # {{{1
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    [ "$(uname -s)" = 'Darwin' ]
}

koopa_is_opensuse() { # {{{1
    # """
    # Is the operating system openSUSE?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'opensuse'
}

koopa_is_os() { # {{{1
    # """
    # Is a specific OS ID?
    # @note Updated 2020-08-06.
    #
    # This will match Debian but not Ubuntu for a Debian check.
    # """
    [ "$(koopa_os_id)" = "${1:?}" ]
}

koopa_is_os_like() { # {{{1
    # """
    # Is a specific OS ID-like?
    # @note Updated 2021-05-26.
    #
    # This will match Debian and Ubuntu for a Debian check.
    # """
    local grep file id
    grep='grep'
    id="${1:?}"
    koopa_is_os "$id" && return 0
    file='/etc/os-release'
    [ -f "$file" ] || return 1
    "$grep" 'ID=' "$file" | "$grep" -q "$id" && return 0
    "$grep" 'ID_LIKE=' "$file" | "$grep" -q "$id" && return 0
    return 1
}

koopa_is_os_version() { # {{{1
    # """
    # Is a specific OS version?
    # @note Updated 2022-01-21.
    # """
    local file grep version
    file='/etc/os-release'
    grep='grep'
    version="${1:?}"
    [ -f "$file" ] || return 1
    "$grep" -q "VERSION_ID=\"${version}" "$file"
}

koopa_is_python_venv_active() { # {{{1
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}

koopa_is_qemu() { # {{{1
    # """
    # Is the current shell running inside of QEMU emulation?
    # @note Updated 2021-05-26.
    #
    # This can be the case for ARM Docker images running on an x86 Intel
    # machine, and vice versa.
    # """
    local basename cmd real_cmd
    basename='basename'
    cmd="/proc/${$}/exe"
    [ -L "$cmd" ] || return 1
    real_cmd="$(koopa_realpath "$cmd")"
    case "$("$basename" "$real_cmd")" in
        'qemu-'*)
            return 0
            ;;
    esac
    return 1
}

koopa_is_raspbian() { # {{{1
    # """
    # Is the operating system Raspbian?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'raspbian'
}

koopa_is_remote() { # {{{1
    # """
    # Is the current shell session a remote connection over SSH?
    # @note Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

koopa_is_rhel() { # {{{1
    # """
    # Is the operating system RHEL?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'rhel'
}

koopa_is_rhel_like() { # {{{1
    # """
    # Is the operating system RHEL-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'rhel'
}

koopa_is_rhel_ubi() { # {{{
    # """
    # Is the operating system a RHEL universal base image (UBI)?
    # @note Updated 2020-08-06.
    # """
    [ -f '/etc/yum.repos.d/ubi.repo' ]
}

koopa_is_rhel_7_like() { # {{{1
    # """
    # Is the operating system RHEL 7-like?
    # @note Updated 2021-03-25.
    # """
    koopa_is_rhel_like && koopa_is_os_version 7
}

koopa_is_rhel_8_like() { # {{{1
    # """
    # Is the operating system RHEL 8-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_rhel_like && koopa_is_os_version 8
}

koopa_is_rocky() { # {{{1
    # """
    # Is the current operating system Rocky Linux?
    # @note Updated 2021-06-21.
    # """
    koopa_is_os 'rocky'
}

koopa_is_root() { # {{{1
    # """
    # Is the current user root?
    # @note Updated 2020-04-16.
    # """
    [ "$(koopa_user_id)" -eq 0 ]
}

koopa_is_rstudio() { # {{{1
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2020-06-19.
    # """
    [ -n "${RSTUDIO:-}" ]
}

koopa_is_set_nounset() { # {{{1
    # """
    # Is shell running in 'nounset' variable mode?
    # @note Updated 2020-04-29.
    #
    # Many activation scripts, including Perlbrew and others have unset
    # variables that can cause the shell session to exit.
    #
    # How to enable:
    # > set -o nounset  # -u
    #
    # Bash:
    # shopt -o (arg?)
    # Enabled: 'nounset [...] on'.
    #
    # shopt -op (arg?)
    # Enabled: 'set -o nounset'.
    #
    # Zsh:
    # setopt
    # Enabled: 'nounset'.
    # """
    koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

koopa_is_shared_install() { # {{{1
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2019-06-25.
    # """
    ! koopa_is_local_install
}

koopa_is_subshell() { # {{{1
    # """
    # Is koopa running inside a subshell?
    # @note Updated 2021-05-06.
    # """
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

koopa_is_tmux() { # {{{1
    # """
    # Is current session running inside tmux?
    # @note Updated 2020-02-26.
    # """
    [ -n "${TMUX:-}" ]
}

koopa_is_tty() { # {{{1
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-07-03.
    # """
    koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

koopa_is_ubuntu() { # {{{1
    # """
    # Is the operating system Ubuntu?
    # @note Updated 2020-04-29.
    # """
    koopa_is_os 'ubuntu'
}

koopa_is_ubuntu_like() { # {{{1
    # """
    # Is the operating system Ubuntu-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'ubuntu'
}

koopa_is_x86_64() { # {{{1
    # """
    # Is the architecture Intel x86 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "amd64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'x86_64' ]
}

koopa_java_prefix() { # {{{1
    # """
    # Java prefix.
    # @note Updated 2022-04-08.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    local prefix
    if [ -n "${JAVA_HOME:-}" ]
    then
        koopa_print "$JAVA_HOME"
        return 0
    fi
    if [ -d "$(koopa_openjdk_prefix)" ]
    then
        koopa_print "$(koopa_openjdk_prefix)"
        return 0
    fi
    if [ -x '/usr/libexec/java_home' ]
    then
        prefix="$('/usr/libexec/java_home' || true)"
        [ -n "$prefix" ] || return 1
        koopa_print "$prefix"
        return 0
    fi
    if [ -d "$(koopa_homebrew_opt_prefix)/openjdk" ]
    then
        koopa_print "$(koopa_homebrew_opt_prefix)/openjdk"
        return 0
    fi
    return 1
}

koopa_julia_packages_prefix() { # {{{1
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2021-06-14.
    #
    # @usage koopa_julia_packages_prefix [VERSION]
    #
    # In the shell environment, check 'JULIA_DEPOT_PATH'.
    # Inside Julia, check 'DEPOT_PATH'.
    # """
    __koopa_packages_prefix 'julia' "$@"
}

koopa_koopa_prefix() { # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

koopa_lmod_prefix() { # {{{1
    # """
    # Lmod prefix.
    # @note Updated 2021-01-20.
    # """
    koopa_print "$(koopa_opt_prefix)/lmod"
    return 0
}

koopa_local_data_prefix() { # {{{1
    # """
    # Local user application data prefix.
    # @note Updated 2021-05-25.
    #
    # This is the default app path when koopa is installed per user.
    # """
    koopa_print "$(koopa_xdg_data_home)"
    return 0
}

koopa_locate_shell() { # {{{1
    # """
    # Locate the current shell executable.
    # @note Updated 2022-02-02.
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
    local proc_file pid shell
    shell="${KOOPA_SHELL:-}"
    if [ -n "$shell" ]
    then
        koopa_print "$shell"
        return 0
    fi
    pid="${$}"
    if koopa_is_linux
    then
        proc_file="/proc/${pid}/exe"
        if [ -x "$proc_file" ] && ! koopa_is_qemu
        then
            shell="$(koopa_realpath "$proc_file")"
        elif koopa_is_installed 'ps'
        then
            shell="$( \
                ps -p "$pid" -o 'comm=' \
                | sed 's/^-//' \
            )"
        fi
    elif koopa_is_macos
    then
        shell="$( \
            lsof \
                -a \
                -F 'n' \
                -d 'txt' \
                -p "$pid" \
                2>/dev/null \
            | sed -n '3p' \
            | sed 's/^n//' \
        )"
    fi
    # Fallback support for detection failure inside of some subprocesses.
    if [ -z "$shell" ]
    then
        if [ -n "${BASH_VERSION:-}" ]
        then
            shell='bash'
        elif [ -n "${ZSH_VERSION:-}" ]
        then
            shell='zsh'
        fi
    fi
    [ -n "$shell" ] || return 1
    koopa_print "$shell"
    return 0
}

koopa_macos_activate_cli_colors() { # {{{1
    # """
    # Activate macOS-specific terminal color settings.
    # @note Updated 2020-07-05.
    #
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    # """
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

koopa_macos_activate_google_cloud_sdk() { # {{{1
    # """
    # Activate macOS Google Cloud SDK Homebrew cask.
    # @note Updated 2022-04-04.
    #
    # Alternate (slower) approach that enables autocompletion.
    # > local prefix shell
    # > prefix="$(koopa_homebrew_cask_prefix)/google-cloud-sdk/\
    # > latest/google-cloud-sdk"
    # > [ -d "$prefix" ] || return 0
    # > shell="$(koopa_shell_name)"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/path.${shell}.inc" ] && \
    # >     . "${prefix}/path.${shell}.inc"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/completion.${shell}.inc" ] && \
    # >     . "${prefix}/completion.${shell}.inc"
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#mac
    # """
    CLOUDSDK_PYTHON="$(koopa_homebrew_opt_prefix)/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON
    return 0
}

koopa_macos_gfortran_prefix() { # {{{1
    # """
    # macOS gfortran prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/usr/local/gfortran'
    return 0
}

koopa_macos_is_dark_mode() { # {{{1
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2021-05-05.
    # """
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}

koopa_macos_is_light_mode() { # {{{1
    # """
    # Is the current terminal running in light mode?
    # @note Updated 2021-05-05.
    # """
    ! koopa_macos_is_dark_mode
}

koopa_macos_julia_prefix() { # {{{1
    # """
    # macOS Julia prefix.
    # @note Updated 2021-12-01.
    # """
    local x
    x="$( \
        find '/Applications' \
            -mindepth 1 \
            -maxdepth 1 \
            -name 'Julia-*.app' \
            -type 'd' \
            -print \
        | sort \
        | tail -n 1 \
    )"
    [ -d "$x" ] || return 1
    prefix="${x}/Contents/Resources/julia"
    [ -d "$x" ] || return 1
    koopa_print "$prefix"
}

koopa_macos_os_codename() { # {{{1
    # """
    # macOS OS codename (marketing name).
    # @note Updated 2021-12-07.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/333452/
    # - https://unix.stackexchange.com/questions/234104/
    # """
    local version x
    version="$(koopa_macos_os_version)"
    case "$version" in
        '12.'*)
            x='Monterey'
            ;;
        '11.'*)
            x='Big Sur'
            ;;
        '10.15.'*)
            x='Catalina'
            ;;
        '10.14.'*)
            x='Mojave'
            ;;
        '10.13.'*)
            x='High Sierra'
            ;;
        '10.12.'*)
            x='Sierra'
            ;;
        '10.11.'*)
            x='El Capitan'
            ;;
        '10.10.'*)
            x='Yosmite'
            ;;
        '10.9.'*)
            x='Mavericks'
            ;;
        '10.8.'*)
            x='Mountain Lion'
            ;;
        '10.7.'*)
            x='Lion'
            ;;
        '10.6.'*)
            x='Snow Leopard'
            ;;
        '10.5.'*)
            x='Leopard'
            ;;
        '10.4.'*)
            x='Tiger'
            ;;
        '10.3.'*)
            x='Panther'
            ;;
        '10.2.'*)
            x='Jaguar'
            ;;
        '10.1.'*)
            x='Puma'
            ;;
        '10.0.'*)
            x='Cheetah'
            ;;
        *)
            return 1
            ;;
    esac
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_os_version() { # {{{1
    # """
    # macOS version.
    # @note Updated 2022-04-08.
    # """
    local x
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_python_prefix() { # {{{1
    # """
    # macOS Python installation prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/Library/Frameworks/Python.framework/Versions/Current'
}

koopa_macos_r_prefix() { # {{{1
    # """
    # macOS R installation prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
}

koopa_major_version() { # {{{1
    # """
    # Program 'MAJOR' version.
    # @note Updated 2022-02-23.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_major_minor_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_major_minor_patch_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_make_prefix() { # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2022-04-08.
    # """
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif koopa_is_local_install
    then
        prefix="$(koopa_xdg_local_home)"
    else
        prefix='/usr/local'
    fi
    koopa_print "$prefix"
    return 0
}

koopa_msigdb_prefix() { # {{{1
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    koopa_print "$(koopa_refdata_prefix)/msigdb"
    return 0
}

koopa_monorepo_prefix() { # {{{1
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    koopa_print "${HOME:?}/monorepo"
    return 0
}

koopa_nim_packages_prefix() { # {{{1
    # """
    # Nim (Nimble) packages prefix.
    # @note Updated 2021-09-29.
    #
    # @usage koopa_nim_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'nim' "$@"
}

koopa_node_packages_prefix() { # {{{1
    # """
    # Node.js (NPM) packages prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_node_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'node' "$@"
}

koopa_openjdk_prefix() { # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/openjdk"
    return 0
}

koopa_opt_prefix() { # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    koopa_print "$(koopa_koopa_prefix)/opt"
    return 0
}

koopa_os_codename() { # {{{1
    # """
    # Operating system codename.
    # @note Updated 2021-06-02.
    # """
    if koopa_is_debian_like
    then
        koopa_debian_os_codename
    elif koopa_is_macos
    then
        koopa_macos_os_codename
    else
        return 1
    fi
    return 0
}

koopa_os_id() { # {{{1
    # """
    # Operating system ID.
    # @note Updated 2021-05-21.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    local x
    x="$( \
        koopa_os_string \
        | cut -d '-' -f '1' \
    )"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_os_string() { # {{{1
    # """
    # Operating system string.
    # @note Updated 2022-02-23.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    local id release_file string version
    if koopa_is_macos
    then
        id='macos'
        version="$(koopa_macos_os_version)"
        version="$(koopa_major_minor_version "$version")"
    elif koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            # shellcheck disable=SC2016
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' "$release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            # shellcheck disable=SC2016
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' "$release_file" \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version='rolling'
            fi
        else
            id='linux'
        fi
    fi
    [ -z "$id" ] && return 1
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    koopa_print "$string"
    return 0
}

koopa_perl_packages_prefix() { # {{{1
    # """
    # Perl site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_perl_packages_prefix [VERSION]
    #
    # @seealso
    # > perl -V
    # # Inspect the '@INC' variable.
    # """
    __koopa_packages_prefix 'perl' "$@"
}

koopa_perlbrew_prefix() { # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/perlbrew"
    return 0
}

koopa_pipx_prefix() { # {{{1
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/pipx"
    return 0
}

koopa_prelude_emacs_prefix() { # {{{1
    # """
    # Prelude Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/prelude"
    return 0
}

koopa_print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2020-07-05.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    local string
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

koopa_prompt_conda() { # {{{1
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2021-08-17.
    # """
    local env
    env="$(koopa_conda_env_name)"
    [ -n "$env" ] || return 0
    koopa_print " conda:${env}"
    return 0
}

koopa_prompt_git() { # {{{1
    # """
    # Return the current git branch, if applicable.
    # @note Updated 2021-08-19.
    #
    # Also indicate status with '*' if dirty (i.e. has unstaged changes).
    # """
    local git_branch git_status
    koopa_is_git_repo || return 0
    git_branch="$(koopa_git_branch)"
    if koopa_is_git_repo_clean
    then
        git_status=''
    else
        git_status='*'
    fi
    koopa_print " ${git_branch}${git_status}"
    return 0
}

koopa_prompt_python_venv() { # {{{1
    # """
    # Get Python virtual environment name for prompt string.
    # @note Updated 2021-06-14.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    local env
    env="$(koopa_python_venv_name)"
    [ -n "$env" ] || return 0
    koopa_print " venv:${env}"
    return 0
}

koopa_pyenv_prefix() { # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    koopa_print "$(koopa_opt_prefix)/pyenv"
    return 0
}

# > koopa_python_packages_prefix() { # {{{1
# >     # """
# >     # Python site packages library prefix.
# >     # @note Updated 2021-06-11.
# >     #
# >     # @usage koopa_python_packages_prefix [VERSION]
# >     #
# >     # @seealso
# >     # > "$python" -m site
# >     # """
# >     __koopa_packages_prefix 'python' "$@"
# > }

koopa_python_venv_name() { # {{{1
    # """
    # Python virtual environment name.
    # @note Updated 2021-08-17.
    # """
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    # Strip out the path and just leave the env name.
    x="${x##*/}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_python_virtualenvs_prefix() { # {{{1
    # """
    # Python virtual environment prefix.
    # @note Updated 2022-03-30.
    # """
    koopa_print "$(koopa_opt_prefix)/python-virtualenvs"
    return 0
}

koopa_r_packages_prefix() { # {{{1
    # """
    # R site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_r_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'r' "$@"
}

koopa_rbenv_prefix() { # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2021-05-25.
    # ""
    koopa_print "$(koopa_opt_prefix)/rbenv"
    return 0
}

koopa_realpath() { # {{{1
    # """
    # Real path to file/directory on disk.
    # @note Updated 2022-04-08.
    #
    # Note that 'readlink -f' only works with GNU coreutils but not BSD
    # (i.e. macOS) variant.
    #
    # Python option:
    # > x="(python -c "import os; print(os.path.realpath('$1'))")"
    #
    # Perl option:
    # > x="$(perl -MCwd -e 'print Cwd::abs_path shift' "$1")"
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    local readlink x
    readlink='readlink'
    if ! koopa_is_installed "$readlink"
    then
        local brew_readlink koopa_readlink
        koopa_readlink="$(koopa_opt_prefix)/coreutils/bin/readlink"
        brew_readlink="$(koopa_homebrew_opt_prefix)/coreutils/libexec/\
gnubin/readlink"
        if [ -x "$koopa_readlink" ]
        then
            readlink="$koopa_readlink"
        elif [ -x "$brew_readlink" ]
        then
            readlink="$brew_readlink"
        else
            return 1
        fi
    fi
    x="$("$readlink" -f "$@")"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_refdata_prefix() { # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2021-12-09.
    # """
    koopa_print "$(koopa_opt_prefix)/refdata"
    return 0
}

koopa_ruby_packages_prefix() { # {{{1
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_ruby_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'ruby' "$@"
}

koopa_rust_prefix() { # {{{1
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}

koopa_rust_packages_prefix() { # {{{1
    # """
    # Rust packags prefix.
    # @note Updated 2022-04-09.
    #
    # @usage koopa_rust_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'rust' "$@"
}

koopa_sbin_prefix() { # {{{1
    # """
    # Koopa super user binary prefix.
    # @note Updated 2022-04-05.
    # """
    koopa_print "$(koopa_koopa_prefix)/sbin"
    return 0
}

koopa_scripts_private_prefix() { # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/scripts-private"
    return 0
}

koopa_shell_name() { # {{{1
    # """
    # Current shell name.
    # @note Updated 2021-05-25.
    # """
    local shell str
    shell="$(koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_spacemacs_prefix() { # {{{1
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacemacs"
    return 0
}

koopa_spacevim_prefix() { # {{{1
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacevim"
    return 0
}

koopa_str_detect_posix() { # {{{1
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2022-02-15.
    #
    # We're unsetting 'test' here to ensure no variables/functions mask the
    # shell built-in.
    # """
    unset test
    test "${1#*"$2"}" != "$1"
}

koopa_today() { # {{{1
    # """
    # Today string.
    # @note Updated 2021-05-26.
    # """
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_umask() { # {{{1
    # """
    # Set default file permissions.
    # @note Updated 2020-06-03.
    #
    # - 'umask': Files and directories.
    # - 'fmask': Only files.
    # - 'dmask': Only directories.
    #
    # Use 'umask -S' to return 'u,g,o' values.
    #
    # - 0022: 'u=rwx,g=rx,o=rx'.
    #         User can write, others can read. Usually default.
    # - 0002: 'u=rwx,g=rwx,o=rx'.
    #         User and group can write, others can read.
    #         Recommended setting in a shared coding environment.
    # - 0077: 'u=rwx,g=,o='.
    #         User alone can read/write. More secure.
    #
    # Access control lists (ACLs) are sometimes preferable to umask.
    #
    # Here's how to use ACLs with setfacl.
    # > setfacl -d -m group:name:rwx /dir
    #
    # @seealso
    # - https://stackoverflow.com/questions/13268796
    # - https://askubuntu.com/questions/44534
    # """
    umask 0002
    return 0
}

koopa_user() { # {{{1
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use 'whoami' here.
    # """
    __koopa_id -un
    return 0
}

koopa_user_id() { # {{{1
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    __koopa_id -u
    return 0
}

koopa_xdg_cache_home() { # {{{1
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_dirs() { # {{{1
    # """
    # XDG config dirs.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_home() { # {{{1
    # """
    # XDG config home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_dirs() { # {{{1
    # """
    # XDG data dirs.
    # @note Updated 2022-04-08.
    # """
    local x
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        x='/usr/local/share:/usr/share'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_home() { # {{{1
    # """
    # XDG data home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_DATA_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.local/share"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_local_home() { # {{{1
    # """
    # XDG local installation home.
    # @note Updated 2021-05-20.
    #
    # Not intended to be configurable with a global variable.
    #
    # @seealso
    # - https://www.freedesktop.org/software/systemd/man/file-hierarchy.html
    # """
    koopa_print "${HOME:?}/.local"
    return 0
}

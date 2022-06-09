#!/bin/sh
# shellcheck disable=all

__koopa_add_to_path_string_end() {
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

__koopa_add_to_path_string_start() {
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

__koopa_id() {
    local str
    str="$(id "$@")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

__koopa_packages_prefix() {
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

__koopa_remove_from_path_string() {
    koopa_print "${1:?}" | sed "s|${2:?}||g"
    return 0
}

koopa_activate_alacritty() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    koopa_is_alacritty || return 0
    prefix="$(koopa_xdg_config_home)/alacritty"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="colors-${color_mode}.yml"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/colors.yml"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    ln -fns "$source_file" "$target_file"
    return 0
}

koopa_activate_aliases() {
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
    alias cm='chezmoi'
    alias d='clear; cd -; l'
    alias doom-emacs='koopa_alias_doom_emacs'
    alias e='exit'
    alias emacs-vanilla='koopa_alias_emacs_vanilla'
    alias emacs='koopa_alias_emacs'
    alias fd='fd --case-sensitive --no-ignore'
    alias fvim='vim "$(fzf)"'
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
    file="${HOME:?}/.aliases"
    [ -f "$file" ] && . "$file"
    file="${HOME:?}/.aliases-private"
    [ -f "$file" ] && . "$file"
    return 0
}

koopa_activate_bat() {
    local color_mode conf_file prefix
    [ -x "$(koopa_bin_prefix)/bat" ] || return 0
    prefix="$(koopa_xdg_config_home)/bat"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    conf_file="${prefix}/config-${color_mode}"
    [ -f "$conf_file" ] || return 0
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}

koopa_activate_bcbio_nextgen() {
    local prefix
    prefix="$(koopa_bcbio_nextgen_prefix)"
    [ -d "$prefix" ] || return 0
    koopa_add_to_path_end "${prefix}/tools/bin"
    return 0
}

koopa_activate_broot() {
    local config_dir nounset script shell
    [ -x "$(koopa_bin_prefix)/broot" ] || return 0
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
    script="${config_dir}/launcher/bash/br"
    [ -f "$script" ] || return 0
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_color_mode() {
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

koopa_activate_completion() {
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
        [ -f "$file" ] && . "$file"
    done
    return 0
}

koopa_activate_conda() {
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
    . "$script"
    if [ "${CONDA_DEFAULT_ENV:-}" = 'base' ] && \
        [ "${CONDA_SHLVL:-0}" -eq 1 ]
    then
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -o nounset
    [ -z "${MAMBA_NO_BANNER:-}" ] && export MAMBA_NO_BANNER=1
    return 0
}

koopa_activate_coreutils_aliases() {
    [ -x "$(koopa_bin_prefix)/cp" ] || return 0
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
    rm_args='-i' # '--interactive=once'.
    alias cp="${cp} ${cp_args}"
    alias ln="${ln} ${ln_args}"
    alias mkdir="${mkdir} ${mkdir_args}"
    alias mv="${mv} ${mv_args}"
    alias rm="${rm} ${rm_args}"
    return 0
}

koopa_activate_delta() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    [ -x "$(koopa_bin_prefix)/delta" ] || return 0
    prefix="$(koopa_xdg_config_home)/delta"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="theme-${color_mode}.gitconfig"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/theme.gitconfig"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    ln -fns "$source_file" "$target_file"
    return 0
}

koopa_activate_difftastic() {
    [ -x "$(koopa_bin_prefix)/difft" ] || return 0
    DFT_BACKGROUND="$(koopa_color_mode)"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}

koopa_activate_dircolors() {
    [ -n "${SHELL:-}" ] || return 0
    local dircolors
    dircolors="$(koopa_bin_prefix)/dircolors"
    [ -x "$dircolors" ] || return 0
    local color_mode config_prefix dircolors_file
    config_prefix="$(koopa_xdg_config_home)/dircolors"
    color_mode="$(koopa_color_mode)"
    dircolors_file="${config_prefix}/dircolors-${color_mode}"
    [ -f "$dircolors_file" ] || return 0
    eval "$("$dircolors" "$dircolors_file")"
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
    return 0
}

koopa_activate_fzf() {
    [ -x "$(koopa_bin_prefix)/fzf" ] || return 0
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}

koopa_activate_gcc_colors() {
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

koopa_activate_go() {
    local prefix
    [ -x "$(koopa_bin_prefix)/go" ] || return 0
    prefix="$(koopa_go_packages_prefix)"
    [ -d "$prefix" ] || return 0
    GOPATH="$(koopa_go_packages_prefix)"
    export GOPATH
    return 0
}

koopa_activate_homebrew() {
    local prefix
    prefix="$(koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    [ -x "${prefix}/bin/brew" ] || return 0
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

koopa_activate_julia() {
    local prefix
    [ -x "$(koopa_bin_prefix)/julia" ] || return 0
    prefix="$(koopa_julia_packages_prefix)"
    if [ -d "$prefix" ]
    then
        export JULIA_DEPOT_PATH="$prefix"
    fi
    return 0
}

koopa_activate_kitty() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    koopa_is_kitty || return 0
    prefix="$(koopa_xdg_config_home)/kitty"
    [ -d "$prefix" ] || return 0
    color_mode="$(koopa_color_mode)"
    source_bn="theme-${color_mode}.conf"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/current-theme.conf"
    if [ -h "$target_file" ] && koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    ln -fns "$source_file" "$target_file"
    return 0
}

koopa_activate_lesspipe() {
    local lesspipe
    lesspipe="$(koopa_bin_prefix)/lesspipe.sh"
    [ -x "$lesspipe" ] || return 0
    export LESS='-R'
    export LESSCOLOR='yes'
    export LESSOPEN="|${lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    [ -z "${LESSCHARSET:-}" ] && export LESSCHARSET='utf-8'
    return 0
}

koopa_activate_make_paths() {
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

koopa_activate_mcfly() {
    local nounset shell
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    [ -x "$(koopa_bin_prefix)/mcfly" ] || return 0
    koopa_is_root && return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
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

koopa_activate_nim() {
    local prefix
    [ -x "$(koopa_bin_prefix)/nim" ] || return 0
    prefix="$(koopa_nim_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NIMBLE_DIR="$prefix"
    return 0
}

koopa_activate_node() {
    local prefix
    [ -x "$(koopa_bin_prefix)/node" ] || return 0
    prefix="$(koopa_node_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export NPM_CONFIG_PREFIX="$prefix"
    return 0
}

koopa_activate_path_helper() {
    local path_helper
    path_helper='/usr/libexec/path_helper'
    [ -x "$path_helper" ] || return 0
    eval "$("$path_helper" -s)"
    return 0
}

koopa_activate_perl() {
    local prefix
    [ -x "$(koopa_bin_prefix)/perl" ] || return 0
    prefix="$(koopa_perl_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export PERL5LIB="${prefix}/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$prefix"
    export PERL_MB_OPT="--install_base '${prefix}'"
    export PERL_MM_OPT="INSTALL_BASE=${prefix}"
    export PERL_MM_USE_DEFAULT=1
    return 0
}

koopa_activate_perlbrew() {
    local nounset prefix script shell
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/perlbrew" ] || return 0
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
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_activate_pipx() {
    local prefix
    [ -x "$(koopa_bin_prefix)/pipx" ] || return 0
    prefix="$(koopa_pipx_prefix)"
    [ -d "$prefix" ] || return 0
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}

koopa_activate_prefix() {
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

koopa_activate_pyenv() {
    local nounset prefix script
    [ -n "${PYENV_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/pyenv" ] || return 0
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

koopa_activate_python() {
    if [ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [ -z "${PYTHONDONTWRITEBYTECODE:-}" ]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    if [ -z "${PYTHONSAFEPATH:-}" ]
    then
        export PYTHONSAFEPATH=1
    fi
    if [ -z "${PYTHONSTARTUP:-}" ]
    then
        local startup_file
        startup_file="${HOME:?}/.pyrc"
        if [ -f "$startup_file" ]
        then
            export PYTHONSTARTUP="$startup_file"
        fi
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

koopa_activate_rbenv() {
    local nounset prefix script
    [ -n "${RBENV_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/rbenv" ] || return 0
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

koopa_activate_ruby() {
    local prefix
    [ -x "$(koopa_bin_prefix)/ruby" ] || return 0
    prefix="$(koopa_ruby_packages_prefix)"
    [ -d "$prefix" ] || return 0
    export GEM_HOME="$prefix"
    return 0
}

koopa_activate_secrets() {
    local file
    file="${1:-}"
    [ -z "$file" ] && file="${HOME:?}/.secrets"
    [ -r "$file" ] || return 0
    . "$file"
    return 0
}

koopa_activate_ssh_key() {
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

koopa_activate_starship() {
    local nounset shell
    [ -x "$(koopa_bin_prefix)/starship" ] || return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    unset -v STARSHIP_SESSION_KEY STARSHIP_SHELL
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && return 0
    eval "$(starship init "$shell")"
    return 0
}

koopa_activate_tealdeer() {
    [ -x "$(koopa_bin_prefix)/tldr" ] || return 0
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

koopa_activate_today_bucket() {
    local bucket_dir today_bucket today_link
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    [ -d "$bucket_dir" ] || return 0
    today_bucket="$(date '+%Y/%m/%d')"
    today_link="${HOME:?}/today"
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

koopa_activate_xdg() {
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

koopa_activate_zoxide() {
    local nounset shell zoxide
    zoxide="$(koopa_bin_prefix)/zoxide"
    [ -x "$zoxide" ] || return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$zoxide" init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

koopa_add_config_link() {
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

koopa_add_to_fpath_end() {
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

koopa_add_to_fpath_start() {
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

koopa_add_to_manpath_end() {
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

koopa_add_to_manpath_start() {
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

koopa_add_to_path_end() {
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

koopa_add_to_path_start() {
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

koopa_alias_broot() {
    koopa_is_alias 'br' && unalias 'br'
    koopa_activate_broot
    br "$@"
}

koopa_alias_bucket() {
    local prefix
    prefix="${HOME:?}/today"
    [ -d "$prefix" ] || return 1
    cd "$prefix" || return 1
    ls
}

koopa_alias_colorls() {
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

koopa_alias_conda() {
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_activate_conda
    conda "$@"
}

koopa_alias_doom_emacs() {
    local prefix
    prefix="$(koopa_doom_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'doom' "$@"
}

koopa_alias_emacs_vanilla() {
    emacs --no-init-file --no-window-system "$@"
}

koopa_alias_emacs() {
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

koopa_alias_k() {
    cd "$(koopa_koopa_prefix)" || return 1
}

koopa_alias_l() {
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

koopa_alias_mamba() {
    koopa_is_alias 'conda' && unalias 'conda'
    koopa_is_alias 'mamba' && unalias 'mamba'
    koopa_activate_conda
    mamba "$@"
}

koopa_alias_nvim_fzf() {
    nvim "$(fzf)"
}

koopa_alias_nvim_vanilla() {
    nvim -u 'NONE' "$@"
}

koopa_alias_perlbrew() {
    koopa_is_alias 'perlbrew' && unalias 'perlbrew'
    koopa_activate_perlbrew
    perlbrew "$@"
}

koopa_alias_prelude_emacs() {
    local prefix
    prefix="$(koopa_prelude_emacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'prelude' "$@"
}

koopa_alias_pyenv() {
    koopa_is_alias 'pyenv' && unalias 'pyenv'
    koopa_activate_pyenv
    pyenv "$@"
}

koopa_alias_rbenv() {
    koopa_is_alias 'rbenv' && unalias 'rbenv'
    koopa_activate_rbenv
    rbenv "$@"
}

koopa_alias_sha256() {
    shasum -a 256 "$@"
}

koopa_alias_spacemacs() {
    local prefix
    prefix="$(koopa_spacemacs_prefix)"
    [ -d "$prefix" ] || return 1
    emacs --with-profile 'spacemacs' "$@"
}

koopa_alias_spacevim() {
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

koopa_alias_tmux_vanilla() {
    tmux -f '/dev/null'
}

koopa_alias_today() {
    date '+%Y-%m-%d'
}

koopa_alias_vim_fzf() {
    vim "$(fzf)"
}

koopa_alias_vim_vanilla() {
    vim -i 'NONE' -u 'NONE' -U 'NONE' "$@"
}

koopa_alias_week() {
    date '+%V'
}

koopa_alias_zoxide() {
    koopa_is_alias 'z' && unalias 'z'
    koopa_activate_zoxide
    z "$@"
}

koopa_anaconda_prefix() {
    koopa_print "$(koopa_opt_prefix)/anaconda"
    return 0
}

koopa_app_prefix() {
    koopa_print "$(koopa_koopa_prefix)/app"
    return 0
}

koopa_arch() {
    local x
    x="$(uname -m)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_aspera_connect_prefix() {
    koopa_print "$(koopa_opt_prefix)/aspera-connect"
    return 0
}

koopa_bcbio_nextgen_prefix() {
    koopa_print "$(koopa_opt_prefix)/bcbio-nextgen"
    return 0
}

koopa_bin_prefix() {
    koopa_print "$(koopa_koopa_prefix)/bin"
    return 0
}

koopa_boolean_nounset() {
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

koopa_is_centos_like() {
    koopa_is_os_like 'centos'
}

koopa_color_mode() {
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
    koopa_print "$str"
    return 0
}

koopa_conda_env_name() {
    local x
    x="${CONDA_DEFAULT_ENV:-}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_conda_prefix() {
    koopa_print "$(koopa_opt_prefix)/conda"
    return 0
}

koopa_config_prefix() {
    koopa_print "$(koopa_xdg_config_home)/koopa"
    return 0
}

koopa_debian_os_codename() {
    local x
    koopa_is_installed 'lsb_release' || return 0
    x="$(lsb_release -cs)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_distro_prefix() {
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

koopa_docker_prefix() {
    koopa_print "$(koopa_config_prefix)/docker"
    return 0
}

koopa_docker_private_prefix() {
    koopa_print "$(koopa_config_prefix)/docker-private"
    return 0
}

koopa_doom_emacs_prefix() {
    koopa_print "$(koopa_xdg_data_home)/doom"
    return 0
}

koopa_dotfiles_prefix() {
    koopa_print "$(koopa_opt_prefix)/dotfiles"
    return 0
}

koopa_dotfiles_private_prefix() {
    koopa_print "$(koopa_config_prefix)/dotfiles-private"
    return 0
}

koopa_duration_start() {
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    [ -x "${bin_prefix}/date" ] || return 0
    KOOPA_DURATION_START="$(date -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

koopa_duration_stop() {
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

koopa_emacs_prefix() {
    koopa_print "${HOME:?}/.emacs.d"
    return 0
}

koopa_ensembl_perl_api_prefix() {
    koopa_print "$(koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

koopa_export_editor() {
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR="$(koopa_bin_prefix)/vim"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

koopa_export_git() {
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        GIT_MERGE_AUTOEDIT='no'
    fi
    export GIT_MERGE_AUTOEDIT
    return 0
}

koopa_export_gnupg() {
    [ -z "${GPG_TTY:-}" ] || return 0
    koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}

koopa_export_history() {
    local shell
    shell="$(koopa_shell_name)"
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.${shell}_history"
    fi
    export HISTFILE
    if [ ! -f "$HISTFILE" ] \
        && [ -e "${HOME:-}" ] \
        && koopa_is_installed 'touch'
    then
        touch "$HISTFILE"
    fi
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
    if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
    then
        HISTSIZE=1000
    fi
    export HISTSIZE
    if [ -z "${HISTTIMEFORMAT:-}" ]
    then
        HISTTIMEFORMAT='%Y%m%d %T  '
    fi
    export HISTTIMEFORMAT
    if [ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]
    then
        SAVEHIST="$HISTSIZE"
    fi
    export SAVEHIST
    return 0
}

koopa_export_koopa_shell() {
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(koopa_locate_shell)"
    export KOOPA_SHELL
    return 0
}

koopa_export_pager() {
    local less
    [ -n "${PAGER:-}" ] && return 0
    less="$(koopa_bin_prefix)/less"
    [ -x "$less" ] || return 0
    export PAGER="${less} -R"
    return 0
}

koopa_expr() {
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

koopa_fzf_prefix() {
    koopa_print "$(koopa_opt_prefix)/fzf"
    return 0
}

koopa_git_branch() {
    local branch
    koopa_is_git_repo || return 0
    branch="$(git branch --show-current 2>/dev/null)"
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

koopa_git_repo_has_unstaged_changes() {
    local x
    git update-index --refresh >/dev/null 2>&1
    x="$(git diff-index 'HEAD' -- 2>/dev/null)"
    [ -n "$x" ]
}

koopa_git_repo_needs_pull_or_push() {
    local rev_1 rev_2
    rev_1="$(git rev-parse 'HEAD' 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}

koopa_go_packages_prefix() {
    __koopa_packages_prefix 'go' "$@"
}

koopa_go_prefix() {
    koopa_print "$(koopa_opt_prefix)/go"
    return 0
}

koopa_group_id() {
    __koopa_id -g
    return 0
}

koopa_group() {
    __koopa_id -gn
    return 0
}

koopa_homebrew_cellar_prefix() {
    koopa_print "$(koopa_homebrew_prefix)/Cellar"
    return 0
}

koopa_homebrew_opt_prefix() {
    koopa_print "$(koopa_homebrew_prefix)/opt"
    return 0
}

koopa_homebrew_prefix() {
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

koopa_host_id() {
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
        *'.ec2.internal')
            id='aws'
            ;;
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

koopa_hostname() {
    local x
    x="$(uname -n)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_include_prefix() {
    koopa_print "$(koopa_koopa_prefix)/include"
    return 0
}

koopa_is_aarch64() {
    [ "$(koopa_arch)" = 'aarch64' ]
}

koopa_is_alacritty() {
    [ -n "${ALACRITTY_SOCKET:-}" ]
}

koopa_is_alias() {
    local cmd str
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        koopa_str_detect_posix "$str" ' is aliased to ' && continue
        koopa_str_detect_posix "$str" ' is an alias for ' && continue
        return 1
    done
    return 0
}

koopa_is_alpine() {
    koopa_is_os 'alpine'
}

koopa_is_amzn() {
    koopa_is_os 'amzn'
}

koopa_is_arch() {
    koopa_is_os 'arch'
}

koopa_is_aws() {
    koopa_is_host 'aws'
}

koopa_is_azure() {
    koopa_is_host 'azure'
}

koopa_is_centos() {
    koopa_is_os 'centos'
}

koopa_is_conda_active() {
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

koopa_is_conda_env_active() {
    [ "${CONDA_SHLVL:-1}" -gt 1 ] && return 0
    [ "${CONDA_DEFAULT_ENV:-base}" != 'base' ] && return 0
    return 1
}

koopa_is_debian_like() {
    koopa_is_os_like 'debian'
}

koopa_is_debian() {
    koopa_is_os 'debian'
}

koopa_is_docker() {
    [ -f '/.dockerenv' ]
}

koopa_is_fedora_like() {
    koopa_is_os_like 'fedora'
}

koopa_is_fedora() {
    koopa_is_os 'fedora'
}

koopa_is_git_repo_clean() {
    koopa_is_git_repo || return 1
    koopa_git_repo_has_unstaged_changes && return 1
    koopa_git_repo_needs_pull_or_push && return 1
    return 0
}

koopa_is_git_repo_top_level() {
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

koopa_is_git_repo() {
    koopa_is_git_repo_top_level '.' && return 0
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}

koopa_is_host() {
    [ "$(koopa_host_id)" = "${1:?}" ]
}

koopa_is_installed() {
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

koopa_is_interactive() {
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    koopa_str_detect_posix "$-" 'i' && return 0
    koopa_is_tty && return 0
    return 1
}

koopa_is_kitty() {
    [ -n "${KITTY_PID:-}" ]
}

koopa_is_linux() {
    [ "$(uname -s)" = 'Linux' ]
}

koopa_is_local_install() {
    koopa_str_detect_posix "$(koopa_koopa_prefix)" "${HOME:?}"
}

koopa_is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

koopa_is_opensuse() {
    koopa_is_os 'opensuse'
}

koopa_is_os_like() {
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

koopa_is_os_version() {
    local file grep version
    file='/etc/os-release'
    grep='grep'
    version="${1:?}"
    [ -f "$file" ] || return 1
    "$grep" -q "VERSION_ID=\"${version}" "$file"
}

koopa_is_os() {
    [ "$(koopa_os_id)" = "${1:?}" ]
}

koopa_is_python_venv_active() {
    [ -n "${VIRTUAL_ENV:-}" ]
}

koopa_is_qemu() {
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

koopa_is_raspbian() {
    koopa_is_os 'raspbian'
}

koopa_is_remote() {
    [ -n "${SSH_CONNECTION:-}" ]
}

koopa_is_rhel_7_like() {
    koopa_is_rhel_like && koopa_is_os_version 7
}

koopa_is_rhel_8_like() {
    koopa_is_rhel_like && koopa_is_os_version 8
}

koopa_is_rhel_9_like() {
    koopa_is_rhel_like && koopa_is_os_version 9
}

koopa_is_rhel_like() {
    koopa_is_os_like 'rhel'
}

koopa_is_rhel_ubi() {
    [ -f '/etc/yum.repos.d/ubi.repo' ]
}

koopa_is_rhel() {
    koopa_is_os 'rhel'
}

koopa_is_rocky() {
    koopa_is_os 'rocky'
}

koopa_is_root() {
    [ "$(koopa_user_id)" -eq 0 ]
}

koopa_is_rstudio() {
    [ -n "${RSTUDIO:-}" ]
}

koopa_is_set_nounset() {
    koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

koopa_is_shared_install() {
    ! koopa_is_local_install
}

koopa_is_subshell() {
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

koopa_is_tmux() {
    [ -n "${TMUX:-}" ]
}

koopa_is_tty() {
    koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

koopa_is_ubuntu_like() {
    koopa_is_os_like 'ubuntu'
}

koopa_is_ubuntu() {
    koopa_is_os 'ubuntu'
}

koopa_julia_packages_prefix() {
    __koopa_packages_prefix 'julia' "$@"
}

koopa_koopa_prefix() {
    koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

koopa_local_data_prefix() {
    koopa_print "$(koopa_xdg_data_home)"
    return 0
}

koopa_locate_shell() {
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

koopa_macos_activate_cli_colors() {
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

koopa_macos_activate_google_cloud_sdk() {
    CLOUDSDK_PYTHON="$(koopa_homebrew_opt_prefix)/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON
    return 0
}

koopa_macos_homebrew_cask_prefix() {
    koopa_print "$(koopa_homebrew_prefix)/Caskroom"
    return 0
}

koopa_macos_is_dark_mode() {
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}

koopa_macos_is_light_mode() {
    ! koopa_macos_is_dark_mode
}

koopa_macos_julia_prefix() {
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

koopa_macos_os_codename() {
    local version x
    version="$(koopa_macos_os_version)"
    case "$version" in
        '13.'*)
            x='Mammoth'
            ;;
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

koopa_macos_os_version() {
    local x
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_python_prefix() {
    koopa_print '/Library/Frameworks/Python.framework/Versions/Current'
}

koopa_macos_r_prefix() {
    koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
}

koopa_major_minor_patch_version() {
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

koopa_major_minor_version() {
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

koopa_major_version() {
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

koopa_make_prefix() {
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

koopa_monorepo_prefix() {
    koopa_print "${HOME:?}/monorepo"
    return 0
}

koopa_msigdb_prefix() {
    koopa_print "$(koopa_refdata_prefix)/msigdb"
    return 0
}

koopa_nim_packages_prefix() {
    __koopa_packages_prefix 'nim' "$@"
}

koopa_node_packages_prefix() {
    __koopa_packages_prefix 'node' "$@"
}

koopa_openjdk_prefix() {
    koopa_print "$(koopa_opt_prefix)/openjdk"
    return 0
}

koopa_opt_prefix() {
    koopa_print "$(koopa_koopa_prefix)/opt"
    return 0
}

koopa_os_codename() {
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

koopa_os_id() {
    local x
    x="$( \
        koopa_os_string \
        | cut -d '-' -f '1' \
    )"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_os_string() {
    local id release_file string version
    if koopa_is_macos
    then
        id='macos'
        version="$(koopa_macos_os_version)"
        version="$(koopa_major_version "$version")"
    elif koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' "$release_file" \
                | tr -d '"' \
            )"
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' "$release_file" \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(koopa_major_version "$version")"
            else
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

koopa_perl_packages_prefix() {
    __koopa_packages_prefix 'perl' "$@"
}

koopa_perlbrew_prefix() {
    koopa_print "$(koopa_opt_prefix)/perlbrew"
    return 0
}

koopa_pipx_prefix() {
    koopa_print "$(koopa_opt_prefix)/pipx"
    return 0
}

koopa_prelude_emacs_prefix() {
    koopa_print "$(koopa_xdg_data_home)/prelude"
    return 0
}

koopa_print() {
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

koopa_prompt_conda() {
    local env
    env="$(koopa_conda_env_name)"
    [ -n "$env" ] || return 0
    koopa_print " conda:${env}"
    return 0
}

koopa_prompt_git() {
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

koopa_prompt_python_venv() {
    local env
    env="$(koopa_python_venv_name)"
    [ -n "$env" ] || return 0
    koopa_print " venv:${env}"
    return 0
}

koopa_pyenv_prefix() {
    koopa_print "$(koopa_opt_prefix)/pyenv"
    return 0
}

koopa_python_venv_name() {
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    x="${x##*/}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_python_virtualenvs_prefix() {
    koopa_print "$(koopa_opt_prefix)/python-virtualenvs"
    return 0
}

koopa_r_packages_prefix() {
    __koopa_packages_prefix 'r' "$@"
}

koopa_rbenv_prefix() {
    koopa_print "$(koopa_opt_prefix)/rbenv"
    return 0
}

koopa_realpath() {
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

koopa_refdata_prefix() {
    koopa_print "$(koopa_opt_prefix)/refdata"
    return 0
}

koopa_ruby_packages_prefix() {
    __koopa_packages_prefix 'ruby' "$@"
}

koopa_rust_packages_prefix() {
    __koopa_packages_prefix 'rust' "$@"
}

koopa_rust_prefix() {
    koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}

koopa_sbin_prefix() {
    koopa_print "$(koopa_koopa_prefix)/sbin"
    return 0
}

koopa_scripts_private_prefix() {
    koopa_print "$(koopa_config_prefix)/scripts-private"
    return 0
}

koopa_shell_name() {
    local shell str
    shell="$(koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_spacemacs_prefix() {
    koopa_print "$(koopa_xdg_data_home)/spacemacs"
    return 0
}

koopa_spacevim_prefix() {
    koopa_print "$(koopa_xdg_data_home)/spacevim"
    return 0
}

koopa_str_detect_posix() {
    unset test
    test "${1#*"$2"}" != "$1"
}

koopa_today() {
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_umask() {
    umask 0002
    return 0
}

koopa_user_id() {
    __koopa_id -u
    return 0
}

koopa_user() {
    __koopa_id -un
    return 0
}

koopa_xdg_cache_home() {
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_dirs() {
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_home() {
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_dirs() {
    local x
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        x='/usr/local/share:/usr/share'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_home() {
    local x
    x="${XDG_DATA_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.local/share"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_local_home() {
    koopa_print "${HOME:?}/.local"
    return 0
}

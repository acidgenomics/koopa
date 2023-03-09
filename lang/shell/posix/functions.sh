#!/bin/sh
# shellcheck disable=all

_koopa_activate_alacritty() {
    local conf_file color_file color_mode pattern prefix replacement
    _koopa_is_alacritty || return 0
    prefix="$(_koopa_xdg_config_home)/alacritty"
    [ -d "$prefix" ] || return 0
    conf_file="${prefix}/alacritty.yml"
    [ -f "$conf_file" ] || return 0
    color_mode="$(_koopa_color_mode)"
    color_file_bn="colors-${color_mode}.yml"
    color_file="${prefix}/${color_file_bn}"
    [ -f "$color_file" ] || return 0
    if ! grep -q "$color_file_bn" "$conf_file"
    then
        pattern="^  - \"~/\.config/alacritty/colors.*\.yml\"$"
        replacement="  - \"~/.config/alacritty/${color_file_bn}\""
        perl -i -l -p \
            -e "s|${pattern}|${replacement}|" \
            "$conf_file"
    fi
    if [ -f "${prefix}/colors.yml" ]
    then
        rm "${prefix}/colors.yml"
    fi
    return 0
}

_koopa_activate_aliases() {
    local file
    _koopa_activate_coreutils_aliases
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias R='R --no-restore --no-save --quiet'
    alias asdf='_koopa_alias_asdf'
    alias black='black --line-length=79'
    alias br-size='br --sort-by-size'
    alias br='_koopa_alias_broot'
    alias bucket='_koopa_alias_bucket'
    alias c='clear'
    alias cls='_koopa_alias_colorls'
    alias cm='chezmoi'
    alias d='clear; cd -; l'
    alias doom-emacs='_koopa_doom_emacs'
    alias e='exit'
    alias emacs-vanilla='_koopa_alias_emacs_vanilla'
    alias emacs='_koopa_alias_emacs'
    alias fd='fd --case-sensitive --no-ignore'
    alias fvim='vim "$(fzf)"'
    alias g='git'
    alias glances='_koopa_alias_glances'
    alias h='history'
    alias j='z'
    alias k='_koopa_alias_k'
    alias kb='_koopa_alias_kb'
    alias kdev='_koopa_alias_kdev'
    alias kp='_koopa_alias_kp'
    alias l.='l -d .*'
    alias l1='l -1'
    alias l='_koopa_alias_l'
    alias la='l -a'
    alias lh='l | head'
    alias ll='la -l'
    alias lt='l | tail'
    alias nvim-fzf='_koopa_alias_nvim_fzf'
    alias nvim-vanilla='_koopa_alias_nvim_vanilla'
    alias prelude-emacs='_koopa_prelude_emacs'
    alias pyenv='_koopa_alias_pyenv'
    alias q='exit'
    alias radian='radian --no-restore --no-save --quiet'
    alias rbenv='_koopa_alias_rbenv'
    alias rg='rg --case-sensitive --no-ignore'
    alias ronn='ronn --roff'
    alias sha256='_koopa_alias_sha256'
    alias spacemacs='_koopa_spacemacs'
    alias spacevim='_koopa_spacevim'
    alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias vim-fzf='_koopa_alias_vim_fzf'
    alias vim-vanilla='_koopa_alias_vim_vanilla'
    alias week='_koopa_alias_week'
    alias z='_koopa_alias_zoxide'
    file="${HOME:?}/.aliases"
    [ -f "$file" ] && . "$file"
    file="${HOME:?}/.aliases-private"
    [ -f "$file" ] && . "$file"
    return 0
}

_koopa_activate_asdf() {
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_asdf_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/libexec/asdf.sh"
    [ -r "$script" ] || return 0
    _koopa_is_alias 'asdf' && unalias 'asdf'
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_bat() {
    local color_mode conf_file prefix
    [ -x "$(_koopa_bin_prefix)/bat" ] || return 0
    prefix="$(_koopa_xdg_config_home)/bat"
    [ -d "$prefix" ] || return 0
    color_mode="$(_koopa_color_mode)"
    conf_file="${prefix}/config-${color_mode}"
    [ -f "$conf_file" ] || return 0
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}

_koopa_activate_bcbio_nextgen() {
    local prefix
    prefix="$(_koopa_bcbio_nextgen_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_end "${prefix}/tools/bin"
    return 0
}

_koopa_activate_bottom() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    [ -x "$(_koopa_bin_prefix)/btm" ] || return 0
    prefix="$(_koopa_xdg_config_home)/bottom"
    [ -d "$prefix" ] || return 0
    color_mode="$(_koopa_color_mode)"
    source_bn="bottom-${color_mode}.toml"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/bottom.toml"
    if [ -h "$target_file" ] && _koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}

_koopa_activate_broot() {
    local config_dir nounset script shell
    [ -x "$(_koopa_bin_prefix)/broot" ] || return 0
    shell="$(_koopa_shell_name)"
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
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_ca_certificates() {
    local prefix ssl_cert_file
    prefix="$(_koopa_opt_prefix)/ca-certificates"
    [ -d "$prefix" ] || return 0
    prefix="$(_koopa_realpath "$prefix")"
    ssl_cert_file="${prefix}/share/ca-certificates/cacert.pem"
    [ -f "$ssl_cert_file" ] || return 0
    export SSL_CERT_FILE="$ssl_cert_file"
    return 0
}

_koopa_activate_color_mode() {
    if [ -z "${KOOPA_COLOR_MODE:-}" ]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [ -n "${KOOPA_COLOR_MODE:-}" ]
    then
        export KOOPA_COLOR_MODE
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}

_koopa_activate_completion() {
    local file koopa_prefix shell
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
        [ -f "$file" ] && . "$file"
    done
    return 0
}

_koopa_activate_conda() {
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_conda_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_is_alias 'mamba' && unalias 'mamba'
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    . "$script"
    if [ "${CONDA_DEFAULT_ENV:-}" = 'base' ] && \
        [ "${CONDA_SHLVL:-0}" -eq 1 ]
    then
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_coreutils_aliases() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    if [ -x "${bin_prefix}/gcat" ]
    then
        alias cat='gcat'
    fi
    if [ -x "${bin_prefix}/gcp" ]
    then
        alias gcp='gcp --interactive --recursive --verbose'
        alias cp='gcp'
    fi
    if [ -x "${bin_prefix}/gcut" ]
    then
        alias cut='gcut'
    fi
    if [ -x "${bin_prefix}/gdf" ]
    then
        alias df='gdf'
    fi
    if [ -x "${bin_prefix}/gdir" ]
    then
        alias dir='gdir'
    fi
    if [ -x "${bin_prefix}/gecho" ]
    then
        alias echo='gecho'
    fi
    if [ -x "${bin_prefix}/gegrep" ]
    then
        alias egrep='gegrep'
    fi
    if [ -x "${bin_prefix}/gfgrep" ]
    then
        alias fgrep='gfgrep'
    fi
    if [ -x "${bin_prefix}/gfind" ]
    then
        alias find='gfind'
    fi
    if [ -x "${bin_prefix}/ggrep" ]
    then
        alias grep='ggrep'
    fi
    if [ -x "${bin_prefix}/ghead" ]
    then
        alias head='ghead'
    fi
    if [ -x "${bin_prefix}/gln" ]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
        alias ln='gln'
    fi
    if [ -x "${bin_prefix}/gls" ]
    then
        alias ls='gls'
    fi
    if [ -x "${bin_prefix}/gmd5sum" ]
    then
        alias md5sum='gmd5sum'
    fi
    if [ -x "${bin_prefix}/gmkdir" ]
    then
        alias gmkdir='gmkdir --parents --verbose'
        alias mkdir='gmkdir'
    fi
    if [ -x "${bin_prefix}/gmv" ]
    then
        alias gmv='gmv --interactive --verbose'
        alias mv='gmv'
    fi
    if [ -x "${bin_prefix}/greadlink" ]
    then
        alias readlink='greadlink'
    fi
    if [ -x "${bin_prefix}/grealpath" ]
    then
        alias realpath='grealpath'
    fi
    if [ -x "${bin_prefix}/grm" ]
    then
        alias grm='grm --interactive=once --verbose'
        alias rm='grm'
    fi
    if [ -x "${bin_prefix}/gsed" ]
    then
        alias sed='gsed'
    fi
    if [ -x "${bin_prefix}/gsha256sum" ]
    then
        alias sha256sum='gsha256sum'
    fi
    if [ -x "${bin_prefix}/gstat" ]
    then
        alias stat='gstat'
    fi
    if [ -x "${bin_prefix}/gtail" ]
    then
        alias tail='gtail'
    fi
    if [ -x "${bin_prefix}/gtar" ]
    then
        alias tar='gtar'
    fi
    if [ -x "${bin_prefix}/gtouch" ]
    then
        alias touch='gtouch'
    fi
    if [ -x "${bin_prefix}/gtr" ]
    then
        alias tr='gtr'
    fi
    if [ -x "${bin_prefix}/gwhich" ]
    then
        alias which='gwhich'
    fi
    if [ -x "${bin_prefix}/gxargs" ]
    then
        alias xargs='gxargs'
    fi
    return 0
}

_koopa_activate_delta() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    [ -x "$(_koopa_bin_prefix)/delta" ] || return 0
    prefix="$(_koopa_xdg_config_home)/delta"
    [ -d "$prefix" ] || return 0
    color_mode="$(_koopa_color_mode)"
    source_bn="theme-${color_mode}.gitconfig"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/theme.gitconfig"
    if [ -h "$target_file" ] && _koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}

_koopa_activate_difftastic() {
    [ -x "$(_koopa_bin_prefix)/difft" ] || return 0
    DFT_BACKGROUND="$(_koopa_color_mode)"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}

_koopa_activate_dircolors() {
    [ -n "${SHELL:-}" ] || return 0
    local dircolors
    dircolors="$(_koopa_bin_prefix)/gdircolors"
    [ -x "$dircolors" ] || return 0
    local color_mode config_prefix dircolors_file
    config_prefix="$(_koopa_xdg_config_home)/dircolors"
    color_mode="$(_koopa_color_mode)"
    dircolors_file="${config_prefix}/dircolors-${color_mode}"
    [ -f "$dircolors_file" ] || return 0
    eval "$("$dircolors" "$dircolors_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    return 0
}

_koopa_activate_fzf() {
    [ -x "$(_koopa_bin_prefix)/fzf" ] || return 0
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}

_koopa_activate_gcc_colors() {
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

_koopa_activate_google_cloud_sdk() {
    local python
    python="$(_koopa_bin_prefix)/python3.10"
    [ -x "$python" ] || return 0
    CLOUDSDK_PYTHON="$python"
    export CLOUDSDK_PYTHON
    return 0
}

_koopa_activate_homebrew() {
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    [ -x "${prefix}/bin/brew" ] || return 0
    [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ] && \
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ] && \
        export HOMEBREW_INSTALL_CLEANUP=1
    [ -z "${HOMEBREW_NO_ANALYTICS:-}" ] && \
        export HOMEBREW_NO_ANALYTICS=1
    [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ] && \
        export HOMEBREW_NO_ENV_HINTS=1
    return 0
}

_koopa_activate_julia() {
    local depot_path num_threads
    [ -x "$(_koopa_bin_prefix)/julia" ] || return 0
    depot_path="$(_koopa_julia_packages_prefix)"
    num_threads="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH="$depot_path"
    export JULIA_NUM_THREADS="$num_threads"
    return 0
}

_koopa_activate_kitty() {
    local color_mode prefix source_bn source_file target_file target_link_bn
    _koopa_is_kitty || return 0
    prefix="$(_koopa_xdg_config_home)/kitty"
    [ -d "$prefix" ] || return 0
    color_mode="$(_koopa_color_mode)"
    source_bn="theme-${color_mode}.conf"
    source_file="${prefix}/${source_bn}"
    [ -f "$source_file" ] || return 0
    target_file="${prefix}/current-theme.conf"
    if [ -h "$target_file" ] && _koopa_is_installed 'readlink'
    then
        target_link_bn="$(readlink "$target_file")"
        [ "$target_link_bn" = "$source_bn" ] && return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}

_koopa_activate_lesspipe() {
    local lesspipe
    lesspipe="$(_koopa_bin_prefix)/lesspipe.sh"
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

_koopa_activate_mcfly() {
    local color_mode nounset shell
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    [ -x "$(_koopa_bin_prefix)/mcfly" ] || return 0
    _koopa_is_root && return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    color_mode="$(_koopa_color_mode)"
    [ "$color_mode" = 'light' ] && export MCFLY_LIGHT=true
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
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$(mcfly init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_micromamba() {
    if [ -z "${MAMBA_ROOT_PREFIX:-}" ]
    then
        export MAMBA_ROOT_PREFIX="${HOME:?}/.mamba"
    fi
    return 0
}

_koopa_activate_path_helper() {
    local path_helper
    path_helper='/usr/libexec/path_helper'
    [ -x "$path_helper" ] || return 0
    eval "$("$path_helper" -s)"
    return 0
}

_koopa_activate_pipx() {
    local prefix
    [ -x "$(_koopa_bin_prefix)/pipx" ] || return 0
    prefix="$(_koopa_pipx_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "$prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${prefix}/bin"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}

_koopa_activate_pyenv() {
    local nounset prefix script
    [ -n "${PYENV_ROOT:-}" ] && return 0
    [ -x "$(_koopa_bin_prefix)/pyenv" ] || return 0
    prefix="$(_koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_python() {
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

_koopa_activate_rbenv() {
    local nounset prefix script
    [ -n "${RBENV_ROOT:-}" ] && return 0
    [ -x "$(_koopa_bin_prefix)/rbenv" ] || return 0
    prefix="$(_koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_activate_ruby() {
    local prefix
    prefix="${HOME:?}/.gem"
    export GEM_HOME="$prefix"
    _koopa_add_to_path_start "${prefix}/bin"
    return 0
}

_koopa_activate_secrets() {
    local file
    file="${1:-}"
    [ -z "$file" ] && file="${HOME:?}/.secrets"
    [ -r "$file" ] || return 0
    . "$file"
    return 0
}

_koopa_activate_ssh_key() {
    local key
    _koopa_is_linux || return 0
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

_koopa_activate_starship() {
    local nounset shell
    [ -x "$(_koopa_bin_prefix)/starship" ] || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    unset -v STARSHIP_SESSION_KEY STARSHIP_SHELL
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && return 0
    eval "$(starship init "$shell")"
    return 0
}

_koopa_activate_tealdeer() {
    [ -x "$(_koopa_bin_prefix)/tldr" ] || return 0
    if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    then
        TEALDEER_CACHE_DIR="$(_koopa_xdg_cache_home)/tealdeer"
    fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "${TEALDEER_CACHE_DIR:?}" >/dev/null
    fi
    export TEALDEER_CACHE_DIR TEALDEER_CONFIG_DIR
    return 0
}

_koopa_activate_today_bucket() {
    local bucket_dir today_bucket today_link
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    [ -d "$bucket_dir" ] || return 0
    today_bucket="$(date '+%Y/%m/%d')"
    today_link="${HOME:?}/today"
    if _koopa_str_detect_posix \
        "$(_koopa_realpath "$today_link")" \
        "$today_bucket"
    then
        return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    mkdir -p "${bucket_dir}/${today_bucket}" >/dev/null
    ln -fns "${bucket_dir}/${today_bucket}" "$today_link" >/dev/null
    return 0
}

_koopa_activate_xdg() {
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="$(_koopa_xdg_cache_home)"
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="$(_koopa_xdg_config_dirs)"
    fi
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="$(_koopa_xdg_config_home)"
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="$(_koopa_xdg_data_dirs)"
    fi
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="$(_koopa_xdg_data_home)"
    fi
    export XDG_CACHE_HOME XDG_CONFIG_DIRS XDG_CONFIG_HOME \
        XDG_DATA_DIRS XDG_DATA_HOME
    return 0
}


_koopa_activate_zoxide() {
    local nounset shell zoxide
    zoxide="$(_koopa_bin_prefix)/zoxide"
    [ -x "$zoxide" ] || return 0
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
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$zoxide" init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

_koopa_add_config_link() {
    local config_prefix dest_file dest_name source_file
    config_prefix="$(_koopa_config_prefix)"
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    _koopa_is_alias 'rm' && unalias 'rm'
    while [ "$#" -ge 2 ]
    do
        source_file="${1:?}"
        dest_name="${2:?}"
        shift 2
        [ -e "$source_file" ] || continue
        dest_file="${config_prefix}/${dest_name}"
        if [ -L "$dest_file" ] && [ -e "$dest_file" ]
        then
            continue
        fi
        mkdir -p "$config_prefix" >/dev/null
        rm -fr "$dest_file" >/dev/null
        ln -fns "$source_file" "$dest_file" >/dev/null
    done
    return 0
}

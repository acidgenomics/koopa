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

_koopa_add_to_manpath_end() {
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_manpath_start() {
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_start "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_path_end() {
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(_koopa_add_to_path_string_end "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_path_start() {
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(_koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_path_string_end() {
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if _koopa_str_detect_posix "$str" ":${dir}"
    then
        str="$(_koopa_remove_from_path_string "$str" "${dir}")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${str}:${dir}"
    fi
    _koopa_print "$str"
    return 0
}

_koopa_add_to_path_string_start() {
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if _koopa_str_detect_posix "$str" "${dir}:"
    then
        str="$(_koopa_remove_from_path_string "$str" "${dir}")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${dir}:${str}"
    fi
    _koopa_print "$str"
    return 0
}

_koopa_alias_asdf() {
    _koopa_is_alias 'asdf' && unalias 'asdf'
    _koopa_activate_asdf
    asdf "$@"
}

_koopa_alias_broot() {
    _koopa_is_alias 'br' && unalias 'br'
    _koopa_activate_broot
    br "$@"
}

_koopa_alias_bucket() {
    local prefix
    prefix="${HOME:?}/today"
    [ -d "$prefix" ] || return 1
    cd "$prefix" || return 1
    ls
}

_koopa_alias_colorls() {
    local color_flag color_mode
    color_mode="$(_koopa_color_mode)"
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

_koopa_alias_conda() {
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_activate_conda
    conda "$@"
}

_koopa_alias_emacs_vanilla() {
    emacs --no-init-file --no-window-system "$@"
}

_koopa_alias_glances() {
    local color_mode
    color_mode="$(_koopa_color_mode)"
    case "$color_mode" in
        'light')
            set -- '--theme-white' "$@"
            ;;
    esac
    glances \
        --config "${HOME}/.config/glances/glances.conf" \
        "$@"
    return 0
}

_koopa_alias_k() {
    cd "$(_koopa_koopa_prefix)" || return 1
}

_koopa_alias_kb() {
    cd "$(_koopa_koopa_prefix)/lang/shell/bash" || return 1
}

_koopa_alias_kdev() {
    local bash bin_prefix env koopa_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    koopa_prefix="$(_koopa_koopa_prefix)"
    bash="${bin_prefix}/bash"
    env="${bin_prefix}/genv"
    [ ! -x "$bash" ] && bash='/usr/bin/bash'
    [ ! -x "$env" ] && env='/usr/bin/env'
    [ -x "$bash" ] || return 1
    [ -x "$env" ] || return 1
    "$env" -i \
        HOME="${HOME:?}" \
        KOOPA_ACTIVATE=0 \
        PATH='/usr/bin:/bin' \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TMPDIR="${TMPDIR:-/tmp}" \
        "$bash" \
            --noprofile \
            --rcfile "${koopa_prefix}/lang/shell/bash/include/header.sh" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}

_koopa_alias_kp() {
    cd "$(_koopa_koopa_prefix)/lang/shell/posix" || return 1
}

_koopa_alias_l() {
    if _koopa_is_installed 'exa'
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

_koopa_alias_mamba() {
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_is_alias 'mamba' && unalias 'mamba'
    _koopa_activate_conda
    mamba "$@"
}

_koopa_alias_nvim_fzf() {
    nvim "$(fzf)"
}

_koopa_alias_nvim_vanilla() {
    nvim -u 'NONE' "$@"
}

_koopa_alias_pyenv() {
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    _koopa_activate_pyenv
    pyenv "$@"
}

_koopa_alias_rbenv() {
    _koopa_is_alias 'rbenv' && unalias 'rbenv'
    _koopa_activate_rbenv
    rbenv "$@"
}

_koopa_alias_sha256() {
    shasum -a 256 "$@"
}

_koopa_alias_tmux_vanilla() {
    tmux -f '/dev/null'
}

_koopa_alias_today() {
    date '+%Y-%m-%d'
}

_koopa_alias_vim_fzf() {
    vim "$(fzf)"
}

_koopa_alias_vim_vanilla() {
    vim -i 'NONE' -u 'NONE' -U 'NONE' "$@"
}

_koopa_alias_week() {
    date '+%V'
}

_koopa_alias_zoxide() {
    _koopa_is_alias 'z' && unalias 'z'
    _koopa_activate_zoxide
    z "$@"
}

_koopa_anaconda_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/anaconda"
    return 0
}

_koopa_arch() {
    local x
    x="$(uname -m)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_asdf_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/asdf"
    return 0
}

_koopa_aspera_connect_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/aspera-connect"
    return 0
}

_koopa_bcbio_nextgen_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/bcbio-nextgen"
    return 0
}

_koopa_bin_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/bin"
    return 0
}

_koopa_boolean_nounset() {
    local bool
    if _koopa_is_set_nounset
    then
        bool=1
    else
        bool=0
    fi
    _koopa_print "$bool"
    return 0
}

_koopa_color_mode() {
    local str
    str="${KOOPA_COLOR_MODE:-}"
    if [ -n "$str" ]
    then
        _koopa_print "$str"
        return 0
    fi
    if [ -z "$str" ]
    then
        if _koopa_is_macos
        then
            if _koopa_macos_is_dark_mode
            then
                str='dark'
            else
                str='light'
            fi
        fi
    fi
    [ -n "$str" ] || return 0
    _koopa_print "$str"
    return 0
}

_koopa_conda_env_name() {
    local x
    x="${CONDA_DEFAULT_ENV:-}"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_conda_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/conda"
    return 0
}

_koopa_config_prefix() {
    _koopa_print "$(_koopa_xdg_config_home)/koopa"
    return 0
}

_koopa_cpu_count() {
    local bin_prefix getconf nproc num sysctl
    [ "$#" -eq 0 ] || return 1
    num="${KOOPA_CPU_COUNT:-}"
    if [ -n "$num" ]
    then
        _koopa_print "$num"
        return 0
    fi
    bin_prefix="$(_koopa_bin_prefix)"
    nproc="${bin_prefix}/gnproc"
    if [ -x "$nproc" ]
    then
        num="$("$nproc" --all)"
    elif _koopa_is_macos
    then
        sysctl='/usr/sbin/sysctl'
        [ -x "$sysctl" ] || return 1
        num="$("$sysctl" -n 'hw.ncpu')"
    elif _koopa_is_linux
    then
        getconf='/usr/bin/getconf'
        [ -x "$getconf" ] || return 1
        num="$("$getconf" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    _koopa_print "$num"
    return 0
}

_koopa_default_shell_name() {
    local shell str
    shell="${SHELL:-sh}"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_docker_prefix() {
    _koopa_print "$(_koopa_config_prefix)/docker"
    return 0
}

_koopa_docker_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/docker-private"
    return 0
}

_koopa_doom_emacs_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/doom"
    return 0
}

_koopa_doom_emacs() {
    local prefix
    prefix="$(_koopa_doom_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "Doom Emacs is not installed at '${prefix}'."
        return 1
    fi
    _koopa_emacs --with-profile 'doom' "$@"
    return 0
}

_koopa_dotfiles_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_duration_start() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    [ -x "${bin_prefix}/date" ] || return 0
    KOOPA_DURATION_START="$(date -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

_koopa_duration_stop() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
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
    duration="$(_koopa_print "${stop}-${start}" | bc)"
    [ -n "$duration" ] || return 1
    _koopa_dl "$key" "${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

_koopa_emacs_prefix() {
    _koopa_print "${HOME:?}/.emacs.d"
    return 0
}

_koopa_emacs() {
    local emacs prefix
    prefix="${HOME:?}/.emacs.d"
    if [ ! -L "$prefix" ]
    then
        _koopa_print "Chemacs is not linked at '${prefix}'."
        return 1
    fi
    if [ ! -f "${prefix}/chemacs.el" ]
    then
        _koopa_print "Chemacs is not configured at '${prefix}'."
        return 1
    fi
    if _koopa_is_macos
    then
        emacs="$(_koopa_macos_emacs)"
    else
        emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -e "$emacs" ]
    then
        _koopa_print "Emacs not installed at '${emacs}'."
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ]
    then
        TERM='xterm-24bit' "$emacs" "$@" >/dev/null 2>&1
    else
        "$emacs" "$@" >/dev/null 2>&1
    fi
    return 0
}

_koopa_ensembl_perl_api_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

_koopa_export_editor() {
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR="$(_koopa_bin_prefix)/vim"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

_koopa_export_gnupg() {
    [ -z "${GPG_TTY:-}" ] || return 0
    _koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}

_koopa_export_history() {
    local shell
    shell="$(_koopa_shell_name)"
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.${shell}_history"
    fi
    export HISTFILE
    if [ ! -f "$HISTFILE" ] \
        && [ -e "${HOME:-}" ] \
        && _koopa_is_installed 'touch'
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

_koopa_export_koopa_cpu_count() {
    KOOPA_CPU_COUNT="$(_koopa_cpu_count)"
    export KOOPA_CPU_COUNT
    return 0
}

_koopa_export_koopa_shell() {
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(_koopa_locate_shell)"
    export KOOPA_SHELL
    return 0
}

_koopa_export_pager() {
    local less
    [ -n "${PAGER:-}" ] && return 0
    less="$(_koopa_bin_prefix)/less"
    [ -x "$less" ] || return 0
    export PAGER="${less} -R"
    return 0
}

_koopa_expr() {
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_git_branch() {
    local branch
    _koopa_is_git_repo || return 0
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
    _koopa_print "$branch"
    return 0
}

_koopa_git_repo_has_unstaged_changes() {
    local x
    git update-index --refresh >/dev/null 2>&1
    x="$(git diff-index 'HEAD' -- 2>/dev/null)"
    [ -n "$x" ]
}

_koopa_git_repo_needs_pull_or_push() {
    local rev_1 rev_2
    rev_1="$(git rev-parse 'HEAD' 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}

_koopa_go_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/go"
    return 0
}

_koopa_group_id() {
    id -g
    return 0
}

_koopa_group() {
    id -gn
}

_koopa_homebrew_cellar_prefix() {
    _koopa_print "$(_koopa_homebrew_prefix)/Cellar"
    return 0
}

_koopa_homebrew_opt_prefix() {
    _koopa_print "$(_koopa_homebrew_prefix)/opt"
    return 0
}

_koopa_homebrew_prefix() {
    local arch x
    x="${HOMEBREW_PREFIX:-}"
    if [ -z "$x" ]
    then
        if _koopa_is_installed 'brew'
        then
            x="$(brew --prefix)"
        elif _koopa_is_macos
        then
            arch="$(_koopa_arch)"
            case "$arch" in
                'arm'*)
                    x='/opt/homebrew'
                    ;;
                'x86'*)
                    x='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            x='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -d "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_host_id() {
    local id
    if [ -r '/etc/hostname' ]
    then
        id="$(cat '/etc/hostname')"
    elif _koopa_is_installed 'hostname'
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
    _koopa_print "$id"
    return 0
}

_koopa_hostname() {
    local x
    x="$(uname -n)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_is_alacritty() {
    [ -n "${ALACRITTY_SOCKET:-}" ]
}

_koopa_is_alias() {
    local cmd str
    for cmd in "$@"
    do
        _koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        _koopa_str_detect_posix "$str" ' is aliased to ' && continue
        _koopa_str_detect_posix "$str" ' is an alias for ' && continue
        return 1
    done
    return 0
}

_koopa_is_alpine() {
    _koopa_is_os 'alpine'
}

_koopa_is_arch() {
    _koopa_is_os 'arch'
}

_koopa_is_debian_like() {
    _koopa_is_os_like 'debian'
}

_koopa_is_fedora_like() {
    _koopa_is_os_like 'fedora'
}

_koopa_is_git_repo_clean() {
    _koopa_is_git_repo || return 1
    _koopa_git_repo_has_unstaged_changes && return 1
    _koopa_git_repo_needs_pull_or_push && return 1
    return 0
}

_koopa_is_git_repo_top_level() {
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

_koopa_is_git_repo() {
    _koopa_is_git_repo_top_level '.' && return 0
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}

_koopa_is_installed() {
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

_koopa_is_interactive() {
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    _koopa_str_detect_posix "$-" 'i' && return 0
    _koopa_is_tty && return 0
    return 1
}

_koopa_is_kitty() {
    [ -n "${KITTY_PID:-}" ]
}

_koopa_is_linux() {
    [ "$(uname -s)" = 'Linux' ]
}

_koopa_is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

_koopa_is_opensuse() {
    _koopa_is_os 'opensuse'
}

_koopa_is_os_like() {
    local file id
    file='/etc/os-release'
    id="${1:?}"
    _koopa_is_os "$id" && return 0
    [ -r "$file" ] || return 1
    grep 'ID=' "$file" | grep -q "$id" && return 0
    grep 'ID_LIKE=' "$file" | grep -q "$id" && return 0
    return 1
}

_koopa_is_os() {
    [ "$(_koopa_os_id)" = "${1:?}" ]
}

_koopa_is_qemu() {
    local basename cmd real_cmd
    basename='basename'
    cmd="/proc/${$}/exe"
    [ -L "$cmd" ] || return 1
    real_cmd="$(_koopa_realpath "$cmd")"
    case "$("$basename" "$real_cmd")" in
        'qemu-'*)
            return 0
            ;;
    esac
    return 1
}

_koopa_is_rhel_like() {
    _koopa_is_os_like 'rhel'
}

_koopa_is_root() {
    [ "$(_koopa_user_id)" -eq 0 ]
}

_koopa_is_set_nounset() {
    _koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

_koopa_is_subshell() {
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

_koopa_is_tty() {
    _koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_is_ubuntu_like() {
    _koopa_is_os_like 'ubuntu'
}

_koopa_is_user_install() {
    _koopa_str_detect_posix "$(_koopa_koopa_prefix)" "${HOME:?}"
}

_koopa_julia_packages_prefix() {
    _koopa_print "${HOME:?}/.julia"
}

_koopa_koopa_prefix() {
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_local_data_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)"
    return 0
}

_koopa_locate_shell() {
    local proc_file pid shell
    shell="${KOOPA_SHELL:-}"
    if [ -n "$shell" ]
    then
        _koopa_print "$shell"
        return 0
    fi
    pid="${$}"
    proc_file="/proc/${pid}/exe"
    if [ -x "$proc_file" ] && ! _koopa_is_qemu
    then
        shell="$(_koopa_realpath "$proc_file")"
    elif _koopa_is_installed 'ps'
    then
        shell="$( \
            ps -p "$pid" -o 'comm=' \
            | sed 's/^-//' \
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
    _koopa_print "$shell"
    return 0
}

_koopa_macos_activate_cli_colors() {
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    return 0
}

_koopa_macos_emacs() {
    _koopa_print '/usr/local/bin/emacs'
    return 0
}

_koopa_macos_homebrew_cask_prefix() {
    _koopa_print "$(_koopa_homebrew_prefix)/Caskroom"
    return 0
}

_koopa_macos_is_dark_mode() {
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}

_koopa_macos_is_light_mode() {
    ! _koopa_macos_is_dark_mode
}

_koopa_macos_julia_prefix() {
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
    _koopa_print "$prefix"
}

_koopa_macos_os_version() {
    local x
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_macos_python_prefix() {
    _koopa_print '/Library/Frameworks/Python.framework/Versions/Current'
}

_koopa_macos_r_prefix() {
    _koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
}

_koopa_major_minor_patch_version() {
    local version x
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_version() {
    local version x
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_version() {
    local version x
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | cut -d '.' -f '1' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_make_prefix() {
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif _koopa_is_user_install
    then
        prefix="$(_koopa_xdg_local_home)"
    else
        prefix='/usr/local'
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_monorepo_prefix() {
    _koopa_print "${HOME:?}/monorepo"
    return 0
}

_koopa_openjdk_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/openjdk"
    return 0
}

_koopa_opt_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/opt"
    return 0
}

_koopa_os_id() {
    local string
    string="$(_koopa_os_string | cut -d '-' -f '1')"
    [ -n "$string" ] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_os_string() {
    local id release_file string version
    if _koopa_is_macos
    then
        id='macos'
        version="$(_koopa_major_version "$(_koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            id="$( \
                awk -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "$release_file" \
                | tr -d '"' \
            )"
            version="$( \
                awk -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "$release_file" \
                | tr -d '"' \
            )"
            if [ -n "$version" ]
            then
                version="$(_koopa_major_version "$version")"
            else
                version='rolling'
            fi
        else
            id='linux'
            version=''
        fi
    fi
    [ -n "$id" ] ||  return 1
    string="$id"
    [ -n "$version" ] && string="${string}-${version}"
    _koopa_print "$string"
    return 0
}

_koopa_pipx_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/pipx"
    return 0
}

_koopa_prelude_emacs_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/prelude"
    return 0
}

_koopa_prelude_emacs() {
    local prefix
    prefix="$(_koopa_prelude_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "Prelude Emacs is not installed at '${prefix}'."
        return 1
    fi
    _koopa_emacs --with-profile 'prelude' "$@"
    return 0
}

_koopa_print() {
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

_koopa_pyenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}

_koopa_python_venv_name() {
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    x="${x##*/}"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_python_virtualenvs_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/python-virtualenvs"
    return 0
}

_koopa_rbenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/rbenv"
    return 0
}

_koopa_realpath() {
    local x
    x="$(readlink -f "$@")"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_remove_from_path_string() {
    local dir str1 str2
    str1="${1:?}"
    dir="${2:?}"
    str2="$( \
        _koopa_print "$str1" \
            | sed \
                -e "s|^${dir}:||g" \
                -e "s|:${dir}:|:|g" \
                -e "s|:${dir}\$||g" \
        )"
    [ -n "$str2" ] || return 1
    _koopa_print "$str2"
    return 0
}

_koopa_rust_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/rust"
    return 0
}

_koopa_scripts_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_shell_name() {
    local shell str
    shell="$(_koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_spacemacs_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacemacs"
    return 0
}

_koopa_spacemacs() {
    local prefix
    prefix="$(_koopa_spacemacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "Spacemacs is not installed at '${prefix}'."
        return 1
    fi
    _koopa_emacs --with-profile 'spacemacs' "$@"
    return 0
}

_koopa_spacevim_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacevim"
    return 0
}

_koopa_spacevim() {
    local gvim prefix vim vimrc
    vim='vim'
    if _koopa_is_macos
    then
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        if [ -x "$gvim" ]
        then
            vim="$gvim"
        fi
    fi
    prefix="$(_koopa_spacevim_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_print "SpaceVim is not installed at '${prefix}'."
        return 1
    fi
    vimrc="${prefix}/vimrc"
    if [ ! -f "$vimrc" ]
    then
        _koopa_print "No vimrc file at '${vimrc}'."
        return 1
    fi
    _koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
}

_koopa_str_detect_posix() {
    unset test
    test "${1#*"$2"}" != "$1"
}

_koopa_today() {
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_umask() {
    umask 0002
    return 0
}

_koopa_user_id() {
    id -u
}

_koopa_user() {
    id -un
}

_koopa_xdg_cache_home() {
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_config_dirs() {
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_config_home() {
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_data_dirs() {
    local x
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        x='/usr/local/share:/usr/share'
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_data_home() {
    local x
    x="${XDG_DATA_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.local/share"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_local_home() {
    _koopa_print "${HOME:?}/.local"
    return 0
}

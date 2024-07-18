#!/bin/sh
# shellcheck disable=all

_koopa_activate_alacritty() {
    _koopa_is_alacritty || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/alacritty"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_conf_file="${__kvar_prefix}/alacritty.toml"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v __kvar_conf_file __kvar_prefix
        return 0
    fi
    __kvar_color_file_bn="colors-$(_koopa_color_mode).toml"
    __kvar_color_file="${__kvar_prefix}/${__kvar_color_file_bn}"
    if [ ! -f "$__kvar_color_file" ]
    then
        unset -v \
            __kvar_color_file \
            __kvar_color_file_bn \
            __kvar_conf_file \
            __kvar_prefix
        return 0
    fi
    if ! grep -q "$__kvar_color_file_bn" "$__kvar_conf_file"
    then
        __kvar_pattern='colors-.+\.toml'
        __kvar_replacement="${__kvar_color_file_bn}"
        perl -i -l -p \
            -e "s|${__kvar_pattern}|${__kvar_replacement}|" \
            "$__kvar_conf_file"
    fi
    unset -v \
        __kvar_color_file \
        __kvar_color_file_bn \
        __kvar_conf_file \
        __kvar_pattern \
        __kvar_prefix \
        __kvar_replacement
    return 0
}

_koopa_activate_aliases() {
    _koopa_is_interactive || return 0
    _koopa_activate_coreutils_aliases
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_xdg_data_home="$(_koopa_xdg_data_home)"
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias c='clear'
    alias d='clear; cd -; l'
    alias e='exit'
    alias g='git'
    alias h='history'
    alias k='_koopa_alias_k'
    alias kb='_koopa_alias_kb'
    alias kbs='_koopa_alias_kbs'
    alias kdev='_koopa_alias_kdev'
    alias l='_koopa_alias_l'
    alias l.='l -d .*'
    alias l1='ls -1'
    alias la='l -a'
    alias lh='l | head'
    alias ll='l -l'
    alias lt='l | tail'
    alias q='exit'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias week='_koopa_alias_week'
    if [ -x "${__kvar_bin_prefix}/asdf" ]
    then
        alias asdf='_koopa_activate_asdf; asdf'
    fi
    if [ -x "${__kvar_bin_prefix}/black" ]
    then
        alias black='black --line-length=79'
    fi
    if [ -x "${__kvar_bin_prefix}/broot" ]
    then
        alias br='_koopa_activate_broot; br'
        alias br-size='br --sort-by-size'
    fi
    if [ -x "${__kvar_bin_prefix}/chezmoi" ]
    then
        alias cm='chezmoi'
    fi
    if [ -x "${__kvar_bin_prefix}/colorls" ]
    then
        alias cls='_koopa_alias_colorls'
    fi
    if [ -x "${__kvar_bin_prefix}/conda" ]
    then
        alias conda='_koopa_activate_conda; conda'
    fi
    if [ -x '/usr/local/bin/emacs' ] || \
        [ -x '/usr/bin/emacs' ] || \
        [ -x "${__kvar_bin_prefix}/emacs" ]
    then
        alias emacs='_koopa_alias_emacs'
        alias emacs-vanilla='_koopa_alias_emacs_vanilla'
        if [ -d "${__kvar_xdg_data_home}/doom" ]
        then
            alias doom-emacs='_koopa_doom_emacs'
        fi
        if [ -d "${__kvar_xdg_data_home}/prelude" ]
        then
            alias prelude-emacs='_koopa_prelude_emacs'
        fi
        if [ -d "${__kvar_xdg_data_home}/spacemacs" ]
        then
            alias spacemacs='_koopa_spacemacs'
        fi
    fi
    if [ -x "${__kvar_bin_prefix}/fd" ]
    then
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    fi
    if [ -x "${__kvar_bin_prefix}/glances" ]
    then
        alias glances='_koopa_alias_glances'
    fi
    if [ -x "${__kvar_bin_prefix}/nvim" ]
    then
        alias nvim-vanilla='_koopa_alias_nvim_vanilla'
        if [ -x "${__kvar_bin_prefix}/fzf" ]
        then
            alias nvim-fzf='_koopa_alias_nvim_fzf'
        fi
    fi
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias pyenv='_koopa_activate_pyenv; pyenv'
    fi
    if [ -x "${__kvar_bin_prefix}/python3" ]
    then
        alias python3-dev='_koopa_alias_python3_dev'
    fi
    if [ -x '/usr/local/bin/R' ] || [ -x '/usr/bin/R' ]
    then
        alias R='R --no-restore --no-save --quiet'
    fi
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias radian='radian --no-restore --no-save --quiet'
    fi
    if [ -x "${__kvar_bin_prefix}/rbenv" ]
    then
        alias rbenv='_koopa_activate_rbenv; rbenv'
    fi
    if [ -x '/usr/bin/shasum' ]
    then
        alias sha256='_koopa_alias_sha256'
    fi
    if [ -x "${__kvar_bin_prefix}/tmux" ]
    then
        alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    fi
    if [ -x "${__kvar_bin_prefix}/vim" ]
    then
        alias vim-vanilla='_koopa_alias_vim_vanilla'
        if [ -x "${__kvar_bin_prefix}/fzf" ]
        then
            alias vim-fzf='_koopa_alias_vim_fzf'
        fi
        if [ -d "${__kvar_xdg_data_home}/spacevim" ]
        then
            alias spacevim='_koopa_spacevim'
        fi
    fi
    if [ -x "${__kvar_bin_prefix}/walk" ]
    then
        alias lk='_koopa_walk'
    fi
    if [ -x "${__kvar_bin_prefix}/zoxide" ]
    then
        alias z='_koopa_activate_zoxide; __zoxide_z'
        alias j='z'
    fi
    if [ -f "${HOME:?}/.aliases" ]
    then
        . "${HOME:?}/.aliases"
    fi
    if [ -f "${HOME:?}/.aliases-private" ]
    then
        . "${HOME:?}/.aliases-private"
    fi
    if [ -f "${HOME:?}/.aliases-work" ]
    then
        . "${HOME:?}/.aliases-work"
    fi
    unset -v __kvar_bin_prefix __kvar_xdg_data_home
    return 0
}

_koopa_activate_asdf() {
    __kvar_prefix="${1:-}"
    if [ -z "$__kvar_prefix" ]
    then
        __kvar_prefix="$(_koopa_asdf_prefix)"
    fi
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_script="${__kvar_prefix}/libexec/asdf.sh"
    if [ ! -r "$__kvar_script" ]
    then
        unset -v __kvar_prefix __kvar_script
        return 0
    fi
    _koopa_is_alias 'asdf' && unalias 'asdf'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    . "$__kvar_script"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v __kvar_nounset __kvar_prefix __kvar_script
    return 0
}

_koopa_activate_bat() {
    [ -x "$(_koopa_bin_prefix)/bat" ] || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/bat"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_conf_file="${__kvar_prefix}/config-$(_koopa_color_mode)"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v \
            __kvar_conf_file \
            __kvar_prefix
        return 0
    fi
    export BAT_CONFIG_PATH="$__kvar_conf_file"
    unset -v \
        __kvar_conf_file \
        __kvar_prefix
    return 0
}

_koopa_activate_bcbio_nextgen() {
    __kvar_prefix="$(_koopa_bcbio_nextgen_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    _koopa_add_to_path_end "${__kvar_prefix}/tools/bin"
    unset -v __kvar_prefix
    return 0
}

_koopa_activate_bottom() {
    [ -x "$(_koopa_bin_prefix)/btm" ] || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/bottom"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_source_bn="bottom-$(_koopa_color_mode).toml"
    __kvar_source_file="${__kvar_prefix}/${__kvar_source_bn}"
    if [ ! -f "$__kvar_source_file" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_source_bn \
            __kvar_source_file
        return 0
    fi
    __kvar_target_file="${__kvar_prefix}/bottom.toml"
    if [ -h "$__kvar_target_file" ] && _koopa_is_installed 'readlink'
    then
        __kvar_target_link_bn="$(readlink "$__kvar_target_file")"
        if [ "$__kvar_target_link_bn" = "$__kvar_source_bn" ]
        then
            unset -v \
                __kvar_prefix \
                __kvar_source_bn \
                __kvar_source_file \
                __kvar_target_file \
                __kvar_target_link_bn
            return 0
        fi
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$__kvar_source_file" "$__kvar_target_file" >/dev/null
    unset -v \
        __kvar_prefix \
        __kvar_source_bn \
        __kvar_source_file \
        __kvar_target_file \
        __kvar_target_link_bn
    return 0
}

_koopa_activate_broot() {
    [ -x "$(_koopa_bin_prefix)/broot" ] || return 0
    __kvar_config_dir="$(_koopa_xdg_config_home)/broot"
    if [ ! -d "$__kvar_config_dir" ]
    then
        unset -v __kvar_config_dir
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v \
                __kvar_config_dir \
                __kvar_shell
            return 0
            ;;
    esac
    __kvar_script="${__kvar_config_dir}/launcher/bash/br"
    if [ ! -f "$__kvar_script" ]
    then
        unset -v \
            __kvar_config_dir \
            __kvar_script \
            __kvar_shell \
        return 0
    fi
    _koopa_is_alias 'br' && unalias 'br'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    . "$__kvar_script"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_config_dir \
        __kvar_nounset \
        __kvar_script \
        __kvar_shell
    return 0
}

_koopa_activate_ca_certificates() {
    [ -n "${DEFAULT_CA_BUNDLE_PATH:-}" ] && return 0
    [ -n "${REQUESTS_CA_BUNDLE:-}" ] && return 0
    [ -n "${SSL_CERT_FILE:-}" ] && return 0
    __kvar_prefix="$(_koopa_opt_prefix)/ca-certificates"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_prefix="$(_koopa_realpath "$__kvar_prefix")"
    __kvar_file="${__kvar_prefix}/share/ca-certificates/cacert.pem"
    if [ ! -f "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_prefix
        return 0
    fi
    export DEFAULT_CA_BUNDLE_PATH="$__kvar_prefix"
    export REQUESTS_CA_BUNDLE="$__kvar_file"
    export SSL_CERT_FILE="$__kvar_file"
    unset -v __kvar_file __kvar_prefix
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
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v __kvar_shell
            return 0
            ;;
    esac
    __kvar_koopa_prefix="$(_koopa_koopa_prefix)"
    for __kvar_file in "${__kvar_koopa_prefix}/etc/completion/"*'.sh'
    do
        [ -f "$__kvar_file" ] && . "$__kvar_file"
    done
    unset -v \
        __kvar_file \
        __kvar_koopa_prefix \
        __kvar_shell
    return 0
}

_koopa_activate_conda() {
    __kvar_prefix="$(_koopa_conda_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_conda="${__kvar_prefix}/bin/conda"
    if [ ! -x "$__kvar_conda" ]
    then
        unset -v __kvar_conda __kvar_prefix
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            __kvar_shell='posix'
            ;;
    esac
    _koopa_is_alias 'conda' && unalias 'conda'
    __kvar_conda_setup="$("$__kvar_conda" "shell.${__kvar_shell}" 'hook')"
    eval "$__kvar_conda_setup"
    _koopa_is_function 'conda' || return 1
    unset -v \
        __kvar_conda \
        __kvar_conda_setup \
        __kvar_prefix
    return 0
}

_koopa_activate_coreutils_aliases() {
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    if [ -x "${__kvar_bin_prefix}/gcp" ]
    then
        alias gcp='gcp --interactive --recursive --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gln" ]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gmkdir" ]
    then
        alias gmkdir='gmkdir --parents --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/gmv" ]
    then
        alias gmv='gmv --interactive --verbose'
    fi
    if [ -x "${__kvar_bin_prefix}/grm" ]
    then
        alias grm='grm --interactive=once --verbose'
    fi
    unset -v __kvar_bin_prefix
    return 0
}

_koopa_activate_delta() {
    [ -x "$(_koopa_bin_prefix)/delta" ] || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/delta"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_source_bn="theme-$(_koopa_color_mode).gitconfig"
    __kvar_source_file="${__kvar_prefix}/${__kvar_source_bn}"
    if [ ! -f "$__kvar_source_file" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_source_bn \
            __kvar_source_file
        return 0
    fi
    __kvar_target_file="${__kvar_prefix}/theme.gitconfig"
    if [ -h "$__kvar_target_file" ] && _koopa_is_installed 'readlink'
    then
        __kvar_target_link_bn="$(readlink "$__kvar_target_file")"
        if [ "$__kvar_target_link_bn" = "$__kvar_source_bn" ]
        then
            unset -v \
                __kvar_prefix \
                __kvar_source_bn \
                __kvar_source_file \
                __kvar_target_file \
                __kvar_target_link_bn
            return 0
        fi
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$__kvar_source_file" "$__kvar_target_file" >/dev/null
    unset -v \
        __kvar_prefix \
        __kvar_source_bn \
        __kvar_source_file \
        __kvar_target_file \
        __kvar_target_link_bn
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
    __kvar_dircolors="$(_koopa_bin_prefix)/gdircolors"
    if [ ! -x "$__kvar_dircolors" ]
    then
        unset -v __kvar_dircolors
        return 0
    fi
    __kvar_prefix="$(_koopa_xdg_config_home)/dircolors"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v \
            __kvar_dircolors \
            __kvar_prefix
        return 0
    fi
    __kvar_conf_file="${__kvar_prefix}/dircolors-$(_koopa_color_mode)"
    if [ ! -f "$__kvar_conf_file" ]
    then
        unset -v \
            __kvar_conf_file \
            __kvar_dircolors \
            __kvar_prefix
        return 0
    fi
    eval "$("$__kvar_dircolors" "$__kvar_conf_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    unset -v \
        __kvar_conf_file \
        __kvar_dircolors \
        __kvar_prefix
    return 0
}

_koopa_activate_docker() {
    _koopa_add_to_path_start "${HOME:?}/.docker/bin"
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

_koopa_activate_julia() {
    [ -x "$(_koopa_bin_prefix)/julia" ] || return 0
    JULIA_DEPOT_PATH="$(_koopa_julia_packages_prefix)"
    JULIA_NUM_THREADS="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH JULIA_NUM_THREADS
    return 0
}

_koopa_activate_kitty() {
    _koopa_is_kitty || return 0
    __kvar_prefix="$(_koopa_xdg_config_home)/kitty"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_source_bn="theme-$(_koopa_color_mode).conf"
    __kvar_source_file="${__kvar_prefix}/${__kvar_source_bn}"
    if [ ! -f "$__kvar_source_file" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_source_bn \
            __kvar_source_file
        return 0
    fi
    __kvar_target_file="${__kvar_prefix}/current-theme.conf"
    if [ -h "$__kvar_target_file" ] && _koopa_is_installed 'readlink'
    then
        __kvar_target_link_bn="$(readlink "$__kvar_target_file")"
        if [ "$__kvar_target_link_bn" = "$__kvar_source_bn" ]
        then
            unset -v \
                __kvar_prefix \
                __kvar_source_bn \
                __kvar_source_file \
                __kvar_target_file \
                __kvar_target_link_bn
            return 0
        fi
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    ln -fns "$__kvar_source_file" "$__kvar_target_file" >/dev/null
    unset -v \
        __kvar_prefix \
        __kvar_source_bn \
        __kvar_source_file \
        __kvar_target_file \
        __kvar_target_link_bn
    return 0
}

_koopa_activate_lesspipe() {
    __kvar_lesspipe="$(_koopa_bin_prefix)/lesspipe.sh"
    if [ ! -x "$__kvar_lesspipe" ]
    then
        unset -v __kvar_lesspipe
        return 0
    fi
    export LESS='-R'
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    export LESSCHARSET='utf-8'
    export LESSCOLOR='yes'
    export LESSOPEN="|${__kvar_lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    unset -v __kvar_lesspipe
    return 0
}

_koopa_activate_mcfly() {
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    _koopa_is_root && return 0
    __kvar_mcfly="$(_koopa_bin_prefix)/mcfly"
    if [ ! -x "$__kvar_mcfly" ]
    then
        unset -v __kvar_mcfly
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v \
                __kvar_mcfly \
                __kvar_shell
            return 0
            ;;
    esac
    __kvar_color_mode="$(_koopa_color_mode)"
    [ "$__kvar_color_mode" = 'light' ] && export MCFLY_LIGHT=true
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
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_mcfly" init "$__kvar_shell")"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_color_mode \
        __kvar_mcfly \
        __kvar_nounset \
        __kvar_shell
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
    __kvar_path_helper='/usr/libexec/path_helper'
    if [ ! -x "$__kvar_path_helper" ]
    then
        unset -v __kvar_path_helper
        return 0
    fi
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_path_helper" -s)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_path_helper
    return 0
}

_koopa_activate_pipx() {
    [ -x "$(_koopa_bin_prefix)/pipx" ] || return 0
    __kvar_prefix="$(_koopa_pipx_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "$__kvar_prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    PIPX_HOME="$__kvar_prefix"
    PIPX_BIN_DIR="${__kvar_prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    unset -v __kvar_prefix
    return 0
}

_koopa_activate_profile_files() {
    if [ -r "${HOME:?}/.profile-personal" ]
    then
        . "${HOME:?}/.profile-personal"
    fi
    if [ -r "${HOME:?}/.profile-work" ]
    then
        . "${HOME:?}/.profile-work"
    fi
    if [ -r "${HOME:?}/.profile-private" ]
    then
        . "${HOME:?}/.profile-private"
    fi
    if [ -r "${HOME:?}/.secrets" ]
    then
        . "${HOME:?}/.secrets"
    fi
    if [ -r "${HOME:?}/.secrets-personal" ]
    then
        . "${HOME:?}/.secrets-personal"
    fi
    if [ -r "${HOME:?}/.secrets-work" ]
    then
        . "${HOME:?}/.secrets-work"
    fi
    return 0
}

_koopa_activate_pyenv() {
    [ -n "${PYENV_ROOT:-}" ] && return 0
    __kvar_prefix="$(_koopa_pyenv_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_pyenv="${__kvar_prefix}/bin/pyenv"
    if [ ! -r "$__kvar_pyenv" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_pyenv
        return 0
    fi
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    export PYENV_ROOT="$__kvar_prefix"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_pyenv" init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_pyenv
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
        __kvar_startup_file="${HOME:?}/.pyrc"
        if [ -f "$__kvar_startup_file" ]
        then
            export PYTHONSTARTUP="$__kvar_startup_file"
        fi
        unset -v __kvar_startup_file
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

_koopa_activate_rbenv() {
    [ -n "${RBENV_ROOT:-}" ] && return 0
    __kvar_prefix="$(_koopa_rbenv_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_rbenv="${__kvar_prefix}/bin/rbenv"
    if [ ! -r "$__kvar_rbenv" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_rbenv
        return 0
    fi
    _koopa_is_alias 'rbenv' && unalias 'rbenv'
    export RBENV_ROOT="$__kvar_prefix"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_rbenv" init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_rbenv
    return 0
}

_koopa_activate_ripgrep() {
    [ -x "$(_koopa_bin_prefix)/rg" ] || return 0
    __kvar_config_file="$(_koopa_xdg_config_home)/ripgrep/config"
    if [ -f "$__kvar_config_file" ]
    then
        RIPGREP_CONFIG_PATH="$__kvar_config_file"
        export RIPGREP_CONFIG_PATH
    fi
    unset -v __kvar_config_file
    return 0
}

_koopa_activate_ruby() {
    __kvar_prefix="${HOME:?}/.gem"
    export GEM_HOME="$__kvar_prefix"
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    unset -v __kvar_prefix
    return 0
}

_koopa_activate_ssh_key() {
    _koopa_is_linux || return 0
    __kvar_key="${1:-}"
    if [ -z "$__kvar_key" ] && [ -n "${SSH_KEY:-}" ]
    then
        __kvar_key="${SSH_KEY:?}"
    else
        __kvar_key="${HOME:?}/.ssh/id_rsa"
    fi
    if [ ! -r "$__kvar_key" ]
    then
        unset -v __kvar_key
        return 0
    fi
    _koopa_is_installed 'ssh-add' 'ssh-agent' || return 1
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    ssh-add "$__kvar_key" >/dev/null 2>&1
    unset -v \
        __kvar_key \
        __kvar_nounset
    return 0
}

_koopa_activate_starship() {
    __kvar_starship="$(_koopa_bin_prefix)/starship"
    if [ ! -x "$__kvar_starship" ]
    then
        unset -v __kvar_starship
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v __kvar_shell
            return 0
            ;;
    esac
    __kvar_nounset="$(_koopa_boolean_nounset)"
    if [ "$__kvar_nounset" -eq 1 ]
    then
        unset -v \
            __kvar_nounset \
            __kvar_shell \
            __kvar_starship
        return 0
    fi
    eval "$("$__kvar_starship" init "$__kvar_shell")"
    unset -v \
            __kvar_nounset \
            __kvar_shell \
            __kvar_starship
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
    __kvar_bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$__kvar_bucket_dir" ] && __kvar_bucket_dir="${HOME:?}/bucket"
    if [ ! -d "$__kvar_bucket_dir" ]
    then
        unset -v __kvar_bucket_dir
        return 0
    fi
    __kvar_today_link="${HOME:?}/today"
    __kvar_today_subdirs="$(date '+%Y/%m/%d')"
    if _koopa_str_detect_posix \
        "$(_koopa_realpath "$__kvar_today_link")" \
        "$__kvar_today_subdirs"
    then
        unset -v \
            __kvar_bucket_dir \
            __kvar_today_link \
            __kvar_today_subdirs
        return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    mkdir -p \
        "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
        >/dev/null
    ln -fns \
        "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
        "$__kvar_today_link" \
        >/dev/null
    unset -v \
        __kvar_bucket_dir \
        __kvar_today_link \
        __kvar_today_subdirs
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
    if [ -z "${XDG_STATE_HOME:-}" ]
    then
        XDG_STATE_HOME="$(_koopa_xdg_state_home)"
    fi
    export \
        XDG_CACHE_HOME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_DATA_DIRS \
        XDG_DATA_HOME \
        XDG_STATE_HOME
    return 0
}

_koopa_activate_zoxide() {
    __kvar_zoxide="$(_koopa_bin_prefix)/zoxide"
    if [ ! -x "$__kvar_zoxide" ]
    then
        unset -v __kvar_zoxide
        return 0
    fi
    _koopa_is_alias 'z' && unalias 'z'
    __kvar_shell="$(_koopa_shell_name)"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_zoxide" init "$__kvar_shell")"
            ;;
        *)
            eval "$("$__kvar_zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_shell \
        __kvar_zoxide
    return 0
}

_koopa_add_config_link() {
    __kvar_config_prefix="$(_koopa_config_prefix)"
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    _koopa_is_alias 'rm' && unalias 'rm'
    while [ "$#" -ge 2 ]
    do
        __kvar_source_file="${1:?}"
        __kvar_dest_name="${2:?}"
        shift 2
        [ -e "$__kvar_source_file" ] || continue
        __kvar_dest_file="${__kvar_config_prefix}/${__kvar_dest_name}"
        if [ -L "$__kvar_dest_file" ] && [ -e "$__kvar_dest_file" ]
        then
            continue
        fi
        mkdir -p "$__kvar_config_prefix" >/dev/null
        rm -fr "$__kvar_dest_file" >/dev/null
        ln -fns "$__kvar_source_file" "$__kvar_dest_file" >/dev/null
    done
    unset -v \
        __kvar_config_prefix \
        __kvar_dest_file \
        __kvar_dest_name \
        __kvar_source_file
    return 0
}

_koopa_add_to_manpath_end() {
    MANPATH="${MANPATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$__kvar_dir")"
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}

_koopa_add_to_manpath_start() {
    MANPATH="${MANPATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        MANPATH="$(_koopa_add_to_path_string_start "$MANPATH" "$__kvar_dir")"
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}

_koopa_add_to_path_end() {
    PATH="${PATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        PATH="$(_koopa_add_to_path_string_end "$PATH" "$__kvar_dir")"
    done
    export PATH
    unset -v __kvar_dir
    return 0
}

_koopa_add_to_path_start() {
    PATH="${PATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        PATH="$(_koopa_add_to_path_string_start "$PATH" "$__kvar_dir")"
    done
    export PATH
    unset -v __kvar_dir
    return 0
}

_koopa_add_to_path_string_end() {
    __kvar_string="${1:-}"
    __kvar_dir="${2:?}"
    if _koopa_str_detect_posix "$__kvar_string" ":${__kvar_dir}"
    then
        __kvar_string="$(\
            _koopa_remove_from_path_string \
                "$__kvar_string" ":${__kvar_dir}" \
        )"
    fi
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$__kvar_dir"
    else
        __kvar_string="${__kvar_string}:${__kvar_dir}"
    fi
    _koopa_print "$__kvar_string"
    unset -v \
        __kvar_dir \
        __kvar_string
    return 0
}

_koopa_add_to_path_string_start() {
    __kvar_string="${1:-}"
    __kvar_dir="${2:?}"
    if _koopa_str_detect_posix "$__kvar_string" "${__kvar_dir}:"
    then
        __kvar_string="$( \
            _koopa_remove_from_path_string \
                "$__kvar_string" "${__kvar_dir}" \
        )"
    fi
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$__kvar_dir"
    else
        __kvar_string="${__kvar_dir}:${__kvar_string}"
    fi
    _koopa_print "$__kvar_string"
    unset -v \
        __kvar_dir \
        __kvar_string
    return 0
}

_koopa_alias_colorls() {
    case "$(_koopa_color_mode)" in
        'dark')
            __kvar_color_flag='--dark'
            ;;
        'light')
            __kvar_color_flag='--light'
            ;;
    esac
    colorls \
        "$__kvar_color_flag" \
        --group-directories-first \
        "$@"
    unset -v __kvar_color_flag
    return 0
}

_koopa_alias_emacs_vanilla() {
    emacs --no-init-file --no-window-system "$@"
}

_koopa_alias_emacs() {
    _koopa_emacs "$@"
}

_koopa_alias_glances() {
    case "$(_koopa_color_mode)" in
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
    __kvar_bash_prefix="$(_koopa_koopa_prefix)/lang/bash"
    [ -d "$__kvar_bash_prefix" ] || return 1
    cd "$__kvar_bash_prefix" || return 1
    return 0
}

_koopa_alias_kbs() {
    _koopa_add_to_path_start "$(_koopa_xdg_data_home)/koopa-bootstrap/bin"
    return 0
}

_koopa_alias_kdev() {
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_koopa_prefix="$(_koopa_koopa_prefix)"
    __kvar_bash="${__kvar_bin_prefix}/bash"
    __kvar_env="${__kvar_bin_prefix}/genv"
    if [ ! -x "$__kvar_bash" ]
    then
        if _koopa_is_linux
        then
            __kvar_bash='/bin/bash'
        elif _koopa_is_macos
        then
            __kvar_bash="$(_koopa_bootstrap_prefix)/bin/bash"
        fi
    fi
    if [ ! -x "$__kvar_bash" ]
    then
        __koopa_print 'Failed to locate bash.'
        return 1
    fi
    if [ ! -x "$__kvar_env" ]
    then
        __kvar_env='/usr/bin/env'
    fi
    if [ ! -x "$__kvar_env" ]
    then
        __koopa_print 'Failed to locate env.'
        return 1
    fi
    __kvar_rcfile="${__kvar_koopa_prefix}/lang/bash/include/header.sh"
    [ -f "$__kvar_rcfile" ] || return 1
    "$__kvar_env" -i \
        AWS_CLOUDFRONT_DISTRIBUTION_ID="${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" \
        HOME="${HOME:?}" \
        HTTP_PROXY="${HTTP_PROXY:-}" \
        HTTPS_PROXY="${HTTPS_PROXY:-}" \
        KOOPA_ACTIVATE=0 \
        KOOPA_BUILDER="${KOOPA_BUILDER:-0}" \
        KOOPA_CAN_INSTALL_BINARY="${KOOPA_CAN_INSTALL_BINARY:-}" \
        LANG='C' \
        LC_ALL='C' \
        PATH='/usr/bin:/bin' \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TMPDIR="${TMPDIR:-/tmp}" \
        http_proxy="${http_proxy:-}" \
        https_proxy="${https_proxy:-}" \
        "$__kvar_bash" \
            --noprofile \
            --rcfile "$__kvar_rcfile" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    unset -v \
        __kvar_bash \
        __kvar_bin_prefix \
        __kvar_env \
        __kvar_koopa_prefix \
        __kvar_rcfile
    return 0
}

_koopa_alias_l() {
    if [ -x "$(_koopa_bin_prefix)/eza" ]
    then
        "$(_koopa_bin_prefix)/eza" \
            --classify \
            --group \
            --group-directories-first \
            --numeric \
            --sort='Name' \
            "$@"
    elif [ -x "$(_koopa_bin_prefix)/gls" ]
    then
        "$(_koopa_bin_prefix)/gls" -BFhn "$@"
    else
        ls -BFhn "$@"
    fi
}

_koopa_alias_nvim_fzf() {
    nvim "$(fzf)"
}

_koopa_alias_nvim_vanilla() {
    nvim -u 'NONE' "$@"
}

_koopa_alias_python3_dev() {
    PYTHONPATH="$(pwd)" python3
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

_koopa_arch() {
    __kvar_string="$(uname -m)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
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
    if _koopa_is_set_nounset
    then
        __kvar_bool=1
    else
        __kvar_bool=0
    fi
    _koopa_print "$__kvar_bool"
    unset -v __kvar_bool
    return 0
}

_koopa_bootstrap_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/koopa-bootstrap"
    return 0
}

_koopa_check_multiple_users() {
    _koopa_is_aws_ec2 || return 0
    __kvar_n="$(_koopa_logged_in_user_count)"
    if [ "$__kvar_n" -gt 1 ]
    then
        __kvar_users="$( \
            _koopa_logged_in_users \
            | tr '\n' ' ' \
        )"
        _koopa_print "Multiple users: ${__kvar_users}"
        unset -v __kvar_users
    fi
    unset -v __kvar_n
    return 0
}

_koopa_color_mode() {
    __kvar_string="${KOOPA_COLOR_MODE:-}"
    if [ -z "$__kvar_string" ]
    then
        if _koopa_is_macos
        then
            if _koopa_macos_is_dark_mode
            then
                __kvar_string='dark'
            else
                __kvar_string='light'
            fi
        else
            __kvar_string='dark'
        fi
    fi
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
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
    __kvar_num="${KOOPA_CPU_COUNT:-}"
    if [ -n "$__kvar_num" ]
    then
        _koopa_print "$__kvar_num"
        unset -v __kvar_num
        return 0
    fi
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_getconf='/usr/bin/getconf'
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/gnproc" ]
    then
        __kvar_nproc="${__kvar_bin_prefix}/gnproc"
    else
        __kvar_nproc=''
    fi
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/python3" ]
    then
        __kvar_python="${__kvar_bin_prefix}/python3"
    elif [ -x '/usr/bin/python3' ]
    then
        __kvar_python='/usr/bin/python3'
    else
        __kvar_python=''
    fi
    __kvar_sysctl='/usr/sbin/sysctl'
    if [ -x "$__kvar_nproc" ]
    then
        __kvar_num="$("$__kvar_nproc" --all)"
    elif [ -x "$__kvar_getconf" ]
    then
        __kvar_num="$("$__kvar_getconf" '_NPROCESSORS_ONLN')"
    elif [ -x "$__kvar_sysctl" ] && _koopa_is_macos
    then
        __kvar_num="$( \
            "$__kvar_sysctl" -n 'hw.ncpu' \
            | cut -d ' ' -f 2 \
        )"
    elif [ -x "$__kvar_python" ]
    then
        __kvar_num="$( \
            "$__kvar_python" -c \
                "import multiprocessing; print(multiprocessing.cpu_count())" \
            2>/dev/null \
            || true \
        )"
    fi
    [ -z "$__kvar_num" ] && __kvar_num=1
    _koopa_print "$__kvar_num"
    unset -v \
        __kvar_bin_prefix \
        __kvar_getconf \
        __kvar_nproc \
        __kvar_num \
        __kvar_python \
        __kvar_sysctl
    return 0
}

_koopa_default_shell_name() {
    __kvar_shell="${SHELL:-sh}"
    __kvar_shell="$(basename "$__kvar_shell")"
    [ -n "$__kvar_shell" ] || return 1
    _koopa_print "$__kvar_shell"
    unset -v __kvar_shell
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
    __kvar_doom_emacs_prefix="$(_koopa_doom_emacs_prefix)"
    if [ ! -d "$__kvar_doom_emacs_prefix" ]
    then
        _koopa_print 'Doom Emacs is not installed.'
        unset -v __kvar_doom_emacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_doom_emacs_prefix" "$@"
    unset -v __kvar_doom_emacs_prefix
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
    __kvar_date="$(_koopa_bin_prefix)/gdate"
    if [ ! -x "$__kvar_date" ]
    then
        unset -v __kvar_date
        return 0
    fi
    KOOPA_DURATION_START="$("$__kvar_date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    unset -v __kvar_date
    return 0
}

_koopa_duration_stop() {
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_bc="${__kvar_bin_prefix}/gbc"
    __kvar_date="${__kvar_bin_prefix}/gdate"
    unset -v __kvar_bin_prefix
    if [ ! -x "$__kvar_bc" ] || [ ! -x "$__kvar_date" ]
    then
        unset -v __kvar_bc __kvar_date
        return 0
    fi
    __kvar_key="${1:-}"
    if [ -z "$__kvar_key" ]
    then
        __kvar_key='duration'
    else
        __kvar_key="[${__kvar_key}] duration"
    fi
    __kvar_start="${KOOPA_DURATION_START:?}"
    __kvar_stop="$("$__kvar_date" -u '+%s%3N')"
    __kvar_duration="$( \
        _koopa_print "${__kvar_stop}-${__kvar_start}" \
        | "$__kvar_bc" \
    )"
    [ -n "$__kvar_duration" ] || return 1
    _koopa_dl "$__kvar_key" "${__kvar_duration} ms"
    unset -v \
        KOOPA_DURATION_START \
        __kvar_bc \
        __kvar_date \
        __kvar_duration \
        __kvar_start \
        __kvar_stop
    return 0
}

_koopa_emacs_prefix() {
    _koopa_print "${HOME:?}/.emacs.d"
    return 0
}

_koopa_emacs() {
    if _koopa_is_macos
    then
        __kvar_emacs="$(_koopa_macos_emacs)"
    else
        __kvar_emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -e "$__kvar_emacs" ]
    then
        _koopa_print "Emacs not installed at '${__kvar_emacs}'."
        unset -v __kvar_emacs
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$__kvar_emacs" "$@" >/dev/null 2>&1
    else
        "$__kvar_emacs" "$@" >/dev/null 2>&1
    fi
    unset -v __kvar_emacs
    return 0
}

_koopa_export_editor() {
    if [ -z "${EDITOR:-}" ]
    then
        __kvar_editor="$(_koopa_bin_prefix)/nvim"
        [ -x "$__kvar_editor" ] || __kvar_editor='vim'
        EDITOR="$__kvar_editor"
        unset -v __kvar_editor
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
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.$(_koopa_shell_name)_history"
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

_koopa_export_home() {
    [ -z "${HOME:-}" ] && HOME="$(pwd)"
    export HOME
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
    [ -z "${SHELL:-}" ] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}

_koopa_export_pager() {
    [ -n "${PAGER:-}" ] && return 0
    __kvar_less="$(_koopa_bin_prefix)/less"
    if [ -x "$__kvar_less" ]
    then
        export PAGER="${__kvar_less} -R"
    fi
    unset -v __kvar_less
    return 0
}

_koopa_expr() {
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_go_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/go"
    return 0
}

_koopa_group_id() {
    __kvar_string="$(id -g)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_group_name() {
    __kvar_string="$(id -gn)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_homebrew_prefix() {
    __kvar_string="${HOMEBREW_PREFIX:-}"
    if [ -z "$__kvar_string" ]
    then
        if _koopa_is_installed 'brew'
        then
            __kvar_string="$(brew --prefix)"
        elif _koopa_is_macos
        then
            case "$(_koopa_arch)" in
                'arm'*)
                    __kvar_string='/opt/homebrew'
                    ;;
                'x86'*)
                    __kvar_string='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            __kvar_string='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_is_alacritty() {
    [ -n "${ALACRITTY_SOCKET:-}" ]
}

_koopa_is_alias() {
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        case "$__kvar_string" in
            'alias '*)
                continue
                ;;
            *)
                unset -v __kvar_cmd __kvar_string
                return 1
                ;;
        esac
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}

_koopa_is_alpine() {
    _koopa_is_os 'alpine'
}

_koopa_is_arch() {
    _koopa_is_os 'arch'
}

_koopa_is_aws_ec2() {
    [ -x '/usr/bin/ec2metadata' ] && return 0
    [ "$(hostname -d)" = 'ec2.internal' ] && return 0
    return 1
}

_koopa_is_debian_like() {
    _koopa_is_os_like 'debian'
}

_koopa_is_fedora_like() {
    _koopa_is_os_like 'fedora'
}

_koopa_is_function() {
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        [ "$__kvar_string" = "$__kvar_cmd" ] && continue
        unset -v __kvar_cmd __kvar_string
        return 1
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}

_koopa_is_installed() {
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        [ -x "$__kvar_string" ] && continue
        unset -v __kvar_cmd __kvar_string
        return 1
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}

_koopa_is_interactive() {
    if [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ]
    then
        return 0
    fi
    if [ "${KOOPA_FORCE:-0}" -eq 1 ]
    then
        return 0
    fi
    if _koopa_str_detect_posix "$-" 'i'
    then
        return 0
    fi
    if _koopa_is_tty
    then
        return 0
    fi
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
    __kvar_id="${1:?}"
    if _koopa_is_os "$__kvar_id"
    then
        unset __kvar_id
        return 0
    fi
    __kvar_file='/etc/os-release'
    if [ ! -r "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_id
        return 1
    fi
    if grep 'ID=' "$__kvar_file" | grep -q "$__kvar_id"
    then
        unset -v __kvar_file __kvar_id
        return 0
    fi
    if grep 'ID_LIKE=' "$__kvar_file" | grep -q "$__kvar_id"
    then
        unset -v __kvar_file __kvar_id
        return 0
    fi
    unset -v __kvar_file __kvar_id
    return 1
}

_koopa_is_os() {
    [ "$(_koopa_os_id)" = "${1:?}" ]
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
    __kvar_shell="${KOOPA_SHELL:-}"
    if [ -n "$__kvar_shell" ]
    then
        _koopa_print "$__kvar_shell"
        unset -v __kvar_shell
        return 0
    fi
    __kvar_pid="${$}"
    if _koopa_is_installed 'ps'
    then
        __kvar_shell="$( \
            ps -p "$__kvar_pid" -o 'comm=' \
            | sed 's/^-//' \
        )"
    elif _koopa_is_linux
    then
        __kvar_proc_file="/proc/${__kvar_pid}/exe"
        [ -f "$__kvar_proc_file" ] || return 1
        __kvar_shell="$(_koopa_realpath "$__kvar_proc_file")"
        __kvar_shell="$(basename "$__kvar_shell")"
        unset -v __kvar_proc_file
    else
        if [ -n "${BASH_VERSION:-}" ]
        then
            __kvar_shell='bash'
        elif [ -n "${KSH_VERSION:-}" ]
        then
            __kvar_shell='ksh'
        elif [ -n "${ZSH_VERSION:-}" ]
        then
            __kvar_shell='zsh'
        else
            __kvar_shell='sh'
        fi
    fi
    [ -n "$__kvar_shell" ] || return 1
    case "$__kvar_shell" in
        '/bin/sh' | 'sh')
            __kvar_shell="$(_koopa_realpath '/bin/sh')"
            ;;
    esac
    _koopa_print "$__kvar_shell"
    unset -v __kvar_pid __kvar_shell
    return 0
}

_koopa_logged_in_user_count() {
    __kvar_string="$(_koopa_logged_in_users | wc -l)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_logged_in_users() {
    __kvar_string="$( \
        who -q \
        | awk 'NR > 1 { print prev } { prev = $0 }' \
        | tr ' ' '\n' \
        | sort \
        | uniq \
    )"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_macos_activate_cli_colors() {
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    return 0
}

_koopa_macos_activate_egnyte() {
    _koopa_add_to_path_end "${HOME}/Library/Group Containers/\
FELUD555VC.group.com.egnyte.DesktopApp/CLI"
    return 0
}

_koopa_macos_activate_homebrew() {
    __kvar_prefix="$(_koopa_homebrew_prefix)"
    if [ ! -x "${__kvar_prefix}/bin/brew" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ] && \
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ] && \
        export HOMEBREW_INSTALL_CLEANUP=1
    [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ] && \
        export HOMEBREW_NO_ENV_HINTS=1
    unset -v __kvar_prefix
    return 0
}

_koopa_macos_emacs() {
    __kvar_homebrew_prefix="$(_koopa_homebrew_prefix)"
    [ -d "$__kvar_homebrew_prefix" ] || return 1
    __kvar_emacs="${__kvar_homebrew_prefix}/bin/emacs"
    [ -x "$__kvar_emacs" ] || return 1
    _koopa_print "$__kvar_emacs"
    unset -v __kvar_emacs __kvar_homebrew_prefix
    return 0
}

_koopa_macos_is_dark_mode() {
    [ \
        "$( \
            /usr/bin/defaults read -g 'AppleInterfaceStyle' \
            2>/dev/null \
        )" = 'Dark' \
    ]
}

_koopa_macos_is_light_mode() {
    ! _koopa_macos_is_dark_mode
}

_koopa_macos_os_version() {
    __kvar_string="$(/usr/bin/sw_vers -productVersion)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_major_minor_patch_version() {
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$__kvar_string" ] || return 1
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '-' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d 'p' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}

_koopa_major_minor_version() {
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}

_koopa_major_version() {
    _koopa_is_alias 'cut' && unalias 'cut'
    for __kvar_string in "$@"
    do
        __kvar_string="$( \
            _koopa_print "$__kvar_string" \
            | cut -d '.' -f '1' \
            | cut -d '-' -f '1' \
            | cut -d '+' -f '1' \
        )"
        [ -n "$__kvar_string" ] || return 1
        _koopa_print "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}

_koopa_opt_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/opt"
    return 0
}

_koopa_os_id() {
    __kvar_string="$(_koopa_os_string | cut -d '-' -f 1)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_os_string() {
    __kvar_id=''
    if _koopa_is_macos
    then
        __kvar_id='macos'
        __kvar_version="$(_koopa_major_version "$(_koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        __kvar_release_file='/etc/os-release'
        if [ -r "$__kvar_release_file" ]
        then
            __kvar_id="$( \
                awk -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "$__kvar_release_file" \
                | tr -d '"' \
            )"
            __kvar_version="$( \
                awk -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "$__kvar_release_file" \
                | tr -d '"' \
            )"
            if [ -n "$__kvar_version" ]
            then
                __kvar_version="$(_koopa_major_version "$__kvar_version")"
            else
                __kvar_version='rolling'
            fi
        else
            __kvar_id='linux'
            __kvar_version=''
        fi
    fi
    [ -n "$__kvar_id" ] ||  return 1
    __kvar_string="$__kvar_id"
    if [ -n "$__kvar_version" ]
    then
        __kvar_string="${__kvar_string}-${__kvar_version}"
    fi
    _koopa_print "$__kvar_string"
    unset -v \
        __kvar_id \
        __kvar_release_file \
        __kvar_string \
        __kvar_version
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
    __kvar_prelude_emacs_prefix="$(_koopa_prelude_emacs_prefix)"
    if [ ! -d "$__kvar_prelude_emacs_prefix" ]
    then
        _koopa_print 'Prelude Emacs is not installed.'
        unset -v __kvar_prelude_emacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_prelude_emacs_prefix" "$@"
    unset -v __kvar_prelude_emacs_prefix
    return 0
}

_koopa_print() {
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for __kvar_string in "$@"
    do
        printf '%b\n' "$__kvar_string"
    done
    unset __kvar_string
    return 0
}

_koopa_pyenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}

_koopa_rbenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/rbenv"
    return 0
}

_koopa_realpath() {
    for __kvar_arg in "$@"
    do
        __kvar_string="$( \
            readlink -f "$__kvar_arg" \
            2>/dev/null \
            || true \
        )"
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$__kvar_arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                python3 -c \
                    "import os; print(os.path.realpath('${__kvar_arg}'))" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            unset -v __kvar_arg _kvar_string
            return 1
        fi
        __koopa_print "$__kvar_string"
    done
    unset -v __kvar_arg __kvar_string
    return 0
}

_koopa_remove_from_path_string() {
    __kvar_str1="${1:?}"
    __kvar_dir="${2:?}"
    __kvar_str2="$( \
        _koopa_print "$__kvar_str1" \
            | sed \
                -e "s|^${__kvar_dir}:||g" \
                -e "s|:${__kvar_dir}:|:|g" \
                -e "s|:${__kvar_dir}\$||g" \
        )"
    [ -n "$__kvar_str2" ] || return 1
    _koopa_print "$__kvar_str2"
    unset -v \
        __kvar_dir \
        __kvar_str1 \
        __kvar_str2
    return 0
}

_koopa_scripts_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_shell_name() {
    __kvar_shell="$(_koopa_locate_shell)"
    __kvar_shell="$(basename "$__kvar_shell")"
    [ -n "$__kvar_shell" ] || return 1
    _koopa_print "$__kvar_shell"
    unset -v __kvar_shell
    return 0
}

_koopa_spacemacs_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacemacs"
    return 0
}

_koopa_spacemacs() {
    __kvar_spacemacs_prefix="$(_koopa_spacemacs_prefix)"
    if [ ! -d "$__kvar_spacemacs_prefix" ]
    then
        _koopa_print 'Spacemacs is not installed.'
        unset -v __kvar_spacemacs_prefix
        return 1
    fi
    _koopa_emacs --init-directory="$__kvar_spacemacs_prefix" "$@"
    unset -v __kvar_spacemacs_prefix
    return 0
}

_koopa_spacevim_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacevim"
    return 0
}

_koopa_spacevim() {
    __kvar_vim='vim'
    if _koopa_is_macos
    then
        __kvar_gvim='/Applications/MacVim.app/Contents/bin/gvim'
        [ -x "$__kvar_gvim" ] && __kvar_vim="$__kvar_gvim"
        unset -v __kvar_gvim
    fi
    __kvar_vimrc="$(_koopa_spacevim_prefix)/vimrc"
    if [ ! -f "$__kvar_vimrc" ]
    then
        _koopa_print 'SpaceVim is not installed.'
        return 1
    fi
    _koopa_is_alias 'vim' && unalias 'vim'
    "$__kvar_vim" -u "$__kvar_vimrc" "$@"
    unset -v __kvar_vim __kvar_vimrc
    return 0
}

_koopa_str_detect_posix() {
    unset test
    test "${1#*"$2"}" != "$1"
}

_koopa_today() {
    __kvar_string="$(date '+%Y-%m-%d')"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_umask() {
    umask 0002
    return 0
}

_koopa_user_id() {
    __kvar_string="$(id -u)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_user_name() {
    __kvar_string="$(id -un)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_walk() {
    __kvar_walk="$(_koopa_bin_prefix)/walk"
    [ -x "$__kvar_walk" ] || return 1
    cd "$("$__kvar_walk" "$@")" || return 1
    unset -v __kvar_walk
    return 0
}

_koopa_xdg_cache_home() {
    __kvar_string="${XDG_CACHE_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.cache"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_xdg_config_dirs() {
    __kvar_string="${XDG_CONFIG_DIRS:-}"
    if [ -z "$__kvar_string" ] 
    then
        __kvar_string='/etc/xdg'
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_xdg_config_home() {
    __kvar_string="${XDG_CONFIG_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.config"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_xdg_data_dirs() {
    __kvar_string="${XDG_DATA_DIRS:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string='/usr/local/share:/usr/share'
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_xdg_data_home() {
    __kvar_string="${XDG_DATA_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="${HOME:?}/.local/share"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_xdg_local_home() {
    _koopa_print "${HOME:?}/.local"
    return 0
}

_koopa_xdg_state_home() {
    __kvar_string="${XDG_STATE_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$(_koopa_xdg_local_home)/state"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

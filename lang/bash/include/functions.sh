#!/usr/bin/env bash
# shellcheck disable=all

_koopa_activate_alacritty() {
    _koopa_is_alacritty || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/alacritty"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/alacritty.toml"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    local color_file_bn
    color_file_bn="colors-$(_koopa_color_mode).toml"
    local color_file
    color_file="${prefix}/${color_file_bn}"
    if [[ ! -f "$color_file" ]]
    then
        return 0
    fi
    if ! grep -q "$color_file_bn" "$conf_file"
    then
        local pattern
        pattern='colors-.+\.toml'
        local replacement
        replacement="${color_file_bn}"
        perl -i -l -p \
            -e "s|${pattern}|${replacement}|" \
            "$conf_file"
    fi
    return 0
}

_koopa_activate_aliases() {
    _koopa_is_interactive || return 0
    _koopa_activate_coreutils_aliases
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local xdg_data_home
    xdg_data_home="$(_koopa_xdg_data_home)"
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
    alias realcd='_koopa_alias_realcd'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias venv='_koopa_alias_venv'
    alias week='_koopa_alias_week'
    if [[ -x "${bin_prefix}/asdf" ]]
    then
        alias asdf='_koopa_activate_asdf; asdf'
    fi
    if [[ -x "${bin_prefix}/black" ]]
    then
        alias black='black --line-length=79'
    fi
    if [[ -x "${bin_prefix}/broot" ]]
    then
        alias br='_koopa_activate_broot; br'
        alias br-size='br --sort-by-size'
    fi
    if [[ -x "${bin_prefix}/chezmoi" ]]
    then
        alias cm='chezmoi'
    fi
    if [[ -x "${bin_prefix}/colorls" ]]
    then
        alias cls='_koopa_alias_colorls'
    fi
    if [[ -x "${bin_prefix}/conda" ]]
    then
        alias conda='_koopa_activate_conda; conda'
    fi
    if [[ -x '/usr/local/bin/emacs' ]] || \
        [[ -x '/usr/bin/emacs' ]] || \
        [[ -x "${bin_prefix}/emacs" ]]
    then
        alias emacs='_koopa_alias_emacs'
        alias emacs-vanilla='_koopa_alias_emacs_vanilla'
        if [[ -d "${xdg_data_home}/doom" ]]
        then
            alias doom-emacs='_koopa_doom_emacs'
        fi
        if [[ -d "${xdg_data_home}/prelude" ]]
        then
            alias prelude-emacs='_koopa_prelude_emacs'
        fi
        if [[ -d "${xdg_data_home}/spacemacs" ]]
        then
            alias spacemacs='_koopa_spacemacs'
        fi
    fi
    if [[ -x "${bin_prefix}/fd" ]]
    then
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    fi
    if [[ -x "${bin_prefix}/glances" ]]
    then
        alias glances='_koopa_alias_glances'
    fi
    if [[ -x "${bin_prefix}/nvim" ]]
    then
        alias nvim-vanilla='_koopa_alias_nvim_vanilla'
        if [[ -x "${bin_prefix}/fzf" ]]
        then
            alias nvim-fzf='_koopa_alias_nvim_fzf'
        fi
    fi
    if [[ -x "${bin_prefix}/pyenv" ]]
    then
        alias pyenv='_koopa_activate_pyenv; pyenv'
    fi
    if [[ -x "${bin_prefix}/python3" ]]
    then
        alias python3-dev='PYTHONPATH="$(pwd)" python3'
    fi
    if [[ -x '/usr/local/bin/R' ]] || [[ -x '/usr/bin/R' ]]
    then
        alias R='R --no-restore --no-save --quiet'
    fi
    if [[ -x "${bin_prefix}/pyenv" ]]
    then
        alias radian='radian --no-restore --no-save --quiet'
    fi
    if [[ -x "${bin_prefix}/rbenv" ]]
    then
        alias rbenv='_koopa_activate_rbenv; rbenv'
    fi
    if [[ -x '/usr/bin/shasum' ]]
    then
        alias sha256='shasum -a 256'
    fi
    if [[ -x "${bin_prefix}/tmux" ]]
    then
        alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    fi
    if [[ -x "${bin_prefix}/vim" ]]
    then
        alias vim-vanilla='_koopa_alias_vim_vanilla'
        if [[ -x "${bin_prefix}/fzf" ]]
        then
            alias vim-fzf='_koopa_alias_vim_fzf'
        fi
        if [[ -d "${xdg_data_home}/spacevim" ]]
        then
            alias spacevim='_koopa_spacevim'
        fi
    fi
    if [[ -x "${bin_prefix}/walk" ]]
    then
        alias lk='_koopa_walk'
    fi
    if [[ -x "${bin_prefix}/zoxide" ]]
    then
        alias z='_koopa_activate_zoxide; __zoxide_z'
        alias j='z'
    fi
    if [[ -f "${HOME:?}/.aliases" ]]
    then
        source "${HOME:?}/.aliases"
    fi
    if [[ -f "${HOME:?}/.aliases-private" ]]
    then
        source "${HOME:?}/.aliases-private"
    fi
    if [[ -f "${HOME:?}/.aliases-work" ]]
    then
        source "${HOME:?}/.aliases-work"
    fi
    return 0
}

_koopa_activate_asdf() {
    local prefix
    prefix="${1:-}"
    if [[ -z "$prefix" ]]
    then
        prefix="$(_koopa_asdf_prefix)"
    fi
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local script
    script="${prefix}/libexec/asdf.sh"
    if [[ ! -r "$script" ]]
    then
        return 0
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_bash_aliases() {
    local -A dict
    dict['user_aliases_file']="${HOME}/.bash_aliases"
    if [[ -f "${dict['user_aliases_file']}" ]]
    then
        source "${dict['user_aliases_file']}"
    fi
    return 0
}

_koopa_activate_bash_completion() {
    local -A app dict
    local -a completion_dirs completion_files
    local completion_dir completion_file
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    completion_files+=(
        "${dict['opt_prefix']}/bash-completion/etc/profile.d/bash_completion.sh"
        "${dict['opt_prefix']}/gh/share/bash-completion/completions/gh"
        "${dict['opt_prefix']}/git/share/completion/git-completion.bash"
        "${dict['opt_prefix']}/google-cloud-sdk/libexec/gcloud/\
completion.bash.inc"
    )
    for completion_file in "${completion_files[@]}"
    do
        if [[ -f "$completion_file" ]]
        then
            source "$completion_file"
        fi
    done
    completion_dirs+=(
        '/etc/bash_completion.d'
        '/usr/local/etc/bash_completion.d'
        "${dict['opt_prefix']}/chezmoi/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/eza/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/gum/etc/bash_completion.d"
        "${dict['opt_prefix']}/lesspipe/etc/bash_completion.d"
        "${dict['opt_prefix']}/rust/etc/bash_completion.d"
        "${dict['opt_prefix']}/tealdeer/libexec/etc/bash_completion.d"
    )
    for completion_dir in "${completion_dirs[@]}"
    do
        if [[ -d "$completion_dir" ]]
        then
            local rc_file
            for rc_file in "${completion_dir}/"*
            do
                if [[ -f "$rc_file" ]]
                then
                    source "$rc_file"
                fi
            done
        fi
    done
    app['aws_completer']="${dict['opt_prefix']}/aws-cli/bin/aws_completer"
    if [[ -x "${app['aws_completer']}" ]]
    then
        complete -C "${app['aws_completer']}" 'aws'
    fi
    return 0
}

_koopa_activate_bash_extras() {
    _koopa_is_interactive || return 0
    _koopa_activate_bashrc_files
    _koopa_activate_bash_readline
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    _koopa_activate_bash_reverse_search
    _koopa_activate_bash_completion
    _koopa_activate_completion
    return 0
}

_koopa_activate_bash_prompt() {
    _koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(_koopa_bash_prompt_string)"
    export PS1
    return 0
}

_koopa_activate_bash_readline() {
    local -A dict
    [[ -n "${INPUTRC:-}" ]] && return 0
    dict['input_rc_file']="${HOME}/.inputrc"
    [[ -r "${dict['input_rc_file']}" ]] || return 0
    export INPUTRC="${dict['input_rc_file']}"
    return 0
}

_koopa_activate_bash_reverse_search() {
    _koopa_activate_mcfly
    return 0
}

_koopa_activate_bashrc_files() {
    if [[ -f '/etc/bashrc' ]]
    then
        source '/etc/bashrc'
    fi
    if [[ -d "${HOME}/.bashrc.d" ]]
    then
        local rc_file
        for rc_file in "${HOME}/.bashrc.d/"*
        do
            if [[ -f "$rc_file" ]]
            then
                source "$rc_file"
            fi
        done
    fi
    if [[ -f "${HOME}/.bashrc-personal" ]]
    then
        source "${HOME}/.bashrc-personal"
    fi
    if [[ -f "${HOME}/.bashrc-work" ]]
    then
        source "${HOME}/.bashrc-work"
    fi
    return 0
}

_koopa_activate_bat() {
    [[ -x "$(_koopa_bin_prefix)/bat" ]] || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/bat"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/config-$(_koopa_color_mode)"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    export BAT_CONFIG_PATH="$conf_file"
    return 0
}

_koopa_activate_bootstrap() {
    local bootstrap_prefix
    bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    if [[ ! -d "$(_koopa_bootstrap_prefix)" ]]
    then
        return 0
    fi
    local opt_prefix
    opt_prefix="$(_koopa_opt_prefix)"
    if [[ -d "${opt_prefix}/bash" ]] \
        && [[ -d "${opt_prefix}/coreutils" ]] \
        && [[ -d "${opt_prefix}/openssl3" ]] \
        && [[ -d "${opt_prefix}/python3.12" ]] \
        && [[ -d "${opt_prefix}/zlib" ]]
    then
        return 0
    fi
    _koopa_add_to_path_start "${bootstrap_prefix}/bin"
    return 0
}

_koopa_activate_bottom() {
    [[ -x "$(_koopa_bin_prefix)/btm" ]] || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/bottom"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local source_bn
    source_bn="bottom-$(_koopa_color_mode).toml"
    local source_file
    source_file="${prefix}/${source_bn}"
    if [[ ! -f "$source_file" ]]
    then
        return 0
    fi
    local target_file
    target_file="${prefix}/bottom.toml"
    if [[ -h "$target_file" ]] && _koopa_is_installed 'readlink'
    then
        local target_link_bn
        target_link_bn="$(readlink "$target_file")"
        if [[ "$target_link_bn" = "$source_bn" ]]
        then
            return 0
        fi
    fi
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}

_koopa_activate_broot() {
    [[ -x "$(_koopa_bin_prefix)/broot" ]] || return 0
    local config_dir
    config_dir="$(_koopa_xdg_config_home)/broot"
    if [[ ! -d "$config_dir" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    local script
    script="${config_dir}/launcher/bash/br"
    if [[ ! -f "$script" ]]
    then
        return 0
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_ca_certificates() {
    local prefix
    prefix="$(_koopa_xdg_data_home)/ca-certificates"
    local file
    file="${prefix}/cacert.pem"
    if [[ ! -f "$file" ]] && _koopa_is_linux
    then
        prefix='/etc/ssl/certs'
        file="${prefix}/ca-certificates.crt"
    fi
    if [[ ! -f "$file" ]]
    then
        prefix="$(_koopa_opt_prefix)/ca-certificates/share/\
ca-certificates"
        file="${prefix}/cacert.pem"
    fi
    if [[ ! -f "$file" ]]
    then
        return 0
    fi
    export AWS_CA_BUNDLE="$file"
    export CURL_CA_BUNDLE="$file"
    export DEFAULT_CA_BUNDLE_PATH="$prefix"
    export NODE_EXTRA_CA_CERTS="$file"
    export REQUESTS_CA_BUNDLE="$file"
    export SSL_CERT_FILE="$file"
    if _koopa_is_linux
    then
        export SSL_CERT_DIR='/etc/ssl/certs'
    fi
    return 0
}

_koopa_activate_color_mode() {
    if [[ -z "${KOOPA_COLOR_MODE:-}" ]]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [[ -n "${KOOPA_COLOR_MODE:-}" ]]
    then
        export KOOPA_COLOR_MODE
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}

_koopa_activate_completion() {
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    local koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    local file
    for file in "${koopa_prefix}/etc/completion/"*'.sh'
    do
        [[ -f "$file" ]] && source "$file"
    done
    return 0
}

_koopa_activate_conda() {
    local prefix
    prefix="$(_koopa_conda_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conda
    conda="${prefix}/bin/conda"
    if [[ ! -x "$conda" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            shell='posix'
            ;;
    esac
    local conda_setup
    conda_setup="$("$conda" "shell.${shell}" 'hook')"
    eval "$conda_setup"
    _koopa_is_function 'conda' || return 1
    return 0
}

_koopa_activate_coreutils_aliases() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    if [[ -x "${bin_prefix}/gcp" ]]
    then
        alias gcp='gcp --interactive --recursive --verbose'
    fi
    if [[ -x "${bin_prefix}/gln" ]]
    then
        alias gln='gln --interactive --no-dereference --symbolic --verbose'
    fi
    if [[ -x "${bin_prefix}/gmkdir" ]]
    then
        alias gmkdir='gmkdir --parents --verbose'
    fi
    if [[ -x "${bin_prefix}/gmv" ]]
    then
        alias gmv='gmv --interactive --verbose'
    fi
    if [[ -x "${bin_prefix}/grm" ]]
    then
        alias grm='grm --interactive=once --verbose'
    fi
    return 0
}

_koopa_activate_delta() {
    [[ -x "$(_koopa_bin_prefix)/delta" ]] || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/delta"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local source_bn
    source_bn="theme-$(_koopa_color_mode).gitconfig"
    local source_file
    source_file="${prefix}/${source_bn}"
    if [[ ! -f "$source_file" ]]
    then
        return 0
    fi
    local target_file
    target_file="${prefix}/theme.gitconfig"
    if [[ -h "$target_file" ]] && _koopa_is_installed 'readlink'
    then
        local target_link_bn
        target_link_bn="$(readlink "$target_file")"
        if [[ "$target_link_bn" = "$source_bn" ]]
        then
            return 0
        fi
    fi
    ln -fns \
        "$source_file" \
        "$target_file" \
        >/dev/null 2>&1
    return 0
}

_koopa_activate_difftastic() {
    [[ -x "$(_koopa_bin_prefix)/difft" ]] || return 0
    DFT_BACKGROUND="$(_koopa_color_mode)"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}

_koopa_activate_dircolors() {
    [[ -n "${SHELL:-}" ]] || return 0
    local dircolors
    dircolors="$(_koopa_bin_prefix)/gdircolors"
    if [[ ! -x "$dircolors" ]]
    then
        return 0
    fi
    local prefix
    prefix="$(_koopa_xdg_config_home)/dircolors"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conf_file
    conf_file="${prefix}/dircolors-$(_koopa_color_mode)"
    if [[ ! -f "$conf_file" ]]
    then
        return 0
    fi
    eval "$("$dircolors" "$conf_file")"
    alias gdir='gdir --color=auto'
    alias gegrep='gegrep --color=auto'
    alias gfgrep='gfgrep --color=auto'
    alias ggrep='ggrep --color=auto'
    alias gls='gls --color=auto'
    alias gvdir='gvdir --color=auto'
    return 0
}

_koopa_activate_direnv() {
    local direnv
    direnv="$(_koopa_bin_prefix)/direnv"
    if [[ ! -x "$direnv" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    case "$shell" in
        'bash' | \
        'zsh')
            eval "$("$direnv" hook "$shell")"
            eval "$("$direnv" export "$shell")"
            ;;
    esac
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_docker() {
    _koopa_add_to_path_start "${HOME:?}/.docker/bin"
    return 0
}

_koopa_activate_fzf() {
    [[ -x "$(_koopa_bin_prefix)/fzf" ]] || return 0
    if [[ -z "${FZF_DEFAULT_OPTS:-}" ]]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}

_koopa_activate_gcc_colors() {
    [[ -n "${GCC_COLORS:-}" ]] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

_koopa_activate_julia() {
    [[ -x "$(_koopa_bin_prefix)/julia" ]] || return 0
    JULIA_DEPOT_PATH="$(_koopa_julia_packages_prefix)"
    JULIA_NUM_THREADS="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH JULIA_NUM_THREADS
    return 0
}

_koopa_activate_kitty() {
    _koopa_is_kitty || return 0
    local prefix
    prefix="$(_koopa_xdg_config_home)/kitty"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local source_bn
    source_bn="theme-$(_koopa_color_mode).conf"
    local source_file
    source_file="${prefix}/${source_bn}"
    if [[ ! -f "$source_file" ]]
    then
        return 0
    fi
    local target_file
    target_file="${prefix}/current-theme.conf"
    if [[ -h "$target_file" ]] && _koopa_is_installed 'readlink'
    then
        local target_link_bn
        target_link_bn="$(readlink "$target_file")"
        if [[ "$target_link_bn" = "$source_bn" ]]
        then
            return 0
        fi
    fi
    ln -fns "$source_file" "$target_file" >/dev/null
    return 0
}

_koopa_activate_lesspipe() {
    local lesspipe
    lesspipe="$(_koopa_bin_prefix)/lesspipe.sh"
    if [[ ! -x "$lesspipe" ]]
    then
        return 0
    fi
    export LESS='-R'
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    export LESSCHARSET='utf-8'
    export LESSCOLOR='yes'
    export LESSOPEN="|${lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    return 0
}

_koopa_activate_mcfly() {
    [[ "${__MCFLY_LOADED:-}" = 'loaded' ]] && return 0
    _koopa_is_root && return 0
    local mcfly
    mcfly="$(_koopa_bin_prefix)/mcfly"
    if [[ ! -x "$mcfly" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    local color_mode
    color_mode="$(_koopa_color_mode)"
    [[ "$color_mode" = 'light' ]] && export MCFLY_LIGHT=true
    case "${EDITOR:-}" in
        'nvim' | *'/nvim' | \
        'vim' | *'/vim')
            export MCFLY_KEY_SCHEME='vim'
            ;;
        'emacs' | *'/emacs')
            export MCFLY_KEY_SCHEME='emacs'
            ;;
    esac
    export MCFLY_DISABLE_MENU=true
    export MCFLY_FUZZY=2
    export MCFLY_HISTORY_LIMIT=10000
    export MCFLY_INTERFACE_VIEW='TOP'
    export MCFLY_RESULTS=50
    export MCFLY_RESULTS_SORT='RANK'
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$mcfly" init "$shell")"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_micromamba() {
    if [[ -z "${MAMBA_ROOT_PREFIX:-}" ]]
    then
        export MAMBA_ROOT_PREFIX="${HOME:?}/.mamba"
    fi
    return 0
}

_koopa_activate_path_helper() {
    local path_helper
    path_helper='/usr/libexec/path_helper'
    if [[ ! -x "$path_helper" ]]
    then
        return 0
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$path_helper" -s)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_pipx() {
    [[ -x "$(_koopa_bin_prefix)/pipx" ]] || return 0
    local prefix
    prefix="$(_koopa_pipx_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        mkdir -p "$prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${prefix}/bin"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}

_koopa_activate_profile_files() {
    if [[ -r "${HOME:?}/.profile-personal" ]]
    then
        source "${HOME:?}/.profile-personal"
    fi
    if [[ -r "${HOME:?}/.profile-work" ]]
    then
        source "${HOME:?}/.profile-work"
    fi
    if [[ -r "${HOME:?}/.profile-private" ]]
    then
        source "${HOME:?}/.profile-private"
    fi
    if [[ -r "${HOME:?}/.secrets" ]]
    then
        source "${HOME:?}/.secrets"
    fi
    if [[ -r "${HOME:?}/.secrets-personal" ]]
    then
        source "${HOME:?}/.secrets-personal"
    fi
    if [[ -r "${HOME:?}/.secrets-work" ]]
    then
        source "${HOME:?}/.secrets-work"
    fi
    return 0
}

_koopa_activate_pyenv() {
    [[ -n "${PYENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="$(_koopa_pyenv_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local pyenv
    pyenv="${prefix}/bin/pyenv"
    if [[ ! -r "$pyenv" ]]
    then
        return 0
    fi
    export PYENV_ROOT="$prefix"
    export PYENV_LOCAL_SHIM="${HOME:?}/.pyenv_local_shim"
    if [[ ! -d "$PYENV_LOCAL_SHIM" ]]
    then
        mkdir -p "$PYENV_LOCAL_SHIM"
    fi
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$pyenv" virtualenv-init -)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_pyright() {
    [[ -x "$(_koopa_bin_prefix)/pyright" ]] || return 0
    export PYRIGHT_PYTHON_FORCE_VERSION='latest'
    return 0
}

_koopa_activate_python() {
    if [[ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [[ -z "${PYTHONDONTWRITEBYTECODE:-}" ]]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    if [[ -z "${PYTHONSTARTUP:-}" ]]
    then
        local startup_file
        startup_file="${HOME:?}/.pyrc"
        if [[ -f "$startup_file" ]]
        then
            export PYTHONSTARTUP="$startup_file"
        fi
    fi
    if [[ -z "${PYTHONWARNINGS:-}" ]]
    then
        export PYTHONWARNINGS='ignore::SyntaxWarning'
    fi
    if [[ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

_koopa_activate_rbenv() {
    [[ -n "${RBENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="$(_koopa_rbenv_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local rbenv
    rbenv="${prefix}/bin/rbenv"
    if [[ ! -r "$rbenv" ]]
    then
        return 0
    fi
    export RBENV_ROOT="$prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$rbenv" init -)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_activate_ripgrep() {
    [[ -x "$(_koopa_bin_prefix)/rg" ]] || return 0
    local config_file
    config_file="$(_koopa_xdg_config_home)/ripgrep/config"
    if [[ -f "$config_file" ]]
    then
        RIPGREP_CONFIG_PATH="$config_file"
        export RIPGREP_CONFIG_PATH
    fi
    return 0
}

_koopa_activate_ruby() {
    local prefix
    prefix="${HOME:?}/.gem"
    export GEM_HOME="$prefix"
    _koopa_add_to_path_start "${prefix}/bin"
    return 0
}

_koopa_activate_starship() {
    local starship
    starship="$(_koopa_bin_prefix)/starship"
    if [[ ! -x "$starship" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    if [[ -n "${STARSHIP_SHELL:-}" ]] && [[ "$STARSHIP_SHELL" != "$shell" ]]
    then
        unset -v STARSHIP_SHELL
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    if [[ "$nounset" -eq 1 ]]
    then
        return 0
    fi
    eval "$("$starship" init "$shell")"
    return 0
}

_koopa_activate_tealdeer() {
    [[ -x "$(_koopa_bin_prefix)/tldr" ]] || return 0
    if [[ -z "${TEALDEER_CONFIG_DIR:-}" ]]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    export TEALDEER_CONFIG_DIR
    return 0
}

_koopa_activate_today_bucket() {
    local bucket_dir
    bucket_dir="${KOOPA_BUCKET:-}"
    local today_link
    if [[ -n "$bucket_dir" ]]
    then
        [[ -d "$KOOPA_BUCKET" ]] || return 1
        today_link="${HOME:?}/today"
    elif [[ -d "${HOME:?}/bucket" ]]
    then
        bucket_dir="${HOME:?}/bucket"
        today_link="${HOME:?}/today"
    elif [[ -d "${HOME:?}/Documents/bucket" ]]
    then
        bucket_dir="${HOME:?}/Documents/bucket"
        today_link="${HOME:?}/Documents/today"
    else
        return 0
    fi
    local today_subdirs
    today_subdirs="$(date '+%Y/%m/%d')"
    if _koopa_str_detect_posix \
        "$(_koopa_realpath "$today_link")" \
        "$today_subdirs"
    then
        return 0
    fi
    mkdir -p \
        "${bucket_dir}/${today_subdirs}" \
        >/dev/null
    ln -fns \
        "${bucket_dir}/${today_subdirs}" \
        "$today_link" \
        >/dev/null
    return 0
}

_koopa_activate_xdg() {
    if [[ -z "${XDG_CACHE_HOME:-}" ]]
    then
        XDG_CACHE_HOME="$(_koopa_xdg_cache_home)"
    fi
    if [[ -z "${XDG_CONFIG_DIRS:-}" ]]
    then
        XDG_CONFIG_DIRS="$(_koopa_xdg_config_dirs)"
    fi
    if [[ -z "${XDG_CONFIG_HOME:-}" ]]
    then
        XDG_CONFIG_HOME="$(_koopa_xdg_config_home)"
    fi
    if [[ -z "${XDG_DATA_DIRS:-}" ]]
    then
        XDG_DATA_DIRS="$(_koopa_xdg_data_dirs)"
    fi
    if [[ -z "${XDG_DATA_HOME:-}" ]]
    then
        XDG_DATA_HOME="$(_koopa_xdg_data_home)"
    fi
    if [[ -z "${XDG_STATE_HOME:-}" ]]
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
    local zoxide
    zoxide="$(_koopa_bin_prefix)/zoxide"
    if [[ ! -x "$zoxide" ]]
    then
        return 0
    fi
    local shell
    shell="$(_koopa_shell_name)"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    case "$shell" in
        'bash' | \
        'zsh')
            eval "$("$zoxide" init "$shell")"
            ;;
        *)
            eval "$("$zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_alert_info() {
    _koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

_koopa_alias_colorls() {
    local color_flag
    case "$(_koopa_color_mode)" in
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
    local bash_prefix
    bash_prefix="$(_koopa_koopa_prefix)/lang/bash"
    [[ -d "$bash_prefix" ]] || return 1
    cd "$bash_prefix" || return 1
    return 0
}

_koopa_alias_kbs() {
    _koopa_add_to_path_start "$(_koopa_xdg_data_home)/koopa-bootstrap/bin"
    return 0
}

_koopa_alias_kdev() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    local bash
    bash="${bin_prefix}/bash"
    local env
    env="${bin_prefix}/genv"
    if [[ ! -x "$bash" ]]
    then
        if _koopa_is_linux
        then
            bash='/bin/bash'
        elif _koopa_is_macos
        then
            bash="$(_koopa_bootstrap_prefix)/bin/bash"
        fi
    fi
    if [[ ! -x "$bash" ]]
    then
        _koopa_print 'Failed to locate bash.'
        return 1
    fi
    if [[ ! -x "$env" ]]
    then
        env='/usr/bin/env'
    fi
    if [[ ! -x "$env" ]]
    then
        _koopa_print 'Failed to locate env.'
        return 1
    fi
    local rcfile
    rcfile="${koopa_prefix}/lang/bash/include/header.sh"
    [[ -f "$rcfile" ]] || return 1
    "$env" -i \
        AWS_CLOUDFRONT_DISTRIBUTION_ID="${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" \
        HOME="${HOME:?}" \
        HTTP_PROXY="${HTTP_PROXY:-}" \
        HTTPS_PROXY="${HTTPS_PROXY:-}" \
        KOOPA_ACTIVATE=0 \
        KOOPA_BUILDER="${KOOPA_BUILDER:-0}" \
        KOOPA_CAN_INSTALL_BINARY="${KOOPA_CAN_INSTALL_BINARY:-}" \
        LANG='C' \
        LC_ALL='C' \
        PATH="${PATH:?}" \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TMPDIR="${TMPDIR:-/tmp}" \
        http_proxy="${http_proxy:-}" \
        https_proxy="${https_proxy:-}" \
        "$bash" \
            --noprofile \
            --rcfile "$rcfile" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}

_koopa_alias_l() {
    if [[ -x "$(_koopa_bin_prefix)/eza" ]]
    then
        "$(_koopa_bin_prefix)/eza" \
            --classify \
            --group \
            --group-directories-first \
            --numeric \
            --sort='Name' \
            "$@"
    elif [[ -x "$(_koopa_bin_prefix)/gls" ]]
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

_koopa_alias_realcd() {
    local dir
    dir="${1:-}"
    [[ -z "$dir" ]] && dir="$(pwd)"
    dir="$(_koopa_realpath "$dir")"
    cd "$dir" || return 1
    return 0
}

_koopa_alias_tmux_vanilla() {
    tmux -f '/dev/null'
}

_koopa_alias_today() {
    date '+%Y-%m-%d'
}

_koopa_alias_venv() {
    if [[ -f '.venv/bin/activate' ]]
    then
        source '.venv/bin/activate'
    elif [[ -f "venv/bin/activate" ]]
    then
        source "venv/bin/activate"
    elif [[ -f "${HOME}/.venv/bin/activate" ]]
    then
        source "${HOME}/.venv/bin/activate"
    elif [[ -f "${HOME}/venv/bin/activate" ]]
    then
        source "${HOME}/venv/bin/activate"
    else
        _koopa_print 'Failed to locate Python virtual environment.'
        return 1
    fi
    return 0
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

_koopa_assert_has_args_eq() {
    if [[ "$#" -ne 2 ]]
    then
        _koopa_stop '"_koopa_assert_has_args_eq" requires 2 args.'
    fi
    if [[ "${1:?}" -ne "${2:?}" ]]
    then
        _koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

_koopa_assert_has_args_ge() {
    if [[ "$#" -ne 2 ]]
    then
        _koopa_stop '"_koopa_assert_has_args_ge" requires 2 args.'
    fi
    if [[ ! "${1:?}" -ge "${2:?}" ]]
    then
        _koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

_koopa_assert_has_args_le() {
    if [[ "$#" -ne 2 ]]
    then
        _koopa_stop '"_koopa_assert_has_args_le" requires 2 args.'
    fi
    if [[ ! "${1:?}" -le "${2:?}" ]]
    then
        _koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

_koopa_assert_has_args() {
    if [[ "$#" -ne 1 ]]
    then
        _koopa_stop \
            '"_koopa_assert_has_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -eq 0 ]]
    then
        _koopa_stop 'Required arguments missing.'
    fi
    return 0
}

_koopa_assert_has_no_args() {
    if [[ "$#" -ne 1 ]]
    then
        _koopa_stop \
            '"_koopa_assert_has_no_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -ne 0 ]]
    then
        _koopa_stop "Arguments are not allowed (${1} detected)."
    fi
    return 0
}

_koopa_assert_is_admin() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_admin
    then
        _koopa_stop \
            'Administrator account is required.' \
            "You may need to run 'sudo -v' to elevate current user."
    fi
    return 0
}

_koopa_assert_is_dir() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -d "$arg" ]]
        then
            _koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_executable() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -z "$arg" ]]
        then
            _koopa_stop 'Missing executable.'
        fi
        if [[ ! -x "$arg" ]]
        then
            _koopa_stop "Not executable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_file() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -f "$arg" ]]
        then
            _koopa_stop "Not file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_readable() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            _koopa_stop "Not readable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_set() {
    local name value
    _koopa_assert_has_args_ge "$#" 2
    while (("$#"))
    do
        name="${1:?}"
        value="${2:-}"
        shift 2
        if [[ -z "${value}" ]]
        then
            _koopa_stop "'${name}' is unset."
        fi
    done
    return 0
}

_koopa_add_to_manpath_end() {
    MANPATH="${MANPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_manpath_start() {
    MANPATH="${MANPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        MANPATH="$(_koopa_add_to_path_string_start "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_path_end() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PATH="$(_koopa_add_to_path_string_end "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_path_start() {
    PATH="${PATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PATH="$(_koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_path_string_end() {
    local string
    string="${1:-}"
    local dir
    dir="${2:?}"
    if _koopa_str_detect_posix "$string" ":${dir}"
    then
        string="$( \
            _koopa_remove_from_path_string \
                "$string" ":${dir}" \
        )"
    fi
    if [[ -z "$string" ]]
    then
        string="$dir"
    else
        string="${string}:${dir}"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_add_to_path_string_start() {
    local string
    string="${1:-}"
    local dir
    dir="${2:?}"
    if _koopa_str_detect_posix "$string" "${dir}:"
    then
        string="$( \
            _koopa_remove_from_path_string \
                "$string" "${dir}" \
        )"
    fi
    if [[ -z "$string" ]]
    then
        string="$dir"
    else
        string="${dir}:${string}"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_ansi_escape() {
    local escape
    case "${1:?}" in
        'nocolor')
            escape='0'
            ;;
        'default')
            escape='0;39'
            ;;
        'default-bold')
            escape='1;39'
            ;;
        'black')
            escape='0;30'
            ;;
        'black-bold')
            escape='1;30'
            ;;
        'blue')
            escape='0;34'
            ;;
        'blue-bold')
            escape='1;34'
            ;;
        'cyan')
            escape='0;36'
            ;;
        'cyan-bold')
            escape='1;36'
            ;;
        'green')
            escape='0;32'
            ;;
        'green-bold')
            escape='1;32'
            ;;
        'magenta')
            escape='0;35'
            ;;
        'magenta-bold')
            escape='1;35'
            ;;
        'red')
            escape='0;31'
            ;;
        'red-bold')
            escape='1;31'
            ;;
        'yellow')
            escape='0;33'
            ;;
        'yellow-bold')
            escape='1;33'
            ;;
        'white')
            escape='0;97'
            ;;
        'white-bold')
            escape='1;97'
            ;;
        *)
            return 1
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}

_koopa_app_json_version() {
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='version'
    done
}

_koopa_app_json() {
    "${KOOPA_PREFIX:?}/bin/koopa" internal app-json "$@"
    return 0
}

_koopa_arch() {
    local string
    string="$(uname -m)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_basename() {
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        [[ -n "$arg" ]] || return 1
        arg="${arg%%+(/)}"
        arg="${arg##*/}"
        _koopa_print "$arg"
    done
    return 0
}

_koopa_bash_prompt_string() {
    local -A dict
    dict['newline']='\n'
    dict['prompt']='\$'
    dict['prompt_color']=35
    dict['user']='\u@\h'
    dict['user_color']=36
    dict['wd']='\w'
    dict['wd_color']=34
    printf '%s%s%s%s%s%s ' \
        "${dict['newline']}" \
        "\[\033[${dict['user_color']}m\]${dict['user']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['wd_color']}m\]${dict['wd']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['prompt_color']}m\]${dict['prompt']}\[\033[00m\]"
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

_koopa_cd() {
    local prefix
    _koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    cd "$prefix" >/dev/null 2>&1 || return 1
    return 0
}

_koopa_check_multiple_users() {
    _koopa_is_aws_ec2 || return 0
    local n
    n="$(_koopa_logged_in_user_count)"
    if [[ "$n" -gt 1 ]]
    then
        local users
        users="$( \
            _koopa_logged_in_users \
            | tr '\n' ' ' \
        )"
        _koopa_print "Multiple users: ${users}"
    fi
    return 0
}

_koopa_color_mode() {
    local string
    string="${KOOPA_COLOR_MODE:-}"
    if [[ -z "$string" ]]
    then
        if _koopa_is_macos
        then
            if _koopa_macos_is_dark_mode
            then
                string='dark'
            else
                string='light'
            fi
        else
            string='dark'
        fi
    fi
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_conda_env_list() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['conda']}" env list --json --quiet)"
    _koopa_print "$str"
    return 0
}

_koopa_cpu_count() {
    local num
    num="${KOOPA_CPU_COUNT:-}"
    if [[ -n "$num" ]]
    then
        _koopa_print "$num"
        return 0
    fi
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local getconf
    getconf='/usr/bin/getconf'
    local nproc
    if [[ -d "$bin_prefix" ]] && [[ -x "${bin_prefix}/gnproc" ]]
    then
        nproc="${bin_prefix}/gnproc"
    else
        nproc=''
    fi
    local python
    if [[ -d "$bin_prefix" ]] && [[ -x "${bin_prefix}/python3" ]]
    then
        python="${bin_prefix}/python3"
    elif [[ -x '/usr/bin/python3' ]]
    then
        python='/usr/bin/python3'
    else
        python=''
    fi
    local sysctl
    sysctl='/usr/sbin/sysctl'
    if [[ -x "$nproc" ]]
    then
        num="$("$nproc" --all)"
    elif [[ -x "$getconf" ]]
    then
        num="$("$getconf" '_NPROCESSORS_ONLN')"
    elif [[ -x "$sysctl" ]] && _koopa_is_macos
    then
        num="$( \
            "$sysctl" -n 'hw.ncpu' \
            | cut -d ' ' -f 2 \
        )"
    elif [[ -x "$python" ]]
    then
        num="$( \
            "$python" -c \
                "import multiprocessing; print(multiprocessing.cpu_count())" \
            2>/dev/null \
            || true \
        )"
    fi
    [[ -z "$num" ]] && num=1
    _koopa_print "$num"
    return 0
}

_koopa_dirname() {
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        local str
        [[ -n "$arg" ]] || return 1
        if [[ -e "$arg" ]]
        then
            arg="$(_koopa_realpath "$arg")"
        fi
        if _koopa_str_detect_fixed --string="$arg" --pattern='/'
        then
            str="${arg%/*}"
        else
            str='.'
        fi
        _koopa_print "$str"
    done
    return 0
}

_koopa_dl() {
    _koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        _koopa_msg 'default' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}

_koopa_doom_emacs() {
    local doom_emacs_prefix
    doom_emacs_prefix="$(_koopa_doom_emacs_prefix)"
    if [[ ! -d "$doom_emacs_prefix" ]]
    then
        _koopa_print 'Doom Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$doom_emacs_prefix" "$@"
    return 0
}

_koopa_duration_start() {
    local date
    date="$(_koopa_bin_prefix)/gdate"
    if [[ ! -x "$date" ]]
    then
        return 0
    fi
    KOOPA_DURATION_START="$("$date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

_koopa_duration_stop() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local bc
    bc="${bin_prefix}/gbc"
    local date
    date="${bin_prefix}/gdate"
    if [[ ! -x "$bc" ]] || [[ ! -x "$date" ]]
    then
        return 0
    fi
    local key
    key="${1:-}"
    if [[ -z "$key" ]]
    then
        key='duration'
    else
        key="[${key}] duration"
    fi
    local start
    start="${KOOPA_DURATION_START:?}"
    local stop
    stop="$("$date" -u '+%s%3N')"
    local duration
    duration="$( \
        _koopa_print "${stop}-${start}" \
        | "$bc" \
    )"
    [[ -n "$duration" ]] || return 1
    _koopa_print "${key}: ${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

_koopa_emacs() {
    local emacs
    if _koopa_is_macos
    then
        emacs="$(_koopa_macos_emacs)"
    else
        emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [[ ! -e "$emacs" ]]
    then
        _koopa_print "Emacs not installed at '${emacs}'."
        return 1
    fi
    if [[ -e "${HOME:?}/.terminfo/78/xterm-24bit" ]] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$emacs" "$@" >/dev/null 2>&1
    else
        "$emacs" "$@" >/dev/null 2>&1
    fi
    return 0
}

_koopa_grep() {
    local -A app dict
    local -a grep_args grep_cmd
    _koopa_assert_has_args "$#"
    dict['boolean']=0
    dict['engine']="${KOOPA_GREP_ENGINE:-}"
    dict['file']=''
    dict['invert_match']=0
    dict['only_matching']=0
    dict['mode']='fixed' # or 'regex'.
    dict['pattern']=''
    dict['stdin']=1
    dict['string']=''
    dict['sudo']=0
    while (("$#"))
    do
        case "$1" in
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--file='*)
                dict['file']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                dict['stdin']=0
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--string')
                dict['string']="${2:-}"
                dict['stdin']=0
                shift 2
                ;;
            '--boolean' | \
            '--quiet')
                dict['boolean']=1
                shift 1
                ;;
            '--regex' | \
            '--extended-regexp')
                dict['mode']='regex'
                shift 1
                ;;
            '--fixed' | \
            '--fixed-strings')
                dict['mode']='fixed'
                shift 1
                ;;
            '--invert-match')
                dict['invert_match']=1
                shift 1
                ;;
            '--only-matching')
                dict['only_matching']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--pattern' "${dict['pattern']}"
    case "${dict['engine']}" in
        '')
            app['grep']="$(_koopa_locate_rg --allow-missing)"
            [[ -x "${app['grep']}" ]] && dict['engine']='rg'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='grep'
                app['grep']="$(_koopa_locate_grep --allow-system)"
            fi
            ;;
        'grep')
            app['grep']="$(_koopa_locate_grep --allow-system)"
            ;;
        'rg')
            app['grep']="$(_koopa_locate_rg)"
            ;;
    esac
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['string']="$(</dev/stdin)"
    fi
    if [[ -n "${dict['file']}" ]] && [[ -n "${dict['string']}" ]]
    then
        _koopa_stop "Use '--file' or '--string', but not both."
    fi
    grep_cmd=("${app['grep']}")
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        grep_cmd=('_koopa_sudo' "${grep_cmd[@]}")
    fi
    grep_args=()
    case "${dict['engine']}" in
        'grep')
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('-F')
                    ;;
                'regex')
                    grep_args+=('-E')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('-v')  # --invert-match
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('-o')  # --only-matching
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('-q')  # --quiet
            ;;
        'rg')
            grep_args+=('--no-config' '--case-sensitive')
            if [[ -n "${dict['file']}" ]]
            then
                grep_args+=('--no-ignore' '--one-file-system')
            fi
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    grep_args+=('--engine' 'default')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('--invert-match')
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('--only-matching')
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('--quiet')
            ;;
        *)
            _koopa_stop 'Invalid grep engine.'
            ;;
    esac
    grep_args+=("${dict['pattern']}")
    _koopa_assert_is_executable "${app[@]}"
    if [[ -n "${dict['file']}" ]]
    then
        _koopa_assert_is_file "${dict['file']}"
        _koopa_assert_is_readable "${dict['file']}"
        grep_args+=("${dict['file']}")
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    else
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            _koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            _koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    fi
}

_koopa_has_passwordless_sudo() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['sudo']="$(_koopa_locate_sudo --allow-missing)"
    [[ -x "${app['sudo']}" ]] || return 1
    _koopa_is_root && return 0
    "${app['sudo']}" -n true 2>/dev/null && return 0
    return 1
}

_koopa_help_2() {
    local -A dict
    dict['script_file']="$(_koopa_realpath "$0")"
    dict['script_name']="$(_koopa_basename "${dict['script_file']}")"
    dict['man_prefix']="$( \
        _koopa_parent_dir --num=2 "${dict['script_file']}" \
    )"
    dict['man_file']="${dict['man_prefix']}/share/man/\
man1/${dict['script_name']}.1"
    _koopa_assert_is_file "${dict['man_file']}"
    _koopa_help "${dict['man_file']}"
}

_koopa_help() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    app['head']="$(_koopa_locate_head --allow-system)"
    app['man']="$(_koopa_locate_man --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | _koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

_koopa_invalid_arg() {
    local arg str
    if [[ "$#" -gt 0 ]]
    then
        arg="${1:-}"
        str="Invalid argument: '${arg}'."
    else
        str='Invalid argument.'
    fi
    _koopa_stop "$str"
}

_koopa_locate_shell() {
    local shell
    shell="${KOOPA_SHELL:-}"
    if [[ -n "$shell" ]]
    then
        _koopa_print "$shell"
        return 0
    fi
    local pid
    pid="${$}"
    if _koopa_is_installed 'ps'
    then
        shell="$( \
            ps -p "$pid" -o 'comm=' \
            | sed 's/^-//' \
        )"
    elif _koopa_is_linux
    then
        local proc_file
        proc_file="/proc/${pid}/exe"
        [[ -f "$proc_file" ]] || return 1
        shell="$(_koopa_realpath "$proc_file")"
        shell="$(basename "$shell")"
    else
        if [[ -n "${BASH_VERSION:-}" ]]
        then
            shell='bash'
        elif [[ -n "${KSH_VERSION:-}" ]]
        then
            shell='ksh'
        elif [[ -n "${ZSH_VERSION:-}" ]]
        then
            shell='zsh'
        else
            shell='sh'
        fi
    fi
    [[ -n "$shell" ]] || return 1
    case "$shell" in
        '/bin/sh' | 'sh')
            shell="$(_koopa_realpath '/bin/sh')"
            ;;
    esac
    _koopa_print "$shell"
    return 0
}

_koopa_logged_in_user_count() {
    local string
    string="$(_koopa_logged_in_users | wc -l)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_logged_in_users() {
    local string
    string="$( \
        who -q \
        | awk 'NR > 1 { print prev } { prev = $0 }' \
        | tr ' ' '\n' \
        | sort \
        | uniq \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_msg() {
    local -A dict
    local string
    dict['c1']="$(_koopa_ansi_escape "${1:?}")"
    dict['c2']="$(_koopa_ansi_escape "${2:?}")"
    dict['nc']="$(_koopa_ansi_escape 'nocolor')"
    dict['prefix']="${3:?}"
    shift 3
    for string in "$@"
    do
        _koopa_print "${dict['c1']}${dict['prefix']}${dict['nc']} \
${dict['c2']}${string}${dict['nc']}"
    done
    return 0
}

_koopa_parent_dir() {
    local -A app dict
    local -a pos
    local file
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cd_tail']=''
    dict['n']=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict['n']="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict['n']="${2:?}"
                shift 2
                ;;
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    [[ "${dict['n']}" -ge 1 ]] || dict['n']=1
    if [[ "${dict['n']}" -ge 2 ]]
    then
        dict['n']="$((dict[n]-1))"
        dict['cd_tail']="$( \
            printf "%${dict['n']}s" \
            | "${app['sed']}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        local parent
        [[ -e "$file" ]] || return 1
        parent="$(_koopa_dirname "$file")"
        parent="${parent}${dict['cd_tail']}"
        parent="$(_koopa_cd "$parent" && pwd -P)"
        _koopa_print "$parent"
    done
    return 0
}

_koopa_prelude_emacs() {
    local prelude_emacs_prefix
    prelude_emacs_prefix="$(_koopa_prelude_emacs_prefix)"
    if [[ ! -d "$prelude_emacs_prefix" ]]
    then
        _koopa_print 'Prelude Emacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$prelude_emacs_prefix" "$@"
    return 0
}

_koopa_print() {
    if [[ "$#" -eq 0 ]]
    then
        printf '\n'
        return 0
    fi
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

_koopa_realpath() {
    local arg string
    for arg in "$@"
    do
        string="$( \
            readlink -f "$arg" \
            2>/dev/null \
            || true \
        )"
        if [[ -z "$string" ]]
        then
            string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [[ -z "$string" ]]
        then
            string="$( \
                python3 -c \
                    "import os; print(os.path.realpath('${arg}'))" \
                2>/dev/null \
                || true \
            )"
        fi
        if [[ -z "$string" ]]
        then
            return 1
        fi
        _koopa_print "$string"
    done
    return 0
}

_koopa_remove_from_path_string() {
    local str1="${1:?}"
    local dir="${2:?}"
    local str2
    str2="$( \
        _koopa_print "$str1" \
            | sed \
                -e "s|^${dir}:||g" \
                -e "s|:${dir}:|:|g" \
                -e "s|:${dir}\$||g" \
        )"
    [[ -n "$str2" ]] || return 1
    _koopa_print "$str2"
    return 0
}

_koopa_remove_from_path() {
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PATH="$(_koopa_remove_from_path_string "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_shell_name() {
    local shell
    shell="$(_koopa_locate_shell)"
    shell="$(basename "$shell")"
    [[ -n "$shell" ]] || return 1
    _koopa_print "$shell"
    return 0
}

_koopa_spacemacs() {
    local spacemacs_prefix
    spacemacs_prefix="$(_koopa_spacemacs_prefix)"
    if [[ ! -d "$spacemacs_prefix" ]]
    then
        _koopa_print 'Spacemacs is not installed.'
        return 1
    fi
    _koopa_emacs --init-directory="$spacemacs_prefix" "$@"
    return 0
}

_koopa_spacevim() {
    local vim
    vim='vim'
    if _koopa_is_macos
    then
        local gvim
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        [[ -x "$gvim" ]] && vim="$gvim"
    fi
    local vimrc
    vimrc="$(_koopa_spacevim_prefix)/vimrc"
    if [[ ! -f "$vimrc" ]]
    then
        _koopa_print 'SpaceVim is not installed.'
        return 1
    fi
    "$vim" -u "$vimrc" "$@"
    return 0
}

_koopa_stack_trace() {
    local cnt i
    _koopa_assert_has_no_args "$#"
    set +o xtrace
    printf '\nStack trace:\n'
    (( cnt = ${#FUNCNAME[@]} ))
    (( i = 0 ))
    while (( i < cnt ))
    do
        local line
        printf '[%3d] %s\n' "${i}" "${FUNCNAME[i]}"
        if (( i > 0 ))
        then
            line="${BASH_LINENO[$((i - 1))]}"
        else
            line="${LINENO}"
        fi
        printf '      file "%s" line %d\n' "${BASH_SOURCE[i]}" "${line}"
        (( i++ ))
    done
    return 0
}

_koopa_stop() {
    local -A bool
    bool['verbose']="${KOOPA_VERBOSE:-0}"
    _koopa_msg 'red-bold' 'red' 'Error:' "$@" >&2
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        set +o errexit
        set +o errtrace
        set +o xtrace
        trap '' ERR
        _koopa_stack_trace
    fi
    exit 1
}

_koopa_str_detect_fixed() {
    _koopa_str_detect --mode='fixed' "$@"
}

_koopa_str_detect_posix() {
    [[ "${1#*"$2"}" != "$1" ]]
}

_koopa_str_detect_regex() {
    _koopa_str_detect --mode='regex' "$@"
}

_koopa_str_detect() {
    local -A dict
    local -a grep_args
    _koopa_assert_has_args "$#"
    dict['mode']=''
    dict['pattern']=''
    dict['stdin']=1
    dict['string']=''
    dict['sudo']=0
    while (("$#"))
    do
        case "$1" in
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--string')
                dict['string']="${2:-}"
                dict['stdin']=0
                shift 2
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['string']="$(</dev/stdin)"
    fi
    _koopa_assert_is_set \
        '--mode' "${dict['mode']}" \
        '--pattern' "${dict['pattern']}"
    grep_args=(
        '--boolean'
        '--mode' "${dict['mode']}"
        '--pattern' "${dict['pattern']}"
        '--string' "${dict['string']}"
    )
    [[ "${dict['sudo']}" -eq 1 ]] && grep_args+=('--sudo')
    _koopa_grep "${grep_args[@]}"
}

_koopa_sudo() {
    local -A app
    local -a cmd
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    _koopa_assert_has_args "$#"
    if ! _koopa_is_root
    then
        _koopa_assert_is_admin
        app['sudo']="$(_koopa_locate_sudo)"
        _koopa_assert_is_executable "${app[@]}"
        cmd+=("${app['sudo']}")
    fi
    cmd+=("$@")
    "${cmd[@]}"
    return 0
}

_koopa_user_id() {
    local string
    string="$(id -u)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_walk() {
    local walk
    walk="$(_koopa_bin_prefix)/walk"
    [[ -x "$walk" ]] || return 1
    cd "$("$walk" "$@")" || return 1
    return 0
}

_koopa_which() {
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        if _koopa_is_alias "$cmd"
        then
            unalias "$cmd"
        elif _koopa_is_function "$cmd"
        then
            unset -f "$cmd"
        fi
        cmd="$(command -v "$cmd")"
        [[ -x "$cmd" ]] || return 1
        _koopa_print "$cmd"
    done
    return 0
}

_koopa_export_editor() {
    if [[ -z "${EDITOR:-}" ]]
    then
        local editor
        editor="$(_koopa_bin_prefix)/nvim"
        [[ -x "$editor" ]] || editor='vim'
        EDITOR="$editor"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

_koopa_export_gnupg() {
    [[ -z "${GPG_TTY:-}" ]] || return 0
    _koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [[ -n "$GPG_TTY" ]] || return 0
    export GPG_TTY
    return 0
}

_koopa_export_history() {
    if [[ -z "${HISTFILE:-}" ]]
    then
        HISTFILE="${HOME:?}/.$(_koopa_shell_name)_history"
    fi
    export HISTFILE
    if [[ ! -f "$HISTFILE" ]] \
        && [[ -e "${HOME:-}" ]] \
        && _koopa_is_installed 'touch'
    then
        touch "$HISTFILE"
    fi
    if [[ -z "${HISTCONTROL:-}" ]]
    then
        HISTCONTROL='ignoredups'
    fi
    export HISTCONTROL
    if [[ -z "${HISTIGNORE:-}" ]]
    then
        HISTIGNORE='&:ls:[bf]g:exit'
    fi
    export HISTIGNORE
    if [[ -z "${HISTSIZE:-}" ]] || [[ "${HISTSIZE:-}" -eq 0 ]]
    then
        HISTSIZE=1000
    fi
    export HISTSIZE
    if [[ -z "${HISTTIMEFORMAT:-}" ]]
    then
        HISTTIMEFORMAT='%Y%m%d %T  '
    fi
    export HISTTIMEFORMAT
    if [[ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]]
    then
        SAVEHIST="$HISTSIZE"
    fi
    export SAVEHIST
    return 0
}

_koopa_export_home() {
    [[ -z "${HOME:-}" ]] && HOME="$(pwd)"
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
    [[ -z "${SHELL:-}" ]] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}

_koopa_export_manpager() {
    [[ -n "${MANPAGER:-}" ]] && return 0
    local nvim
    nvim="$(_koopa_bin_prefix)/nvim"
    if [[ -x "$nvim" ]]
    then
        export MANPAGER="${nvim} +Man!"
    fi
    return 0
}

_koopa_export_pager() {
    [[ -n "${PAGER:-}" ]] && return 0
    local less
    less="$(_koopa_bin_prefix)/less"
    if [[ -x "$less" ]]
    then
        export PAGER="${less} -R"
    fi
    return 0
}

_koopa_is_admin() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    case "${KOOPA_ADMIN:-}" in
        '0')
            return 1
            ;;
        '1')
            return 0
            ;;
    esac
    _koopa_is_root && return 0
    _koopa_is_installed 'sudo' || return 1
    _koopa_has_passwordless_sudo && return 0
    app['groups']="$(_koopa_locate_groups --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['groups']="$("${app['groups']}")"
    dict['pattern']='\b(admin|root|sudo|wheel)\b'
    [[ -n "${dict['groups']}" ]] || return 1
    _koopa_str_detect_regex \
        --string="${dict['groups']}" \
        --pattern="${dict['pattern']}" \
        && return 0
    return 1
}

_koopa_is_alacritty() {
    [[ -n "${ALACRITTY_SOCKET:-}" ]]
}

_koopa_is_alias() {
    local cmd string
    for cmd in "$@"
    do
        string="$(command -v "$cmd")"
        case "$string" in
            'alias '*)
                continue
                ;;
            *)
                return 1
                ;;
        esac
    done
    return 0
}

_koopa_is_aws_ec2() {
    [[ -x '/usr/bin/ec2metadata' ]] && return 0
    [[ "$(hostname -d)" == 'ec2.internal' ]] && return 0
    return 1
}

_koopa_is_function() {
    local cmd string
    for cmd in "$@"
    do
        string="$(command -v "$cmd")"
        [[ "$string" == "$cmd" ]] && continue
        return 1
    done
    return 0
}

_koopa_is_installed() {
    local cmd string
    for cmd in "$@"
    do
        string="$(command -v "$cmd")"
        [[ -x "$string" ]] && continue
        return 1
    done
    return 0
}

_koopa_is_interactive() {
    if [[ "${KOOPA_INTERACTIVE:-0}" -eq 1 ]]
    then
        return 0
    fi
    if [[ "${KOOPA_FORCE:-0}" -eq 1 ]]
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
    [[ -n "${KITTY_PID:-}" ]]
}

_koopa_is_linux() {
    [[ "$(uname -s)" == 'Linux' ]]
}

_koopa_is_macos() {
    [[ "$(uname -s)" == 'Darwin' ]]
}

_koopa_is_root() {
    [[ "$(_koopa_user_id)" -eq 0 ]]
}

_koopa_is_set_nounset() {
    _koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

_koopa_is_subshell() {
    [[ "${KOOPA_SUBSHELL:-0}" -gt 0 ]]
}

_koopa_is_tty() {
    _koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_locate_app() {
    local -A bool dict
    local -a pos
    bool['allow_bootstrap']=0
    bool['allow_koopa_bin']=1
    bool['allow_missing']=0
    bool['allow_opt_bin']=1
    bool['allow_system']=0
    bool['only_system']=0
    bool['realpath']=0
    dict['app']=''
    dict['app_name']=''
    dict['bin_name']=''
    dict['system_bin_name']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app-name='*)
                dict['app_name']="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict['app_name']="${2:?}"
                shift 2
                ;;
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--system-bin-name='*)
                dict['system_bin_name']="${1#*=}"
                shift 1
                ;;
            '--system-bin-name')
                dict['system_bin_name']="${2:?}"
                shift 2
                ;;
            '--allow-bootstrap')
                bool['allow_bootstrap']=1
                shift 1
                ;;
            '--allow-missing')
                bool['allow_missing']=1
                shift 1
                ;;
            '--allow-system')
                bool['allow_system']=1
                shift 1
                ;;
            '--no-allow-koopa-bin')
                bool['allow_koopa_bin']=0
                shift 1
                ;;
            '--only-system')
                bool['only_system']=1
                shift 1
                ;;
            '--realpath')
                bool['realpath']=1
                shift 1
                ;;
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    __emit_if_found() {
        [[ -x "${dict['app']}" ]] || return 1
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(_koopa_realpath "${dict['app']}")"
        fi
        printf '%s\n' "${dict['app']}"
    }
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        bool['allow_bootstrap']=0
        bool['allow_koopa_bin']=0
        bool['allow_system']=1
    fi
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
        [[ "$#" -eq 1 ]] || return 1
        dict['app']="${1:?}"
        __emit_if_found && return 0
        [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
        _koopa_stop "Failed to locate '${dict['app']}'."
    fi
    [[ -n "${dict['app_name']}" ]] || return 1
    [[ -n "${dict['bin_name']}" ]] || return 1
    if [[ -z "${dict['system_bin_name']}" ]]
    then
        dict['system_bin_name']="${dict['bin_name']}"
    fi
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        dict['saved_path']="${PATH:?}"
        _koopa_remove_from_path "${KOOPA_PREFIX:?}/bin"
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        export PATH="${dict['saved_path']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_bootstrap']}" -eq 1 ]]
    then
        dict['app']="${XDG_DATA_HOME:-${HOME:?}/.local/share}/koopa-bootstrap/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_koopa_bin']}" -eq 1 ]]
    then
        dict['app']="${KOOPA_PREFIX:?}/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_opt_bin']}" -eq 1 ]]
    then
        dict['app']="${KOOPA_PREFIX:?}/opt/${dict['app_name']}/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        __emit_if_found && return 0
    fi
    [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        _koopa_stop \
            "Failed to locate '${dict['system_bin_name']}'."
    else
        _koopa_stop \
            "Failed to locate '${dict['bin_name']}'." \
            "Run 'koopa install ${dict['app_name']}' to resolve."
    fi
}

_koopa_locate_conda_python() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='python' \
        "$@"
}

_koopa_locate_conda() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='conda' \
        "$@"
}

_koopa_locate_grep() {
    _koopa_locate_app \
        --app-name='grep' \
        --bin-name='ggrep' \
        --system-bin-name='grep' \
        "$@"
}

_koopa_locate_groups() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ggroups' \
        --system-bin-name='groups' \
        "$@"
}

_koopa_locate_head() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ghead' \
        --system-bin-name='head' \
        "$@"
}

_koopa_locate_locale() {
    _koopa_locate_app \
        '/usr/bin/locale' \
        "$@"
}

_koopa_locate_man() {
    _koopa_locate_app \
        --app-name='man-db' \
        --bin-name='gman' \
        --system-bin-name='man' \
        "$@"
}

_koopa_locate_r() {
    _koopa_locate_app \
        --app-name='r' \
        --bin-name='R' \
        "$@"
}

_koopa_locate_rg() {
    _koopa_locate_app \
        --app-name='ripgrep' \
        --bin-name='rg' \
        "$@"
}

_koopa_locate_ruby() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='ruby' \
        "$@"
}

_koopa_locate_sed() {
    _koopa_locate_app \
        --app-name='sed' \
        --bin-name='gsed' \
        --system-bin-name='sed' \
        "$@"
}

_koopa_locate_sudo() {
    _koopa_locate_app \
        '/usr/bin/sudo' \
        "$@"
}

_koopa_locate_tail() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtail' \
        --system-bin-name='tail' \
        "$@"
}

_koopa_macos_activate_cli_colors() {
    [[ -z "${CLICOLOR:-}" ]] && export CLICOLOR=1
    return 0
}

_koopa_macos_activate_egnyte() {
    _koopa_add_to_path_end "${HOME}/Library/Group Containers/\
FELUD555VC.group.com.egnyte.DesktopApp/CLI"
    return 0
}

_koopa_macos_activate_homebrew() {
    local -A dict
    dict['prefix']="$(_koopa_homebrew_prefix)"
    if [[ ! -x "${dict['prefix']}/bin/brew" ]]
    then
        return 0
    fi
    dict['brewfile']="$(_koopa_xdg_config_home)/homebrew/Brewfile"
    _koopa_add_to_path_start "${dict['prefix']}/bin"
    if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]] \
        && [[ -f "${dict['brewfile']}" ]]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="${dict['brewfile']}"
    fi
    if [[ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ]]
    then
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    fi
    if [[ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ]]
    then
        export HOMEBREW_INSTALL_CLEANUP=1
    fi
    if [[ -z "${HOMEBREW_NO_ENV_HINTS:-}" ]]
    then
        export HOMEBREW_NO_ENV_HINTS=1
    fi
    return 0
}

_koopa_macos_emacs() {
    local homebrew_prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    [[ -d "$homebrew_prefix" ]] || return 1
    local emacs
    emacs="${homebrew_prefix}/bin/emacs"
    [[ -x "$emacs" ]] || return 1
    _koopa_print "$emacs"
    return 0
}

_koopa_macos_is_dark_mode() {
    [[ "$( \
        /usr/bin/defaults read -g 'AppleInterfaceStyle' \
        2>/dev/null \
    )" == 'Dark' ]]
}

_koopa_app_prefix() {
    local -A dict
    local -a pos
    dict['allow_missing']=0
    dict['app_prefix']="$(_koopa_koopa_prefix)/app"
    if [[ "$#" -eq 0 ]]
    then
        _koopa_print "${dict['app_prefix']}"
        return 0
    fi
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--allow-missing')
                dict['allow_missing']=1
                shift 1
                ;;
            'python')
                dict['python_version']="$(_koopa_python_major_minor_version)"
                pos+=("python${dict['python_version']}")
                shift 1
                ;;
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    for app_name in "$@"
    do
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['version']="$( \
            _koopa_app_json_version "${dict2['app_name']}" \
            2>/dev/null \
            || true \
        )"
        if [[ -z "${dict2['version']}" ]]
        then
            _koopa_stop "Unsupported app: '${dict2['app_name']}'."
        fi
        if [[ "${#dict2['version']}" == 40 ]]
        then
            dict2['version']="${dict2['version']:0:7}"
        fi
        dict2['prefix']="${dict['app_prefix']}/${dict2['app_name']}/\
${dict2['version']}"
        if [[ ! -d "${dict2['prefix']}" ]] && \
            [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            continue
        fi
        _koopa_assert_is_dir "${dict2['prefix']}"
        dict2['prefix']="$(_koopa_realpath "${dict2['prefix']}")"
        _koopa_print "${dict2['prefix']}"
    done
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

_koopa_bash_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/lang/bash"
    return 0
}

_koopa_bin_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/bin"
    return 0
}

_koopa_bootstrap_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/koopa-bootstrap"
    return 0
}

_koopa_conda_env_prefix() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['conda']="$(_koopa_locate_conda)"
    app['python']="$(_koopa_locate_conda_python)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    app['tail']="$(_koopa_locate_tail --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:-}"
    dict['env_prefix']="$( \
        "${app['conda']}" info --json \
        | "${app['python']}" -c \
            "import json,sys;print(json.load(sys.stdin)['envs_dirs'][0])" \
    )"
    [[ -n "${dict['env_prefix']}" ]] || return 1
    if [[ -z "${dict['env_name']}" ]]
    then
        _koopa_print "${dict['env_prefix']}"
        return 0
    fi
    dict['prefix']="${dict['env_prefix']}/${dict['env_name']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        _koopa_print "${dict['prefix']}"
        return 0
    fi
    dict['env_list']="$(_koopa_conda_env_list)"
    dict['env_list2']="$( \
        _koopa_grep \
            --pattern="${dict['env_name']}" \
            --string="${dict['env_list']}" \
    )"
    [[ -n "${dict['env_list2']}" ]] || return 1
    dict['prefix']="$( \
        _koopa_grep \
            --pattern="/${dict['env_name']}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict['env_list']}" \
        | "${app['tail']}" -n 1 \
        | "${app['sed']}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict['prefix']}" ]] || return 1
    _koopa_print "${dict['prefix']}"
    return 0
}

_koopa_conda_pkg_cache_prefix() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    app['python']="$(_koopa_locate_conda_python)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['conda']}" info --json \
        | "${app['python']}" -c \
            "import json,sys;print(json.load(sys.stdin)['pkgs_dirs'][0])" \
    )"
    [[ -n "${dict['prefix']}" ]] || return 1
    _koopa_print "${dict['prefix']}"
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

_koopa_dotfiles_prefix() {
    _koopa_print "$(_koopa_config_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_dotfiles_work_prefix() {
    _koopa_print "$(_koopa_config_prefix)/dotfiles-work"
    return 0
}

_koopa_emacs_prefix() {
    _koopa_print "${HOME:?}/.emacs.d"
    return 0
}

_koopa_go_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/go"
    return 0
}

_koopa_homebrew_prefix() {
    local string
    string="${HOMEBREW_PREFIX:-}"
    if [[ -z "$string" ]]
    then
        if _koopa_is_installed 'brew'
        then
            string="$(brew --prefix)"
        elif _koopa_is_macos
        then
            case "$(_koopa_arch)" in
                'arm'*)
                    string='/opt/homebrew'
                    ;;
                'x86'*)
                    string='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            string='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_julia_packages_prefix() {
    _koopa_print "${HOME:?}/.julia"
}

_koopa_julia_script_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/lang/julia/include"
    return 0
}

_koopa_koopa_prefix() {
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_local_data_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)"
    return 0
}

_koopa_man_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/share/man"
    return 0
}

_koopa_man1_prefix() {
    _koopa_print "$(_koopa_man_prefix)/man1"
    return 0
}

_koopa_monorepo_prefix() {
    _koopa_print "${HOME:?}/monorepo"
    return 0
}

_koopa_opt_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/opt"
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

_koopa_pyenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}

_koopa_python_system_packages_prefix() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['python']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['python']}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_print "${dict['prefix']}"
    return 0
}

_koopa_python_virtualenvs_prefix() {
    _koopa_print "${HOME}/.virtualenvs"
    return 0
}

_koopa_r_library_prefix() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(_koopa_locate_r)"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_print "${dict['prefix']}"
    return 0
}

_koopa_r_packages_prefix() {
    local -A app dict
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    dict['r_prefix']="$(_koopa_r_prefix "${app['r']}")"
    dict['str']="${dict['r_prefix']}/site-library"
    [[ -d "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_r_prefix() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(_koopa_locate_r)"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_print "${dict['prefix']}"
    return 0
}

_koopa_r_scripts_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/lang/r/scripts"
    return 0
}

_koopa_r_system_library_prefix() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(_koopa_locate_r)"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_print "${dict['prefix']}"
    return 0
}

_koopa_rbenv_prefix() {
    _koopa_print "$(_koopa_opt_prefix)/rbenv"
    return 0
}

_koopa_ruby_gem_user_install_prefix() {
    local -A app dict
    app['ruby']="$(_koopa_locate_ruby)"
    _koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['ruby']}" -r rubygems -e 'puts Gem.user_dir')"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_scripts_private_prefix() {
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_spacemacs_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacemacs"
    return 0
}

_koopa_spacevim_prefix() {
    _koopa_print "$(_koopa_xdg_data_home)/spacevim"
    return 0
}

_koopa_tests_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/etc/koopa/tests"
    return 0
}

_koopa_python_major_minor_version() {
    _koopa_print '3.14'
    return 0
}

_koopa_xdg_cache_home() {
    local string
    string="${XDG_CACHE_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.cache"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_xdg_config_dirs() {
    local string
    string="${XDG_CONFIG_DIRS:-}"
    if [[ -z "$string" ]]
    then
        string='/etc/xdg'
    fi
    _koopa_print "$string"
    return 0
}

_koopa_xdg_config_home() {
    local string
    string="${XDG_CONFIG_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.config"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_xdg_data_dirs() {
    local string
    string="${XDG_DATA_DIRS:-}"
    if [[ -z "$string" ]]
    then
        string='/usr/local/share:/usr/share'
    fi
    _koopa_print "$string"
    return 0
}

_koopa_xdg_data_home() {
    local string
    string="${XDG_DATA_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="${HOME:?}/.local/share"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_xdg_local_home() {
    _koopa_print "${HOME:?}/.local"
    return 0
}

_koopa_xdg_state_home() {
    local string
    string="${XDG_STATE_HOME:-}"
    if [[ -z "$string" ]]
    then
        string="$(_koopa_xdg_local_home)/state"
    fi
    _koopa_print "$string"
    return 0
}

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
    local _koopa_prefix
    _koopa_prefix="$(_koopa_koopa_prefix)"
    local file
    for file in "${_koopa_prefix}/etc/completion/"*'.sh'
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

_koopa_activate_ensembl_perl_api() {
    local -A dict
    dict['prefix']="$(_koopa_app_prefix 'ensembl-perl-api')"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_add_to_path_start "${dict['prefix']}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB:-}"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-funcgen/modules"
    export PERL5LIB
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

_koopa_activate_pkg_config() {
    local app
    _koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app in "$@"
    do
        local str
        [[ -x "$app" ]] || continue
        str="$("$app" --variable 'pc_path' 'pkg-config')"
        PKG_CONFIG_PATH="$( \
            _koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$str" \
        )"
    done
    export PKG_CONFIG_PATH
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

_koopa_activate_ssh_key() {
    local key nounset
    _koopa_is_linux || return 0
    key="${1:-}"
    if [[ -z "$key" ]] && [[ -n "${SSH_KEY:-}" ]]
    then
        key="${SSH_KEY:?}"
    else
        key="${HOME:?}/.ssh/id_rsa"
    fi
    if [[ ! -r "$key" ]]
    then
        return 0
    fi
    _koopa_is_installed 'ssh-add' 'ssh-agent' || return 1
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [[ "$nounset" -eq 1 ]] && set -o nounset
    ssh-add "$key" >/dev/null 2>&1
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

_koopa_add_conda_env_to_path() {
    local name
    _koopa_assert_has_args "$#"
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        local bin_dir
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            _koopa_warn "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        _koopa_add_to_path_start "$bin_dir"
    done
    return 0
}

_koopa_add_config_link() {
    local -A dict
    _koopa_assert_has_args_ge "$#" 2
    dict['config_prefix']="$(_koopa_config_prefix)"
    while [[ "$#" -ge 2 ]]
    do
        local -A dict2
        dict2['source_file']="${1:?}"
        dict2['dest_name']="${2:?}"
        shift 2
        _koopa_assert_is_existing "${dict2['source_file']}"
        if _koopa_str_detect_fixed \
            --pattern="${dict['config_prefix']}" \
            --string="${dict2['source_file']}"
        then
            _koopa_stop "${dict2['source_file']} is sourced \
inside '${dict['config_prefix']}'."
        fi
        dict2['dest_file']="${dict['config_prefix']}/${dict2['dest_name']}"
        _koopa_is_symlink "${dict2['dest_file']}" && continue
        _koopa_ln --verbose "${dict2['source_file']}" "${dict2['dest_file']}"
    done
    return 0
}

_koopa_add_make_prefix_link() {
    local -A dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    dict['koopa_prefix']="${1:-}"
    dict['make_prefix']='/usr/local'
    if [[ -z "${dict['koopa_prefix']}" ]]
    then
        dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    fi
    dict['source_link']="${dict['koopa_prefix']}/bin/koopa"
    dict['target_link']="${dict['make_prefix']}/bin/koopa"
    [[ -d "${dict['make_prefix']}" ]] || return 0
    [[ -L "${dict['target_link']}" ]] && return 0
    _koopa_alert "Adding 'koopa' link inside '${dict['make_prefix']}'."
    _koopa_ln --sudo "${dict['source_link']}" "${dict['target_link']}"
    return 0
}

_koopa_add_monorepo_config_link() {
    local -A dict
    local subdir
    _koopa_assert_has_args "$#"
    _koopa_assert_has_monorepo
    dict['prefix']="$(_koopa_monorepo_prefix)"
    for subdir in "$@"
    do
        _koopa_add_config_link \
            "${dict['prefix']}/${subdir}" \
            "$subdir"
    done
    return 0
}

_koopa_add_rpath_to_ldflags() {
    local dir
    _koopa_assert_has_args "$#"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        _koopa_append_ldflags "-Wl,-rpath,${dir}"
    done
    return 0
}

_koopa_add_to_pkg_config_path() {
    local dir
    _koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PKG_CONFIG_PATH="$( \
            _koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

_koopa_alert_coffee_time() {
    _koopa_alert_note 'This step takes a while. Time for a coffee break! ☕'
}

_koopa_alert_configure_start() {
    _koopa_alert_process_start 'Configuring' "$@"
}

_koopa_alert_configure_success() {
    _koopa_alert_process_success 'Configuration' "$@"
}

_koopa_alert_info() {
    _koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

_koopa_alert_install_start() {
    _koopa_alert_process_start 'Installing' "$@"
}

_koopa_alert_install_success() {
    _koopa_alert_process_success 'Installation' "$@"
}

_koopa_alert_is_not_installed() {
    local -A dict
    dict['name']="${1:?}"
    dict['prefix']="${2:-}"
    dict['string']="'${dict['name']}' not installed"
    if [[ -n "${dict['prefix']}" ]]
    then
        dict['string']="${dict['string']} at '${dict['prefix']}'"
    fi
    dict['string']="${dict['string']}."
    _koopa_alert_note "${dict['string']}"
    return 0
}

_koopa_alert_note() {
    _koopa_msg 'yellow' 'default' '**' "$@"
}

_koopa_alert_process_start() {
    local -A dict
    dict['word']="${1:?}"
    shift 1
    _koopa_assert_has_args_le "$#" 3
    dict['name']="${1:?}"
    dict['version']=''
    dict['prefix']=''
    if [[ "$#" -eq 2 ]]
    then
        dict['prefix']="${2:-}"
    elif [[ "$#" -eq 3 ]]
    then
        dict['version']="${2:-}"
        dict['prefix']="${3:-}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ -n "${dict['version']}" ]]
    then
        dict['out']="${dict['word']} '${dict['name']}' ${dict['version']} \
at '${dict['prefix']}'."
    elif [[ -n "${dict['prefix']}" ]]
    then
        dict['out']="${dict['word']} '${dict['name']}' at '${dict['prefix']}'."
    else
        dict['out']="${dict['word']} '${dict['name']}'."
    fi
    _koopa_alert "${dict['out']}"
    return 0
}

_koopa_alert_process_success() {
    local -A dict
    dict['word']="${1:?}"
    shift 1
    _koopa_assert_has_args_le "$#" 2
    dict['name']="${1:?}"
    dict['prefix']="${2:-}"
    if [[ -n "${dict['prefix']}" ]]
    then
        dict['out']="${dict['word']} of '${dict['name']}' at \
'${dict['prefix']}' was successful."
    else
        dict['out']="${dict['word']} of '${dict['name']}' was successful."
    fi
    _koopa_alert_success "${dict['out']}"
    return 0
}

_koopa_alert_restart() {
    _koopa_alert_note 'Restart the shell.'
}

_koopa_alert_success() {
    _koopa_msg 'green-bold' 'green' '✓' "$@"
}

_koopa_alert_uninstall_start() {
    _koopa_alert_process_start 'Uninstalling' "$@"
}

_koopa_alert_uninstall_success() {
    _koopa_alert_process_success 'Uninstallation' "$@"
}

_koopa_alert_update_start() {
    _koopa_alert_process_start 'Updating' "$@"
}

_koopa_alert_update_success() {
    _koopa_alert_process_success 'Update' "$@"
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
    local _koopa_prefix
    _koopa_prefix="$(_koopa_koopa_prefix)"
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
    rcfile="${_koopa_prefix}/lang/bash/include/header.sh"
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

_koopa_alias_python3_dev() {
    PYTHONPATH="$(pwd)" python3
}

_koopa_alias_realcd() {
    local dir
    dir="${1:-}"
    [[ -z "$dir" ]] && dir="$(pwd)"
    dir="$(_koopa_realpath "$dir")"
    cd "$dir" || return 1
    return 0
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

_koopa_alpine_locate_localedef() {
    _koopa_locate_app \
        '/usr/glibc-compat/bin/localedef' \
        "$@"
}

_koopa_assert_can_push_binary() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_can_push_binary
    then
        _koopa_stop 'System not configured to push binaries.'
    fi
    return 0
}

_koopa_assert_conda_env_is_not_active() {
    _koopa_assert_has_no_args "$#"
    if _koopa_is_conda_env_active
    then
        _koopa_stop \
            'Active Conda environment detected.' \
            "Run 'conda deactivate' command before proceeding."
    fi
    return 0
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

_koopa_assert_has_monorepo() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_has_monorepo
    then
        _koopa_stop "No monorepo at '$(_koopa_monorepo_prefix)'."
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

_koopa_assert_has_no_flags() {
    _koopa_assert_has_args "$#"
    while (("$#"))
    do
        case "$1" in
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                shift 1
                ;;
        esac
    done
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

_koopa_assert_is_array_non_empty() {
    if ! _koopa_is_array_non_empty "$@"
    then
        _koopa_stop 'Array is empty.'
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

_koopa_assert_is_existing() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -e "$arg" ]]
        then
            _koopa_stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_file_type() {
    _koopa_assert_has_args "$#"
    if ! _koopa_is_file_type "$@"
    then
        _koopa_stop 'Input does not match expected file type extension.'
    fi
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

_koopa_assert_is_installed() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_stop "Not installed: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_matching_fixed() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['pattern']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
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
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! _koopa_str_detect_fixed \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        _koopa_stop "'${dict['string']}' doesn't match '${dict['pattern']}'."
    fi
    return 0
}

_koopa_assert_is_matching_regex() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['pattern']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
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
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! _koopa_str_detect_regex \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        _koopa_stop "'${dict['string']}' doesn't match regular expression \
pattern '${dict['pattern']}'."
    fi
    return 0
}

_koopa_assert_is_not_compressed_file() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if _koopa_is_compressed_file "$arg"
        then
            _koopa_stop "Compressed file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_dir() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -d "$arg" ]]
        then
            _koopa_stop "Directory exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_file() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -f "$arg" ]]
        then
            _koopa_stop "File exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_symlink() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -L "$arg" ]]
        then
            _koopa_stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_owner() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_owner
    then
        dict['prefix']="$(_koopa_koopa_prefix)"
        dict['user']="$(_koopa_user_name)"
        _koopa_stop "Koopa installation at '${dict['prefix']}' is not \
owned by '${dict['user']}'."
    fi
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

_koopa_assert_is_symlink() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -L "$arg" ]]
        then
            _koopa_stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_python_venv_is_not_active() {
    _koopa_assert_has_no_args "$#"
    if _koopa_is_python_venv_active
    then
        _koopa_stop \
            'Active Python virtual environment detected.' \
            "Run 'deactivate' command before proceeding."
    fi
    return 0
}

_koopa_acid_emoji() {
    _koopa_print '🧪'
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

_koopa_admin_group_id() {
    local -A app dict
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group_name']="$(_koopa_admin_group_name)"
    dict['group_id']="$( \
        _koopa_getent 'group' "${dict['group_name']}" \
        | "${app['cut']}" -d ':' -f 3 \
    )"
    [[ -n "${dict['group_id']}" ]] || return 1
    _koopa_print "${dict['group_id']}"
    return 0
}

_koopa_admin_group_name() {
    local group
    _koopa_assert_has_no_args "$#"
    if _koopa_is_root
    then
        group='root'
    elif _koopa_is_alpine
    then
        group='wheel'
    elif _koopa_is_arch
    then
        group='wheel'
    elif _koopa_is_debian_like
    then
        group='sudo'
    elif _koopa_is_fedora_like
    then
        group='wheel'
    elif _koopa_is_macos
    then
        group='admin'
    elif _koopa_is_opensuse
    then
        group='wheel'
    else
        _koopa_stop 'Failed to determine admin group.'
    fi
    _koopa_print "$group"
    return 0
}

_koopa_admin_user_id() {
    _koopa_print '0'
    return 0
}

_koopa_admin_user_name() {
    _koopa_print 'root'
    return 0
}

_koopa_alert() {
    _koopa_msg 'default' 'default' '→' "$@"
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

_koopa_app_dependencies() {
    _koopa_assert_has_args_eq "$#" 1
    "${KOOPA_PREFIX:?}/bin/koopa" internal app-dependencies "$@"
}

_koopa_app_json_bin() {
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='bin'
    done
}

_koopa_app_json_man1() {
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='man1'
    done
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

_koopa_app_version() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['name']="${1:?}"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    _koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(_koopa_realpath "${dict['symlink']}")"
    dict['version']="$(_koopa_basename "${dict['realpath']}")"
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_append_cflags() {
    local str
    _koopa_assert_has_args "$#"
    CFLAGS="${CFLAGS:-}"
    for str in "$@"
    do
        CFLAGS="${CFLAGS} ${str}"
    done
    export CFLAGS
    return 0
}

_koopa_append_cppflags() {
    local str
    _koopa_assert_has_args "$#"
    CPPFLAGS="${CPPFLAGS:-}"
    for str in "$@"
    do
        CPPFLAGS="${CPPFLAGS} ${str}"
    done
    export CPPFLAGS
    return 0
}

_koopa_append_cxxflags() {
    local str
    _koopa_assert_has_args "$#"
    CXXFLAGS="${CXXFLAGS:-}"
    for str in "$@"
    do
        CXXFLAGS="${CXXFLAGS} ${str}"
    done
    export CXXFLAGS
    return 0
}

_koopa_append_ldflags() {
    local str
    _koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for str in "$@"
    do
        LDFLAGS="${LDFLAGS} ${str}"
    done
    export LDFLAGS
    return 0
}

_koopa_append_string() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    if [[ ! -f "${dict['file']}" ]]
    then
        _koopa_mkdir "$(_koopa_dirname "${dict['file']}")"
        _koopa_touch "${dict['file']}"
    fi
    _koopa_print "${dict['string']}" >> "${dict['file']}"
    return 0
}

_koopa_apply_debian_patch_set() {
    local -A app dict
    local -a patch_series
    app['patch']="$(_koopa_locate_patch)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['patch_version']=''
    dict['target']=''
    dict['version']=''
    while (("$#"))
    do
        case "$1" in
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--patch-version='*)
                dict['patch_version']="${1#*=}"
                shift 1
                ;;
            '--patch-version')
                dict['patch_version']="${2:?}"
                shift 2
                ;;
            '--target='*)
                dict['target']="${1#*=}"
                shift 1
                ;;
            '--target')
                dict['target']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    _koopa_assert_is_dir "${dict['target']}"
    dict['url']="https://deb.debian.org/debian/pool/main/${dict['name']:0:1}/\
${dict['name']}/${dict['name']}_${dict['version']}-${dict['patch_version']}.\
debian.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'debian'
    _koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        _koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(_koopa_realpath "../debian/patches/${patch}")"
            _koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}

_koopa_apply_ubuntu_patch_set() {
    local -A app dict
    local -a patch_series
    app['patch']="$(_koopa_locate_patch)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['patch_version']=''
    dict['target']=''
    dict['version']=''
    while (("$#"))
    do
        case "$1" in
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--patch-version='*)
                dict['patch_version']="${1#*=}"
                shift 1
                ;;
            '--patch-version')
                dict['patch_version']="${2:?}"
                shift 2
                ;;
            '--target='*)
                dict['target']="${1#*=}"
                shift 1
                ;;
            '--target')
                dict['target']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    _koopa_assert_is_dir "${dict['target']}"
    dict['url']="http://archive.ubuntu.com/ubuntu/pool/main/\
${dict['name']:0:1}/${dict['name']}/${dict['name']}_${dict['version']}-\
${dict['patch_version']}ubuntu1.debian.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'debian'
    _koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        _koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(_koopa_realpath .."/debian/patches/${patch}")"
            _koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}

_koopa_arch() {
    local string
    string="$(uname -m)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_arch2() {
    local str
    _koopa_assert_has_no_args "$#"
    str="$(_koopa_arch)"
    case "$str" in
        'aarch64')
            str='arm64'
            ;;
        'x86_64')
            str='amd64'
            ;;
    esac
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_autopad_zeros() {
    local -A dict
    local -a pos
    local file
    _koopa_assert_has_args "$#"
    dict['dryrun']=0
    dict['padwidth']=2
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pad-width='* | \
            '--padwidth='*)
                dict['padwidth']="${1#*=}"
                shift 1
                ;;
            '--pad-width' | \
            '--padwidth')
                dict['padwidth']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--dry-run' | \
            '--dryrun')
                dict['dryrun']=1
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
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict2
        dict2['source']="$file"
        dict2['bn']="$(_koopa_basename "${dict2['source']}")"
        dict2['dn']="$(_koopa_dirname "${dict2['source']}")"
        if [[ "${dict2['bn']}" =~ ^([0-9]+)(.*)$ ]]
        then
            dict2['num']="${BASH_REMATCH[1]}"
            dict2['num']="$(printf "%.${dict['padwidth']}d" "${dict2['num']}")"
            dict2['stem']="${BASH_REMATCH[2]}"
            dict2['bn2']="${dict['prefix']}${dict2['num']}${dict2['stem']}"
            dict2['target']="${dict2['dn']}/${dict2['bn2']}"
            _koopa_alert "Renaming '${dict2['source']}' to '${dict2['target']}'."
            [[ "${dict['dryrun']}" -eq 1 ]] && continue
            _koopa_mv "${dict2['source']}" "${dict2['target']}"
        else
            _koopa_alert_note "Skipping '${dict2['source']}'."
        fi
    done
    return 0
}

_koopa_bam_read_length() {
    local -A app dict
    local bam_file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk)"
    app['head']="$(_koopa_locate_head)"
    app['samtools']="$(_koopa_locate_samtools)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(_koopa_cpu_count)"
    for bam_file in "$@"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['num']="$( \
            "${app['samtools']}" view \
                -@ "${dict['threads']}" \
                "${dict2['bam_file']}" \
            | "${app['head']}" -n 1000000 \
            | "${app['awk']}" '{print length($10)}' \
            | "${app['sort']}" -nu \
            | "${app['head']}" -n 1 \
            || true \
        )"
        [[ -n "${dict2['num']}" ]] || return 1
        _koopa_print "${dict2['num']}"
    done
    return 0
}

_koopa_bam_read_type() {
    local -A app dict
    local bam_file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(_koopa_cpu_count)"
    for bam_file in "$@"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['num']="$( \
            "${app['samtools']}" view \
                -@ "${dict['threads']}" \
                -c \
                -f 1 \
                "${dict2['bam_file']}" \
        )"
        if [[ "${dict2['num']}" -gt 0 ]]
        then
            dict2['type']='paired'
        else
            dict2['type']='single'
        fi
        _koopa_print "${dict2['type']}"
    done
    return 0
}

_koopa_basename_sans_ext_2() {
    local -A app
    local file
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$(_koopa_basename "$file")"
        if _koopa_has_file_ext "$str"
        then
            str="$( \
                _koopa_print "$str" \
                | "${app['cut']}" -d '.' -f '1' \
            )"
        fi
        _koopa_print "$str"
    done
    return 0
}

_koopa_basename_sans_ext() {
    local file
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for file in "$@"
    do
        local str
        str="$(_koopa_basename "$file")"
        if _koopa_has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        _koopa_print "$str"
    done
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

_koopa_bioconda_autobump_recipe() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['git']="$(_koopa_locate_git --allow-system)"
    app['vim']="$(_koopa_locate_vim --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['recipe']="${1:?}"
    dict['repo']="${HOME:?}/git/github/bioconda/bioconda-recipes"
    dict['branch']="${dict['recipe']/-/_}"
    _koopa_assert_is_dir "${dict['repo']}"
    (
        _koopa_cd "${dict['repo']}"
        "${app['git']}" checkout master
        "${app['git']}" fetch --all
        "${app['git']}" pull
        "${app['git']}" checkout \
            -B "${dict['branch']}" \
            "origin/bump/${dict['branch']}"
        "${app['git']}" pull origin master
        _koopa_mkdir "recipes/${dict['recipe']}"
        "${app['vim']}" "recipes/${dict['recipe']}/meta.yaml"
    )
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

_koopa_cache_functions_dir() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -A dict
        dict['prefix']="$prefix"
        _koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        _koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        if _koopa_str_detect_fixed \
            --pattern='/bash/' \
            --string="${dict['prefix']}"
        then
            dict['shebang']='#!/usr/bin/env bash'
        else
            dict['shebang']='#!/bin/sh'
        fi
        {
            printf '%s\n' "${dict['shebang']}"
            printf '%s\n' '# shellcheck disable=all'
            "${app['find']}" "${dict['prefix']}" \
                -type 'f' -name '*.sh' -print0 \
            | "${app['sort']}" -z \
            | "${app['xargs']}" -0 "${app['cat']}" \
            | "${app['grep']}" -Eiv '^(\s+)?#'
        } | "${app['cat']}" -s > "${dict['target_file']}"
    done
    return 0
}

_koopa_cache_functions_dirs() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    dict['target_file']="${1:?}"
    dict['source_prefix']="${2:?}"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_dir "${dict['source_prefix']}"
    if _koopa_str_detect_fixed \
        --pattern='/bash/' \
        --string="${dict['target_file']}"
    then
        dict['shebang']='#!/usr/bin/env bash'
    else
        dict['shebang']='#!/bin/sh'
    fi
    _koopa_alert "Caching functions in '${dict['target_file']}'."
    {
        printf '%s\n' "${dict['shebang']}"
        printf '%s\n' '# shellcheck disable=all'
        "${app['find']}" "${dict['source_prefix']}" \
            -type 'f' -name '*.sh' -print0 \
        | "${app['sort']}" -z \
        | "${app['xargs']}" -0 "${app['cat']}" \
        | "${app['grep']}" -Eiv '^(\s+)?#'
    } | "${app['cat']}" -s > "${dict['target_file']}"
    return 0
}

_koopa_cache_functions() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['prefix']}/lang"
    dict['bash_prefix']="${dict['lang_prefix']}/bash"
    dict['sh_prefix']="${dict['lang_prefix']}/sh"
    dict['zsh_prefix']="${dict['lang_prefix']}/zsh"
    _koopa_cache_functions_dirs \
        "${dict['bash_prefix']}/include/functions.sh" \
        "${dict['bash_prefix']}/functions"
    _koopa_cache_functions_dirs \
        "${dict['sh_prefix']}/include/functions.sh" \
        "${dict['sh_prefix']}/functions"
    _koopa_cache_functions_dirs \
        "${dict['zsh_prefix']}/include/functions.sh" \
        "${dict['zsh_prefix']}/functions"
    return 0
}

_koopa_camel_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        _koopa_gsub \
            --pattern='([ -_])([a-z])' \
            --regex \
            --replacement='\U\2' \
            "$@" \
    )"
    _koopa_is_array_non_empty "${out[@]:-}" || return 1
    _koopa_print "${out[@]}"
    return 0
}

_koopa_can_build_binary() {
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]]
}

_koopa_can_install_binary() {
    case "${KOOPA_CAN_INSTALL_BINARY:-}" in
        '0')
            return 1
            ;;
        '1')
            return 0
            ;;
    esac
    _koopa_can_build_binary && return 1
    _koopa_has_private_access || return 1
    return 0
}

_koopa_can_push_binary() {
    local -A app
    _koopa_has_private_access || return 1
    _koopa_can_build_binary || return 1
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    app['aws']="$(_koopa_locate_aws --allow-missing)"
    [[ -x "${app['aws']}" ]] || return 1
    return 0
}

_koopa_capitalize() {
    local -A app
    local str
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$("${app['tr']}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        _koopa_print "$str"
    done
    return 0
}

_koopa_cd() {
    local prefix
    _koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    cd "$prefix" >/dev/null 2>&1 || return 1
    return 0
}

_koopa_check_build_system() {
    local -A app dict ver1 ver2
    local key
    _koopa_assert_has_no_args "$#"
    if _koopa_is_macos
    then
        dict['sdk_prefix']="$(_koopa_macos_sdk_prefix)"
        if [[ ! -d "${dict['sdk_prefix']}" ]]
        then
            _koopa_stop "Xcode CLT not installed at '${dict['prefix']}.\
Run 'xcode-select --install' to resolve."
        fi
    fi
    app['cc']="$(_koopa_locate_cc --only-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['ld']="$(_koopa_locate_ld --only-system)"
    app['make']="$(_koopa_locate_make --only-system)"
    app['perl']="$(_koopa_locate_perl --only-system)"
    app['python']="$(_koopa_locate_python --allow-bootstrap --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    ver1['cc']="$(_koopa_get_version "${app['cc']}")"
    ver1['git']="$(_koopa_get_version "${app['git']}")"
    ver1['make']="$(_koopa_get_version "${app['make']}")"
    ver1['perl']="$(_koopa_get_version "${app['perl']}")"
    ver1['python']="$(_koopa_get_version "${app['python']}")"
    if _koopa_is_macos
    then
        case "${ver1['cc']}" in
            '16.0.0.0.1.1724870825')
                _koopa_stop "Unsupported cc: ${app['cc']} ${ver1['cc']}."
                ;;
        esac
        ver2['cc']='14.0'
    elif _koopa_is_linux
    then
        ver2['cc']='7.0'
    fi
    ver2['git']='1.8'
    ver2['make']='3.8'
    ver2['perl']='5.16'
    ver2['python']='3.6'
    for key in "${!ver1[@]}"
    do
        if ! _koopa_compare_versions "${ver1[$key]}" -ge "${ver2[$key]}"
        then
            _koopa_stop "Unsupported ${key}: ${app[$key]} \
(${ver1[$key]} < ${ver2[$key]})."
        fi
    done
    return 0
}

_koopa_check_disk() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['limit']=90
    dict['used']="$(_koopa_disk_pct_used "$@")"
    if [[ "${dict['used']}" -gt "${dict['limit']}" ]]
    then
        _koopa_warn "Disk usage is ${dict['used']}%."
        return 1
    fi
    return 0
}

_koopa_check_exports() {
    local -a vars
    _koopa_assert_has_no_args "$#"
    _koopa_is_rstudio && return 0
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    _koopa_warn_if_export "${vars[@]}"
    return 0
}

_koopa_check_mount() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['wc']="$(_koopa_locate_wc --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    if [[ ! -r "${dict['prefix']}" ]] || [[ ! -d "${dict['prefix']}" ]]
    then
        _koopa_warn "'${dict['prefix']}' is not a readable directory."
        return 1
    fi
    dict['nfiles']="$( \
        _koopa_find \
            --prefix="${dict['prefix']}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app['wc']}" -l \
    )"
    if [[ "${dict['nfiles']}" -eq 0 ]]
    then
        _koopa_warn "'${dict['prefix']}' is unmounted and/or empty."
        return 1
    fi
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

_koopa_check_shared_object() {
    local -A app dict
    local -a tool_args
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['name']=''
    dict['prefix']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['file']}" ]]
    then
        _koopa_assert_is_set \
            '--name' "${dict['name']}" \
            '--prefix' "${dict['prefix']}"
        if _koopa_is_linux
        then
            dict['shared_ext']='so'
        elif _koopa_is_macos
        then
            dict['shared_ext']='dylib'
        fi
        dict['file']="${dict['prefix']}/${dict['name']}.${dict['shared_ext']}"
    fi
    _koopa_assert_is_file "${dict['file']}"
    tool_args=()
    if _koopa_is_linux
    then
        app['tool']="$(_koopa_linux_locate_ldd)"
    elif _koopa_is_macos
    then
        app['tool']="$(_koopa_macos_locate_otool)"
        tool_args+=('-L')
    fi
    _koopa_assert_is_executable "${app[@]}"
    tool_args+=("${dict['file']}")
    "${app['tool']}" "${tool_args[@]}"
    return 0
}

_koopa_chgrp() {
    local -A app dict
    local -a chgrp pos
    app['chgrp']="$(_koopa_locate_chgrp)"
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        chgrp=('_koopa_sudo' "${app['chgrp']}")
    else
        chgrp=("${app['chgrp']}")
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${chgrp[@]}" "$@"
    return 0
}

_koopa_chmod() {
    local -A app bool
    local -a chmod pos
    app['chmod']="$(_koopa_locate_chmod)"
    bool['recursive']=0
    bool['sudo']=0
    bool['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive' | \
            '-R')
                bool['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                bool['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                bool['verbose']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        chmod=('_koopa_sudo' "${app['chmod']}")
    else
        chmod=("${app['chmod']}")
    fi
    if [[ "${bool['recursive']}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        chmod+=('-v')
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${chmod[@]}" "$@"
    return 0
}

_koopa_chown() {
    local -A app dict
    local -a chown pos
    app['chown']="$(_koopa_locate_chown)"
    dict['dereference']=1
    dict['recursive']=0
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict['dereference']=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict['dereference']=0
                shift 1
                ;;
            '--recursive' | \
            '-R')
                dict['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        chown=('_koopa_sudo' "${app['chown']}")
    else
        chown=("${app['chown']}")
    fi
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        chown+=('-R')
    fi
    if [[ "${dict['dereference']}" -eq 0 ]]
    then
        chown+=('-h')
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${chown[@]}" "$@"
    return 0
}

_koopa_clone() {
    local -A dict
    local -a rsync_args
    _koopa_assert_has_args_eq "$#" 2
    _koopa_assert_has_no_flags "$@"
    dict['source_dir']="${1:?}"
    dict['target_dir']="${2:?}"
    _koopa_assert_is_dir "${dict['source_dir']}" "${dict['target_dir']}"
    dict['source_dir']="$( \
        _koopa_realpath "${dict['source_dir']}" \
        | _koopa_strip_trailing_slash \
    )"
    dict['target_dir']="$( \
        _koopa_realpath "${dict['target_dir']}" \
        | _koopa_strip_trailing_slash \
    )"
    _koopa_dl \
        'Source dir' "${dict['source_dir']}" \
        'Target dir' "${dict['target_dir']}"
    rsync_args=(
        '--archive'
        '--delete-before'
        "--source-dir=${dict['source_dir']}"
        "--target-dir=${dict['target_dir']}"
    )
    _koopa_rsync "${rsync_args[@]}"
    return 0
}

_koopa_cmake_std_args() {
    local -A dict
    local -a args
    _koopa_assert_has_args "$#"
    dict['bin_dir']=''
    dict['include_dir']=''
    dict['lib_dir']=''
    dict['prefix']=''
    dict['rpath']=''
    while (("$#"))
    do
        case "$1" in
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--rpath='*)
                dict['rpath']="${1#*=}"
                shift 1
                ;;
            '--rpath')
                dict['rpath']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--prefix' "${dict['prefix']}"
    [[ -z "${dict['bin_dir']}" ]] && \
        dict['bin_dir']="${dict['prefix']}/bin"
    [[ -z "${dict['include_dir']}" ]] && \
        dict['include_dir']="${dict['prefix']}/include"
    [[ -z "${dict['lib_dir']}" ]] && \
        dict['lib_dir']="${dict['prefix']}/lib"
    [[ -z "${dict['rpath']}" ]] && \
        dict['rpath']="${dict['prefix']}/lib"
    args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_BINDIR=${dict['bin_dir']}"
        "-DCMAKE_INSTALL_INCLUDEDIR=${dict['include_dir']}"
        "-DCMAKE_INSTALL_LIBDIR=${dict['lib_dir']}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['rpath']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
    )
    if _koopa_is_macos
    then
        dict['sdk_prefix']="$(_koopa_macos_sdk_prefix)"
        _koopa_assert_is_dir "${dict['sdk_prefix']}"
        dict['sdk_prefix']="$(_koopa_realpath "${dict['sdk_prefix']}")"
        args+=(
            '-DCMAKE_MACOSX_RPATH=ON'
            "-DCMAKE_OSX_SYSROOT=${dict['sdk_prefix']}"
        )
    fi
    _koopa_print "${args[@]}"
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

_koopa_compare_versions() {
    local -A app dict
    local -a sorted
    _koopa_assert_has_args_eq "$#" 3
    app['sort']="$(_koopa_locate_sort --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['left']="${1:?}"
    dict['operator']="${2:?}"
    dict['right']="${3:?}"
    if [[ "${dict['left']}" == "${dict['right']}" ]]
    then
        dict['comparison']=0
    else
        readarray -t sorted <<< "$( \
            _koopa_print "${dict['left']}" "${dict['right']}" \
            | "${app['sort']}" -V \
        )"
        if [[ "${sorted[0]}" == "${dict['left']}" ]]
        then
            dict['comparison']=-1
        else
            dict['comparison']=1
        fi
    fi
    dict['return']=1
    case "${dict['operator']}" in
        '-eq')
            if [[ "${dict['comparison']}" -eq 0 ]]
            then
                dict['return']=0
            fi
            ;;
        '-ge')
            if [[ "${dict['comparison']}" -gt -1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-gt')
            if [[ "${dict['comparison']}" -eq 1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-le')
            if [[ "${dict['comparison']}" -lt 1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-lt')
            if [[ "${dict['comparison']}" -eq -1 ]]
            then
                dict['return']=0
            fi
            ;;
        *)
            _koopa_stop "Invalid operator: '${dict['operator']}'."
            ;;
    esac
    return "${dict['return']}"
}

_koopa_compress_ext_pattern() {
    local -a formats
    local str
    _koopa_assert_has_no_args "$#"
    formats=('7z' 'br' 'bz2' 'gz' 'lz' 'lz4' 'lzma' 'xz' 'z' 'zip' 'zst')
    str="$(_koopa_paste --sep='|' "${formats[@]}")"
    str="\.(${str})\$"
    _koopa_print "$str"
    return 0
}

_koopa_compress() {
    local -A app bool dict
    local -a cmd_args pos
    local source_file
    _koopa_assert_has_args "$#"
    bool['keep']=1
    bool['verbose']=0
    dict['format']='gzip'
    dict['threads']="$(_koopa_cpu_count)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--format='*)
                dict['format']="${1#*=}"
                shift 1
                ;;
            '--format')
                dict['format']="${2:?}"
                shift 2
                ;;
            '--keep')
                bool['keep']=1
                shift 1
                ;;
            '--no-keep' | '--remove')
                bool['keep']=0
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
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
    _koopa_assert_is_set '--format' "${dict['format']}"
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    _koopa_assert_is_not_compressed_file "$@"
    case "${dict['format']}" in
        'br' | 'brotli')
            app['cmd']="$(_koopa_locate_brotli --allow-system)"
            dict['ext']='br'
            ;;
        'bz2' | 'bzip2')
            app['cmd']="$( \
                _koopa_locate_pbzip2 --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                dict['processes']="$(_koopa_cpu_count)"
                cmd_args+=("-p${dict['processes']}")
            else
                app['cmd']="$(_koopa_locate_bzip2 --allow-system)"
            fi
            dict['ext']='bz2'
            ;;
        'gz' | 'gzip')
            app['cmd']="$( \
                _koopa_locate_pigz --allow-system --allow-missing \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                dict['processes']="$(_koopa_cpu_count)"
                cmd_args+=('-p' "${dict['processes']}")
            else
                app['cmd']="$( \
                    _koopa_locate_gzip --allow-system --allow-missing \
                )"
            fi
            dict['ext']='gz'
            ;;
        'lz' | 'lzip')
            app['cmd']="$(_koopa_locate_lzip --allow-system)"
            dict['ext']='lz'
            ;;
        'lz4')
            app['cmd']="$(_koopa_locate_lz4 --allow-system)"
            dict['ext']='lz4'
            [[ "${bool['verbose']}" -eq 0 ]] && cmd_args+=('-q')
            ;;
        'lzma')
            app['cmd']="$(_koopa_locate_lzma --allow-system)"
            dict['ext']='lzma'
            ;;
        'xz')
            app['cmd']="$(_koopa_locate_xz --allow-system)"
            dict['ext']='xz'
            ;;
        'zst' | 'zstd')
            app['cmd']="$(_koopa_locate_zstd --allow-system)"
            dict['ext']='zst'
            [[ "${bool['verbose']}" -eq 0 ]] && cmd_args+=('-q')
            ;;
        *)
            _koopa_stop "Unsupported format: '${dict['format']}'."
            ;;
    esac
    _koopa_assert_is_executable "${app['cmd']}"
    cmd_args+=('-k')
    [[ "${bool['verbose']}" -eq 1 ]] && cmd_args+=('-v')
    for source_file in "$@"
    do
        local -A dict2
        dict2['source_file']="$source_file"
        dict2['source_file']="$(_koopa_realpath "${dict2['source_file']}")"
        dict2['target_file']="${dict2['source_file']}.${dict['ext']}"
        _koopa_assert_is_not_file "${dict2['target_file']}"
        _koopa_alert "Compressing '${dict2['source_file']}' \
to '${dict2['target_file']}'."
        "${app['cmd']}" "${cmd_args[@]}" "${dict2['source_file']}"
        _koopa_assert_is_file \
            "${dict2['source_file']}" \
            "${dict2['target_file']}"
        if [[ "${bool['keep']}" -eq 0 ]]
        then
            _koopa_rm "${dict2['target_file']}"
        fi
    done
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

_koopa_contains() {
    local string x
    _koopa_assert_has_args_ge "$#" 2
    string="${1:?}"
    shift 1
    for x
    do
        [[ "$x" == "$string" ]] && return 0
    done
    return 1
}

_koopa_convert_fastq_to_fasta() {
    local -A app dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['paste']="$(_koopa_locate_paste)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    app['tr']="$(_koopa_locate_tr)"
    _koopa_assert_is_executable "${app[@]}"
    dict['source_dir']=''
    dict['target_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    _koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(_koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        _koopa_stop "No FASTQ files detected in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app['paste']}" - - - - < "$fastq_file" \
            | "${app['cut']}" -f '1,2' \
            | "${app['sed']}" 's/^@/>/' \
            | "${app['tr']}" '\t' '\n' > "$fasta_file"
    done
    return 0
}

_koopa_convert_heic_to_jpeg() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['magick']="$(_koopa_locate_magick)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a heic_files
        readarray -t heic_files <<< "$( \
            _koopa_find \
                --pattern='*.heic' \
                --prefix="$prefix" \
                --sort \
                --type='f' \
        )"
        "${app['magick']}" mogrify \
            -format 'jpg' \
            -monitor \
            "${heic_files[@]}"
    done
    return 0
}

_koopa_convert_line_endings_from_crlf_to_lf() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        _koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

_koopa_convert_line_endings_from_lf_to_crlf() {
    local -A app
    local file
    _koopa_assert_has_ars "$#"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        _koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

_koopa_convert_utf8_nfd_to_nfc() {
    local -A app
    _koopa_assert_has_args "$#"
    app['convmv']="$(_koopa_locate_convmv)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    "${app['convmv']}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}

_koopa_cp() {
    local -A app dict
    local -a cp cp_args mkdir pos rm
    app['cp']="$(_koopa_locate_cp --allow-system --realpath)"
    dict['sudo']=0
    dict['symlink']=0
    dict['target_dir']=''
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict['symlink']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        cp=('_koopa_sudo' "${app['cp']}")
        mkdir=('_koopa_mkdir' '--sudo')
        rm=('_koopa_rm' '--sudo')
    else
        cp=("${app['cp']}")
        mkdir=('_koopa_mkdir')
        rm=('_koopa_rm')
    fi
    cp_args=(
        '-f'
        '-r'
    )
    [[ "${dict['symlink']}" -eq 1 ]] && cp_args+=('-s')
    [[ "${dict['verbose']}" -eq 1 ]] && cp_args+=('-v')
    cp_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        _koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            _koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        cp_args+=("${dict['target_dir']}")
    else
        _koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        _koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(_koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${cp[@]}" "${cp_args[@]}"
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

_koopa_datetime() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['date']="$(_koopa_locate_date --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_decompress_single_file() {
    local -A app bool dict
    local -a cmd_args pos
    _koopa_assert_has_args "$#"
    bool['keep']=1
    bool['overwrite']=1
    bool['passthrough']=0
    bool['stdout']=0
    bool['verbose']=0
    dict['compress_ext_pattern']="$(_koopa_compress_ext_pattern)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep')
                bool['keep']=1
                shift 1
                ;;
            '--no-keep' | '--remove')
                bool['keep']=0
                shift 1
                ;;
            '--stdout')
                bool['stdout']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
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
    _koopa_assert_has_args "$#"
    dict['input_file']="${1:?}"
    _koopa_assert_is_file "${dict['input_file']}"
    dict['input_file']="$(_koopa_realpath "${dict['input_file']}")"
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        _koopa_assert_has_args_eq "$#" 1
        dict['output_file']=''
    else
        _koopa_assert_has_args_le "$#" 2
        dict['output_file']="${2:-}"
        if [[ -z "${dict['output_file']}" ]]
        then
            dict['output_file']="$( \
                _koopa_sub \
                    --pattern="${dict['compress_ext_pattern']}" \
                    --regex \
                    --replacement='' \
                    "${dict['input_file']}" \
            )"
        fi
        if [[ "${dict['input_file']}" == "${dict['output_file']}" ]]
        then
            return 0
        fi
        if [[ "${bool['overwrite']}" -eq 0 ]]
        then
            _koopa_assert_is_not_file "${dict['output_file']}"
        fi
    fi
    dict['match']="$( \
        _koopa_basename "${dict['input_file']}" \
        | _koopa_lowercase \
    )"
    case "${dict['match']}" in
        *'.z')
            _koopa_stop "Use 'uncompress' directly on '.Z' files."
            ;;
        *'.7z' | \
        *'.a' | \
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz' | \
        *'.zip')
            _koopa_stop \
                "Unsupported archive file: '${dict['input_file']}'." \
                "Use '_koopa_extract' instead of '_koopa_decompress'."
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.zst')
            bool['passthrough']=0
            ;;
        *)
            bool['passthrough']=1
            ;;
    esac
    if [[ "${bool['passthrough']}" -eq 1 ]]
    then
        if [[ "${bool['stdout']}" -eq 1 ]]
        then
            app['cat']="$(_koopa_locate_cat --allow-system)"
            _koopa_assert_is_executable "${app['cat']}"
            "${app['cat']}" "${dict['input_file']}" || true
        else
            _koopa_alert "Passthrough mode. Copying '${dict['input_file']}' to \
'${dict['output_file']}'."
            _koopa_cp "${dict['input_file']}" "${dict['output_file']}"
        fi
        return 0
    fi
    case "${dict['match']}" in
        *'.br')
            app['cmd']="$(_koopa_locate_brotli --allow-system)"
            ;;
        *'.bz2')
            app['cmd']="$( \
                _koopa_locate_pbzip2 --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                cmd_args+=("-p$(_koopa_cpu_count)")
            else
                app['cmd']="$(_koopa_locate_bzip2 --allow-system)"
            fi
            ;;
        *'.gz')
            app['cmd']="$( \
                _koopa_locate_pigz --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                cmd_args+=('-p' "$(_koopa_cpu_count)")
            else
                app['cmd']="$(_koopa_locate_gzip --allow-system)"
            fi
            ;;
        *'.lz')
            app['cmd']="$(_koopa_locate_lzip --allow-system)"
            ;;
        *'.lz4')
            app['cmd']="$(_koopa_locate_lz4 --allow-system)"
            ;;
        *'.lzma')
            app['cmd']="$(_koopa_locate_lzma --allow-system)"
            ;;
        *'.xz')
            app['cmd']="$(_koopa_locate_xz --allow-system)"
            ;;
        *'.zst')
            app['cmd']="$(_koopa_locate_zstd --allow-system)"
            ;;
    esac
    _koopa_assert_is_executable "${app['cmd']}"
    cmd_args+=('-c' '-d' '-k')
    [[ "${bool['verbose']}" -eq 1 ]] && cmd_args+=('-v')
    cmd_args+=("${dict['input_file']}")
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        "${app['cmd']}" "${cmd_args[@]}" || true
    else
        _koopa_alert "Decompressing '${dict['input_file']}' to \
'${dict['output_file']}'."
        "${app['cmd']}" "${cmd_args[@]}" > "${dict['output_file']}"
        _koopa_assert_is_file "${dict['output_file']}"
    fi
    _koopa_assert_is_file "${dict['input_file']}"
    if [[ "${bool['keep']}" -eq 0 ]]
    then
        _koopa_rm "${dict['input_file']}"
    fi
    return 0
}

_koopa_decompress() {
    local -A bool dict
    local -a flags pos
    local input_file
    _koopa_assert_has_args "$#"
    bool['overwrite']=1
    bool['single_file']=0
    dict['input_file']=''
    dict['output_file']=''
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--input-file='*)
                bool['single_file']=1
                dict['input_file']="${1#*=}"
                shift 1
                ;;
            '--input-file')
                bool['single_file']=1
                dict['input_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                bool['single_file']=1
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                bool['single_file']=1
                dict['output_file']="${2:?}"
                shift 2
                ;;
            '--'*)
                flags+=("$1")
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
    if [[ "${bool['single_file']}" -eq 1 ]]
    then
        _koopa_assert_has_no_args "$#"
        _koopa_assert_is_set \
            '--input-file' "${dict['input_file']}" \
            '--output-file' "${dict['output_file']}"
        _koopa_assert_is_file "${dict['input_file']}"
        if [[ "${bool['overwrite']}" -eq 0 ]]
        then
            _koopa_assert_is_not_file "${dict['output_file']}"
        fi
        _koopa_decompress_single_file \
            "${flags[@]}" \
            "${dict['input_file']}" \
            "${dict['output_file']}"
    else
        _koopa_assert_has_args "$#"
        _koopa_assert_is_file "$@"
        for input_file in "$@"
        do
            _koopa_decompress_single_file "${flags[@]}" "$input_file"
        done
    fi
    return 0
}

_koopa_default_shell_name() {
    local str
    str="${SHELL:-sh}"
    str="$(basename "$str")"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_defunct() {
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    _koopa_stop "${msg}"
}

_koopa_detab() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['vim']="$(_koopa_locate_vim)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set expandtab tabstop=4 shiftwidth=4' \
            -c ':%retab' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

_koopa_df() {
    local -A app
    app['df']="$(_koopa_locate_df)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['df']}" \
        --portability \
        --print-type \
        --si \
        "$@"
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

_koopa_disk_512k_blocks() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" -P "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_disk_gb_free() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    _koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $4}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_disk_gb_total() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    _koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_disk_gb_used() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    _koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $3}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_disk_pct_free() {
    local disk pct_free pct_used
    _koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    _koopa_assert_is_readable "$disk"
    pct_used="$(_koopa_disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    _koopa_print "$pct_free"
    return 0
}

_koopa_disk_pct_used() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    _koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $5}' \
            | "${app['sed']}" 's/%$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
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

_koopa_dot_clean() {
    local -A app dict
    local -a basenames cruft files
    local i
    _koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    if _koopa_is_macos
    then
        app['dot_clean']="$(_koopa_macos_locate_dot_clean)"
        _koopa_assert_is_executable "${app['dot_clean']}"
        "${app['dot_clean']}" "${dict['prefix']}"
    fi
    readarray -t files <<< "$( \
        _koopa_find \
            --hidden \
            --pattern='.*' \
            --prefix="${dict['prefix']}" \
    )"
    if _koopa_is_array_empty "${files[@]}"
    then
        return 0
    fi
    cruft=()
    readarray -t basenames <<< "$(_koopa_basename "${files[@]}")"
    for i in "${!files[@]}"
    do
        local basename file
        file="${files[$i]}"
        [[ -e "$file" ]] || continue
        basename="${basenames[$i]}"
        case "$basename" in
            '.AppleDouble' | \
            '.DS_Store' | \
            '.Rhistory' | \
            '.lacie' | \
            '._'*)
                _koopa_rm --verbose "$file"
                ;;
            *)
                cruft+=("$file")
                ;;
        esac
    done
    if _koopa_is_array_non_empty "${cruft[@]:-}"
    then
        _koopa_alert_note "Dot files remaining in '${dict['prefix']}'."
        _koopa_print "${cruft[@]}"
        return 1
    fi
    return 0
}

_koopa_download_cran_latest() {
    local -A app
    local name
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local file pattern url
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            _koopa_parse_url "$url" \
            | _koopa_grep \
                --only-matching \
                --pattern="$pattern" \
                --regex \
            | "${app['head']}" -n 1 \
        )"
        _koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

_koopa_download_github_latest() {
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local api_url tag tarball_url
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            _koopa_parse_url "$api_url" \
            | _koopa_grep --pattern='tarball_url' \
            | "${app['cut']}" -d ':' -f '2,3' \
            | "${app['tr']}" --delete ' ,"' \
        )"
        tag="$(_koopa_basename "$tarball_url")"
        _koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

_koopa_download() {
    local -A app bool dict
    local -a curl_args
    _koopa_assert_has_args_le "$#" 2
    if _koopa_is_install_subshell
    then
        app['curl']="$(_koopa_locate_curl --only-system)"
    else
        app['curl']="$(_koopa_locate_curl --allow-system)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    bool['progress']=1
    bool['verbose']=0
    if _koopa_is_verbose
    then
        bool['verbose']=1
    fi
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) \
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 \
Edg/131.0.0.0"
    dict['url']="${1:?}"
    dict['file']="${2:-}"
    curl_args+=(
        '--create-dirs'
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
    )
    if [[ -n "${http_proxy:-}" ]]
    then
        curl_args+=('--insecure')
    fi
    if [[ "${bool['progress']}" -eq 0 ]]
    then
        curl_args+=('--silent')
    fi
    case "${dict['url']}" in
        *'sourceforge.net/'*)
            ;;
        *)
            curl_args+=('--user-agent' "${dict['user_agent']}")
            ;;
    esac
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        curl_args+=('--verbose')
    fi
    if [[ -z "${dict['file']}" ]]
    then
        dict['file']="$(_koopa_basename "${dict['url']}")"
        if _koopa_str_detect_fixed --string="${dict['file']}" --pattern='?'
        then
            dict['file']="$( \
                _koopa_sub \
                    --pattern='\?.+$' \
                    --regex \
                    --replacement='' \
                    "${dict['file']}" \
            )"
        fi
        if _koopa_str_detect_fixed --pattern='%' --string="${dict['file']}"
        then
            dict['file']="$( \
                _koopa_print "${dict['file']}" \
                | _koopa_gsub \
                    --fixed \
                    --pattern='%2D' \
                    --replacement='-' \
                | _koopa_gsub \
                    --fixed \
                    --pattern='%2E' \
                    --replacement='.' \
                | _koopa_gsub \
                    --fixed \
                    --pattern='%5F' \
                    --replacement='_' \
                | _koopa_gsub \
                    --fixed \
                    --pattern='%20' \
                    --replacement='_' \
            )"
        fi
    fi
    if [[ -n "${dict['file']}" ]]
    then
        if ! _koopa_str_detect_fixed --string="${dict['file']}" --pattern='/'
        then
            dict['file']="${PWD:?}/${dict['file']}"
        fi
        curl_args+=(
            '--output' "${dict['file']}"
        )
        _koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
    else
        dict['output_dir']="${PWD:?}"
        curl_args+=(
            '--output-dir' "${dict['output_dir']}"
            '--remote-header-name'
            '--remote-name'
        )
        _koopa_alert "Downloading '${dict['url']}' in '${dict['output_dir']}' \
using remote header name."
    fi
    curl_args+=("${dict['url']}")
    "${app['curl']}" "${curl_args[@]}"
    if [[ -n "${dict['file']}" ]]
    then
        _koopa_assert_is_file "${dict['file']}"
    fi
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

_koopa_edit_app_json() {
    local -A app dict
    app['editor']="${EDITOR:-vim}"
    _koopa_assert_is_installed "${app[@]}"
    dict['json_file']="$(_koopa_koopa_prefix)/etc/koopa/app.json"
    _koopa_assert_is_file "${dict['json_file']}"
    "${app['editor']}" "${dict['json_file']}"
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

_koopa_ensure_newline_at_end_of_file() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:?}"
    [[ -n "$("${app['tail']}" --bytes=1 "${dict['file']}")" ]] || return 0
    printf '\n' >> "${dict['file']}"
    return 0
}

_koopa_entab() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['vim']="$(_koopa_locate_vim)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

_koopa_eol_lf() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        _koopa_alert "Setting EOL as LF in '${file}'."
        "${app['perl']}" -pi -e 's/\r\n/\n/g' "$file"
        "${app['perl']}" -pi -e 's/\r/\n/g' "$file"
    done
}

_koopa_exec_dir() {
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local file
        _koopa_assert_is_dir "$prefix"
        for file in "${prefix}/"*'.sh'
        do
            [ -x "$file" ] || continue
            "$file"
        done
    done
    return 0
}

_koopa_expr() {
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_extract_all() {
    local file
    _koopa_assert_has_args_ge "$#" 2
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        _koopa_assert_is_matching_regex \
            --pattern='\.tar\.(bz2|gz|xz)$' \
            --string="$file"
        _koopa_extract "$file"
    done
    return 0
}

_koopa_extract_version() {
    local -A app dict
    local -a args
    local arg
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="$(_koopa_version_pattern)"
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for arg in "${args[@]}"
    do
        local str
        str="$( \
            _koopa_grep \
                --only-matching \
                --pattern="${dict['pattern']}" \
                --regex \
                --string="$arg" \
            | "${app['head']}" -n 1 \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_extract() {
    local -A app bool dict
    local -a cmd_args contents
    _koopa_assert_has_args_le "$#" 2
    bool['decompress_only']=0
    bool['gnu_tar']=0
    dict['file']="${1:?}"
    dict['target_dir']="${2:-}"
    _koopa_assert_is_file "${dict['file']}"
    dict['bn']="$(_koopa_basename_sans_ext "${dict['file']}")"
    case "${dict['bn']}" in
        *'.tar')
            dict['bn']="$(_koopa_basename_sans_ext "${dict['bn']}")"
            ;;
    esac
    dict['file']="$(_koopa_realpath "${dict['file']}")"
    dict['match']="$( \
        _koopa_basename "${dict['file']}" \
        | _koopa_lowercase \
    )"
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz')
            bool['decompress_only']=0
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.z' | \
        *'.zst')
            bool['decompress_only']=1
            ;;
    esac
    if [[ -z "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(_koopa_parent_dir "${dict['file']}")/${dict['bn']}"
    fi
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    if [[ "${bool['decompress_only']}" -eq 1 ]]
    then
        dict['output_file']="${dict['target_dir']}/${dict['bn']}"
        _koopa_decompress \
            --input-file="${dict['file']}" \
            --output-file="${dict['output_file']}"
        return 0
    fi
    _koopa_alert "Extracting '${dict['file']}' to '${dict['target_dir']}'."
    dict['tmpdir']="$(_koopa_parent_dir "${dict['file']}")/$(_koopa_tmp_string)"
    dict['tmpdir']="$(_koopa_init_dir "${dict['tmpdir']}")"
    dict['tmpfile']="${dict['tmpdir']}/$(_koopa_basename "${dict['file']}")"
    _koopa_ln "${dict['file']}" "${dict['tmpfile']}"
    case "${dict['match']}" in
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz')
            local -a tar_cmd_args
            app['tar']="$(_koopa_locate_tar --allow-system --realpath)"
            _koopa_assert_is_executable "${app['tar']}"
            if _koopa_is_gnu "${app['tar']}"
            then
                bool['gnu_tar']=1
            else
                bool['gnu_tar']=0
            fi
            if _koopa_is_root && [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                tar_cmd_args+=('--no-same-owner' '--no-same-permissions')
            fi
            tar_cmd_args+=(
                '-f' "${dict['tmpfile']}"
                '-x'
            )
            ;;
    esac
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz' | \
        *'.tbz2' | \
        *'.tgz')
            app['cmd']="${app['tar']}"
            app['cmd2']=''
            cmd_args+=("${tar_cmd_args[@]}")
            if [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$( \
                            _koopa_locate_pbzip2 --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(_koopa_locate_bzip2 --allow-system)"
                        fi
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$( \
                            _koopa_locate_pigz --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(_koopa_locate_gzip --allow-system)"
                        fi
                        ;;
                    *'.lz')
                        app['cmd2']="$(_koopa_locate_lzip --allow-system)"
                        ;;
                    *'.xz')
                        app['cmd2']="$(_koopa_locate_xz --allow-system)"
                        ;;
                esac
                cmd_args+=('--use-compress-program' "${app['cmd2']}")
            else
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$(_koopa_locate_bzip2 --allow-system)"
                        cmd_args+=('-j')
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$(_koopa_locate_gzip --allow-system)"
                        cmd_args+=('-z')
                        ;;
                    *'.xz')
                        app['cmd2']="$(_koopa_locate_xz --allow-system)"
                        cmd_args+=('-J')
                        ;;
                    *)
                        _koopa_stop "Unsupported file: '${dict['tmpfile']}'."
                        ;;
                esac
            fi
            _koopa_assert_is_executable "${app['cmd2']}"
            ;;
        *'.tar')
            app['cmd']="${app['tar']}"
            cmd_args+=("${tar_cmd_args[@]}")
            ;;
        *'.7z')
            app['cmd']="$(_koopa_locate_7z --allow-system)"
            cmd_args+=('-x' "${dict['tmpfile']}")
            ;;
        *'.zip')
            app['cmd']="$(_koopa_locate_unzip --allow-system)"
            cmd_args+=('-qq' "${dict['tmpfile']}")
            ;;
        *)
            _koopa_stop "Unsupported file: '${dict['file']}'."
            ;;
    esac
    _koopa_assert_is_executable "${app['cmd']}"
    (
        _koopa_cd "${dict['tmpdir']}"
        if [[ "${bool['gnu_tar']}" -eq 0 ]] && [[ -x "${app['cmd2']:-}" ]]
        then
            _koopa_add_to_path_start "$(_koopa_dirname "${app['cmd2']}")"
        fi
        "${app['cmd']}" "${cmd_args[@]}" # 2>/dev/null
    )
    _koopa_rm "${dict['tmpfile']}"
    readarray -t contents <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['tmpdir']}" \
    )"
    if _koopa_is_array_empty "${contents[@]}"
    then
        _koopa_stop "Empty archive file: '${dict['file']}'."
    fi
    (
        shopt -s dotglob
        if [[ "${#contents[@]}" -eq 1 ]] && [[ -d "${contents[0]}" ]]
        then
            _koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*/*
        else
            _koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*
        fi
    )
    _koopa_rm "${dict['tmpdir']}"
    return 0
}

_koopa_file_count() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['wc']="$(_koopa_locate_wc --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    dict['out']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict['prefix']}" \
        | "${app['wc']}" -l \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_file_detect_fixed() {
    _koopa_file_detect --mode='fixed' "$@"
}

_koopa_file_detect_regex() {
    _koopa_file_detect --mode='regex' "$@"
}

_koopa_file_detect() {
    local -A dict
    local -a grep_args
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['mode']=''
    dict['pattern']=''
    dict['stdin']=1
    dict['sudo']=0
    while (("$#"))
    do
        case "$1" in
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
        dict['file']="$(</dev/stdin)"
    fi
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--mode' "${dict['mode']}" \
        '--pattern' "${dict['pattern']}"
    grep_args=(
        '--boolean'
        '--file' "${dict['file']}"
        '--mode' "${dict['mode']}"
        '--pattern' "${dict['pattern']}"
    )
    [[ "${dict['sudo']}" -eq 1 ]] && grep_args+=('--sudo')
    _koopa_grep "${grep_args[@]}"
}

_koopa_file_ext_2() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        if _koopa_has_file_ext "$file"
        then
            str="$( \
                _koopa_print "$file" \
                | "${app['cut']}" -d '.' -f '2-' \
            )"
        else
            str=''
        fi
        _koopa_print "$str"
    done
    return 0
}

_koopa_file_ext() {
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        local x
        if _koopa_has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        _koopa_print "$x"
    done
    return 0
}

_koopa_find() {
    local -A app bool dict
    local -a exclude_arr find find_args results sorted_results
    local exclude_arg
    bool['empty']=0
    bool['exclude']=0
    bool['hidden']=0
    bool['print0']=0
    bool['sort']=0
    bool['sudo']=0
    bool['verbose']=0
    dict['days_modified_gt']=''
    dict['days_modified_lt']=''
    dict['engine']="${KOOPA_FIND_ENGINE:-}"
    dict['max_depth']=''
    dict['min_depth']=1
    dict['pattern']=''
    dict['size']=''
    dict['type']=''
    exclude_arr=()
    while (("$#"))
    do
        case "$1" in
            '--days-modified-before='*)
                dict['days_modified_gt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-before')
                dict['days_modified_gt']="${2:?}"
                shift 2
                ;;
            '--days-modified-within='*)
                dict['days_modified_lt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-within')
                dict['days_modified_lt']="${2:?}"
                shift 2
                ;;
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--exclude='*)
                bool['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                bool['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--max-depth='*)
                dict['max_depth']="${1#*=}"
                shift 1
                ;;
            '--max-depth')
                dict['max_depth']="${2:?}"
                shift 2
                ;;
            '--min-depth='*)
                dict['min_depth']="${1#*=}"
                shift 1
                ;;
            '--min-depth')
                dict['min_depth']="${2:?}"
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
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--size='*)
                dict['size']="${1#*=}"
                shift 1
                ;;
            '--size')
                dict['size']="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict['type']="${1#*=}"
                shift 1
                ;;
            '--type')
                dict['type']="${2:?}"
                shift 2
                ;;
            '--empty')
                bool['empty']=1
                shift 1
                ;;
            '--hidden')
                bool['hidden']=1
                shift 1
                ;;
            '--no-hidden')
                bool['hidden']=0
                shift 1
                ;;
            '--print0')
                bool['print0']=1
                shift 1
                ;;
            '--sort')
                bool['sort']=1
                shift 1
                ;;
            '--sudo')
                bool['sudo']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--prefix' "${dict['prefix']}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    case "${dict['engine']}" in
        '')
            app['find']="$(_koopa_locate_fd --allow-missing)"
            [[ -x "${app['find']}" ]] && dict['engine']='fd'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='find'
                app['find']="$(_koopa_locate_find --allow-system)"
            fi
            ;;
        'fd')
            app['find']="$(_koopa_locate_fd)"
            ;;
        'find')
            app['find']="$(_koopa_locate_find --allow-system)"
            ;;
        *)
            _koopa_stop 'Invalid find engine.'
            ;;
    esac
    find=()
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        find+=('_koopa_sudo')
    fi
    find+=("${app['find']}")
    case "${dict['engine']}" in
        'fd')
            find_args=(
                '--absolute-path'
                '--base-directory' "${dict['prefix']}"
                '--case-sensitive'
                '--glob'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ "${bool['hidden']}" -eq 1 ]]
            then
                find_args+=('--hidden')
            else
                find_args+=('--no-hidden')
            fi
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('--min-depth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('--max-depth' "${dict['max_depth']}")
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'd')
                        dict['type']='directory'
                        ;;
                    'f')
                        dict['type']='file'
                        ;;
                    'l')
                        dict['type']='symlink'
                        ;;
                    *)
                        _koopa_stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict['type']}")
            fi
            if [[ "${bool['empty']}" -eq 1 ]]
            then
                find_args+=('--type' 'empty')
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=(
                    '--changed-before'
                    "${dict['days_modified_gt']}d"
                )
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=(
                    '--changed-within'
                    "${dict['days_modified_lt']}d"
                )
            fi
            if [[ "${bool['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict['size']}" ]]
            then
                dict['size']="$( \
                    _koopa_sub \
                        --pattern='c$' \
                        --replacement='b' \
                        "${dict['size']}" \
                )"
                find_args+=('--size' "${dict['size']}")
            fi
            if [[ "${bool['print0']}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                find_args+=("${dict['pattern']}")
            fi
            ;;
        'find')
            find_args=("${dict['prefix']}" '-xdev')
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('-mindepth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('-maxdepth' "${dict['max_depth']}")
            fi
            if [[ "${bool['hidden']}" -eq 0 ]]
            then
                find_args+=('-not' '-name' '.*')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                if _koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict['pattern']}"
                then
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local -a globs1 globs2 globs3
                        local str
                        readarray -d ',' -t globs1 <<< "$( \
                            _koopa_gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict['pattern']}" \
                        )"
                        globs2=()
                        for i in "${!globs1[@]}"
                        do
                            globs2+=(
                                "-name ${globs1[$i]}"
                            )
                        done
                        str="( $(_koopa_paste --sep=' -o ' "${globs2[@]}") )"
                        readarray -d ' ' -t globs3 <<< "$(
                            _koopa_print "$str"
                        )"
                        _koopa_print "${globs3[@]}"
                    )"
                else
                    find_args+=('-name' "${dict['pattern']}")
                fi
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f' | \
                    'l')
                        find_args+=('-type' "${dict['type']}")
                        ;;
                    *)
                        _koopa_stop 'Invalid file type argument.'
                        ;;
                esac
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=('-mtime' "+${dict['days_modified_gt']}")
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=('-mtime' "-${dict['days_modified_lt']}")
            fi
            if [[ "${bool['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        _koopa_sub \
                            --pattern='^' \
                            --replacement="${dict['prefix']}/" \
                            "$exclude_arg" \
                    )"
                    find_args+=('-not' '-path' "$exclude_arg")
                done
            fi
            if [[ "${bool['empty']}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict['size']}" ]]
            then
                find_args+=('-size' "${dict['size']}")
            fi
            if [[ "${bool['print0']}" -eq 1 ]]
            then
                find_args+=('-print0')
            else
                find_args+=('-print')
            fi
            ;;
        *)
            _koopa_stop 'Invalid find engine.'
            ;;
    esac
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        >&2 _koopa_dl 'Find' "${find[*]} ${find_args[*]}"
    fi
    if [[ "${bool['sort']}" -eq 1 ]]
    then
        app['sort']="$(_koopa_locate_sort --allow-system)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    if [[ "${bool['print0']}" -eq 1 ]]
    then
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        _koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${bool['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                _koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        if [[ "${dict['engine']}" = 'fd' ]]
        then
            readarray -t results <<< "$( \
                _koopa_strip_trailing_slash "${results[@]}" \
            )"
        fi
        printf '%s\0' "${results[@]}"
    else
        readarray -t results <<< "$( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )"
        _koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${bool['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                _koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        if [[ "${dict['engine']}" = 'fd' ]]
        then
            readarray -t results <<< "$( \
                _koopa_strip_trailing_slash "${results[@]}" \
            )"
        fi
        _koopa_print "${results[@]}"
    fi
    return 0
}

_koopa_ftp_mirror() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['wget']="$(_koopa_locate_wget)"
    _koopa_assert_is_executable "${app[@]}"
    dict['dir']=''
    dict['host']=''
    dict['user']=''
    while (("$#"))
    do
        case "$1" in
            '--dir='*)
                dict['dir']="${1#*=}"
                shift 1
                ;;
            '--dir')
                dict['dir']="${2:?}"
                shift 2
                ;;
            '--host='*)
                dict['host']="${1#*=}"
                shift 1
                ;;
            '--host')
                dict['host']="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict['user']="${1#*=}"
                shift 1
                ;;
            '--user')
                dict['user']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--host' "${dict['host']}" \
        '--user' "${dict['user']}"
    if [[ -n "${dict['dir']}" ]]
    then
        dict['dir']="${dict['host']}/${dict['dir']}"
    else
        dict['dir']="${dict['host']}"
    fi
    "${app['wget']}" \
        --ask-password \
        --mirror \
        "ftp://${dict['user']}@${dict['dir']}/"*
    return 0
}

_koopa_gcrypt_url() {
    _koopa_assert_has_no_args "$#"
    _koopa_print 'https://gnupg.org/ftp/gcrypt'
    return 0
}

_koopa_get_version_arg() {
    local arg name
    _koopa_assert_has_args_eq "$#" 1
    name="$(_koopa_basename "${1:?}")"
    case "$name" in
        'apptainer' | \
        'docker-credential-pass' | \
        'go' | \
        'openssl' | \
        'rstudio-server')
            arg='version'
            ;;
        'exiftool')
            arg='-ver'
            ;;
        'lua')
            arg='-v'
            ;;
        'openssh' | \
        'ssh' | \
        'tmux')
            arg='-V'
            ;;
        *)
            arg='--version'
            ;;
    esac
    _koopa_print "$arg"
    return 0
}

_koopa_get_version() {
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local -A dict
        dict['cmd']="$cmd"
        dict['bn']="$(_koopa_basename "${dict['cmd']}")"
        dict['bn_snake']="$(_koopa_snake_case "${dict['bn']}")"
        dict['version_arg']="$(_koopa_get_version_arg "${dict['bn']}")"
        dict['version_fun']="_koopa_${dict['bn_snake']}_version"
        if _koopa_is_function "${dict['version_fun']}"
        then
            if [[ -x "${dict['cmd']}" ]] && \
                [[ ! -d "${dict['cmd']}" ]] && \
                _koopa_is_installed "${dict['cmd']}"
            then
                dict['str']="$("${dict['version_fun']}" "${dict['cmd']}")"
            else
                dict['str']="$("${dict['version_fun']}")"
            fi
            [[ -n "${dict['str']}" ]] || return 1
            _koopa_print "${dict['str']}"
            continue
        fi
        [[ -x "${dict['cmd']}" ]] || return 1
        [[ ! -d "${dict['cmd']}" ]] || return 1
        _koopa_is_installed "${dict['cmd']}" || return 1
        dict['cmd']="$(_koopa_realpath "${dict['cmd']}")"
        dict['str']="$("${dict['cmd']}" "${dict['version_arg']}" 2>&1 || true)"
        [[ -n "${dict['str']}" ]] || return 1
        dict['str']="$(_koopa_extract_version "${dict['str']}")"
        [[ -n "${dict['str']}" ]] || return 1
        _koopa_print "${dict['str']}"
    done
    return 0
}

_koopa_getent() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if [[ "${1:?}" == 'hosts' ]]
    then
        dict['str']="$( \
            "${app['sed']}" 's/#.*//' "/etc/${1:?}" \
            | "${app['grep']}" -w "${2:?}" \
        )"
    elif [[ "${2:?}" == '<->' ]]
    then
        dict['str']="$( \
            "${app['grep']}" ":${2:?}:[^:]*$" "/etc/${1:?}" \
        )"
    else
        dict['str']="$( \
            "${app['grep']}" "^${2:?}:" "/etc/${1:?}" \
        )"
    fi
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_gnu_mirror_url() {
    local server
    _koopa_assert_has_no_args "$#"
    server='https://gnu.mirror.constant.com'
    _koopa_print "$server"
    return 0
}

_koopa_gpg_download_key_from_keyserver() {
    local -A app dict
    local -a cp gpg_args
    _koopa_assert_has_args "$#"
    app['gpg']="$(_koopa_locate_gpg --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    dict['tmp_file']="${dict['tmp_dir']}/export.gpg"
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict['key']="${1#*=}"
                shift 1
                ;;
            '--key')
                dict['key']="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict['keyserver']="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict['keyserver']="${2:?}"
                shift 2
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict['file']}" ]] && return 0
    _koopa_alert "Exporting GPG key '${dict['key']}' at '${dict['file']}'."
    cp=('_koopa_cp')
    [[ "${dict['sudo']}" -eq 1 ]] && cp+=('--sudo')
    gpg_args=(
        --homedir "${dict['tmp_dir']}"
        --keyserver "hkp://${dict['keyserver']}:80"
    )
    if [[ -n "${http_proxy:-}" ]]
    then
        gpg_args+=(
            --keyserver-options "http-proxy=${http_proxy:-}"
        )
    fi
    gpg_args+=(
        --recv-keys "${dict['key']}"
    )
    "${app['gpg']}" "${gpg_args[@]}"
    gpg_args=(
        --homedir "${dict['tmp_dir']}"
        --list-public-keys "${dict['key']}"
    )
    "${app['gpg']}" "${gpg_args[@]}"
    gpg_args=(
        --export
        --homedir "${dict['tmp_dir']}"
        --output "${dict['tmp_file']}"
        "${dict['key']}"
    )
    "${app['gpg']}" "${gpg_args[@]}"
    if [[ ! -f "${dict['tmp_file']}" ]]
    then
        _koopa_warn "Failed to export '${dict['key']}' to '${dict['file']}'."
        return 1
    fi
    "${cp[@]}" "${dict['tmp_file']}" "${dict['file']}"
    _koopa_rm "${dict['tmp_dir']}"
    _koopa_assert_is_file "${dict['file']}"
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
            app['grep']="$(_koopa_locate_ripgrep)"
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

_koopa_group_id() {
    local str
    str="$(id -g)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_group_name() {
    local str
    str="$(id -gn)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_gsub() {
    _koopa_sub --global "$@"
}

_koopa_h() {
    local -A dict
    _koopa_assert_has_args_ge "$#" 2
    dict['emoji']="$(_koopa_acid_emoji)"
    dict['level']="${1:?}"
    shift 1
    case "${dict['level']}" in
        '1')
            _koopa_print ''
            dict['prefix']='#'
            ;;
        '2')
            dict['prefix']='##'
            ;;
        '3')
            dict['prefix']='###'
            ;;
        '4')
            dict['prefix']='####'
            ;;
        '5')
            dict['prefix']='#####'
            ;;
        '6')
            dict['prefix']='######'
            ;;
        '7')
            dict['prefix']='#######'
            ;;
        *)
            _koopa_stop 'Invalid header level.'
            ;;
    esac
    _koopa_msg 'magenta' 'default' "${dict['emoji']} ${dict['prefix']}" "$@"
    return 0
}

_koopa_h1() {
    _koopa_h 1 "$@"
}

_koopa_h2() {
    _koopa_h 2 "$@"
}

_koopa_h3() {
    _koopa_h 3 "$@"
}

_koopa_h4() {
    _koopa_h 4 "$@"
}

_koopa_h5() {
    _koopa_h 5 "$@"
}

_koopa_h6() {
    _koopa_h 6 "$@"
}

_koopa_h7() {
    _koopa_h 7 "$@"
}

_koopa_has_file_ext() {
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        _koopa_str_detect_fixed \
            --string="$(_koopa_print "$file")" \
            --pattern='.' \
        || return 1
    done
    return 0
}

_koopa_has_firewall() {
    local -A dict
    dict['ssl_cert_file']="${SSL_CERT_FILE:-}"
    if [[ -z "${dict['ssl_cert_file']}" ]]
    then
        return 1
    fi
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    if [[ "${dict['ssl_cert_file']}" == "${dict['koopa_prefix']}/"* ]]
    then
        return 1
    fi
    return 0
}

_koopa_has_large_system_disk() {
    local -A dict
    _koopa_assert_has_args_le "$#" 1
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] && return 0
    dict['disk']="${1:-/}"
    dict['blocks']="$(_koopa_disk_512k_blocks "${dict['disk']}")"
    [[ "${dict['blocks']}" -ge 500000000 ]] && return 0
    return 1
}

_koopa_has_monorepo() {
    [[ -d "$(_koopa_monorepo_prefix)" ]]
}

_koopa_has_no_active_envs() {
    _koopa_assert_has_no_args "$#"
    _koopa_is_conda_env_active && return 1
    _koopa_is_lmod_active && return 1
    _koopa_is_python_venv_active && return 1
    return 0
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

_koopa_has_private_access() {
    local file
    file="${HOME}/.aws/credentials"
    [[ -f "$file" ]] || return 1
    _koopa_file_detect_regex \
        --file="$file" \
        --pattern='^\[acidgenomics\]$'
}

_koopa_has_standard_umask() {
    local -A dict
    dict['default_umask']="$(umask)"
    case "${dict['default_umask']}" in
        '0002' | '002' | \
        '0022' | '022')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_koopa_header() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['lang']="$(_koopa_lowercase "${1:?}")"
    case "${dict['lang']}" in
        'posix')
            dict['lang']='sh'
            ;;
    esac
    dict['prefix']="$(_koopa_koopa_prefix)/lang/${dict['lang']}"
    case "${dict['lang']}" in
        'bash' | \
        'sh' | \
        'zsh')
            dict['ext']='sh'
            ;;
        *)
            _koopa_invalid_arg "${dict['lang']}"
            ;;
    esac
    dict['file']="${dict['prefix']}/include/header.${dict['ext']}"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_print "${dict['file']}"
    return 0
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

_koopa_hostname() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['uname']="$(_koopa_locate_uname --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['uname']}" -n)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_ignore_pipefail() {
    local status
    status="${1:?}"
    [[ "$status" -eq 141 ]] && return 0
    return "$status"
}

_koopa_info_box() {
    local -a array
    local barpad i
    _koopa_assert_has_args "$#"
    array=("$@")
    barpad="$(printf '━%.0s' {1..70})"
    printf '  %s%s%s  \n' '┏' "$barpad" '┓'
    for i in "${array[@]}"
    do
        printf '  ┃ %-68s ┃  \n' "${i::68}"
    done
    printf '  %s%s%s  \n\n' '┗' "$barpad" '┛'
    return 0
}

_koopa_init_dir() {
    local -A dict
    local -a mkdir pos
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    _koopa_assert_has_args_eq "$#" 1
    dict['dir']="${1:?}"
    if _koopa_str_detect_regex \
        --string="${dict['dir']}" \
        --pattern='^~'
    then
        dict['dir']="$( \
            _koopa_sub \
                --pattern='^~' \
                --replacement="${HOME:?}" \
                "${dict['dir']}" \
        )"
    fi
    mkdir=('_koopa_mkdir')
    [[ "${dict['sudo']}" -eq 1 ]] && mkdir+=('--sudo')
    if [[ ! -d "${dict['dir']}" ]]
    then
        "${mkdir[@]}" "${dict['dir']}"
    fi
    dict['realdir']="$(_koopa_realpath "${dict['dir']}")"
    _koopa_print "${dict['realdir']}"
    return 0
}

_koopa_insert_at_line_number() {
    local -A app dict
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['line_number']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--line-number='*)
                dict['line_number']="${1#*=}"
                shift 1
                ;;
            '--line-number')
                dict['line_number']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--line-number' "${dict['line_number']}" \
        '--string' "${dict['string']}"
    _koopa_assert_is_file "${dict['file']}"
    dict['perl_cmd']="print '${dict['string']}' \
if \$. == ${dict['line_number']}"
    "${app['perl']}" -i -l -p -e "${dict['perl_cmd']}" "${dict['file']}"
    return 0
}

_koopa_int_to_yn() {
    local str
    _koopa_assert_has_args_eq "$#" 1
    case "${1:?}" in
        '0')
            str='no'
            ;;
        '1')
            str='yes'
            ;;
        *)
            _koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    _koopa_print "$str"
    return 0
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

_koopa_ip_address() {
    local -A dict
    dict['type']='public'
    while (("$#"))
    do
        case "$1" in
            '--local')
                dict['type']='local'
                shift 1
                ;;
            '--public')
                dict['type']='public'
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict['type']}" in
        'local')
            _koopa_local_ip_address
            ;;
        'public')
            _koopa_public_ip_address
            ;;
    esac
    return 0
}

_koopa_ip_info() {
    local -A app dict
    app['curl']="$(_koopa_locate_curl --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['server']='ipinfo.io'
    dict['json']="$( \
        "${app['curl']}" \
            --disable \
            --silent \
            "${dict['server']}" \
    )"
    [[ -n "${dict['json']}" ]] || return 1
    _koopa_print "${dict['json']}"
    return 0
}

_koopa_jekyll_serve() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['bundle']="$(_koopa_locate_bundle)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bundle_prefix']="$(_koopa_xdg_data_home)/gem"
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    _koopa_alert "Serving Jekyll website in '${dict['prefix']}'."
    (
        _koopa_cd "${dict['prefix']}"
        _koopa_assert_is_file 'Gemfile'
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && _koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll serve
        _koopa_rm 'Gemfile.lock'
    )
    return 0
}

_koopa_kebab_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        _koopa_gsub \
            --pattern='[^-A-Za-z0-9]' \
            --regex \
            --replacement='-' \
            "$@" \
        | _koopa_lowercase \
    )"
    _koopa_is_array_non_empty "${out[@]:-}" || return 1
    _koopa_print "${out[@]}"
    return 0
}

_koopa_local_ip_address() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['tail']="$(_koopa_locate_tail --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_macos
    then
        app['ifconfig']="$(_koopa_macos_locate_ifconfig)"
        _koopa_assert_is_executable "${app['ifconfig']}"
        str="$( \
            "${app['ifconfig']}" \
            | _koopa_grep --pattern='inet ' \
            | _koopa_grep --pattern='broadcast' \
            | "${app['awk']}" '{print $2}' \
            | "${app['tail']}" -n 1 \
        )"
    else
        app['hostname']="$(_koopa_locate_hostname)"
        _koopa_assert_is_executable "${app['hostname']}"
        str="$( \
            "${app['hostname']}" -I \
            | "${app['awk']}" '{print $1}' \
            | "${app['head']}" -n 1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_koopa_url() {
    _koopa_assert_has_no_args "$#"
    _koopa_print 'https://koopa.acidgenomics.com'
    return 0
}

_koopa_koopa_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    _koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_line_count() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['wc']="$(_koopa_locate_wc)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$( \
            "${app['wc']}" --lines "$file" \
                | "${app['xargs']}" \
                | "${app['cut']}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_link_in_bin() {
    _koopa_link_in_dir --prefix="$(_koopa_bin_prefix)" "$@"
}

_koopa_link_in_dir() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['name']=''
    dict['prefix']=''
    dict['source']=''
    while (("$#"))
    do
        case "$1" in
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--source='*)
                dict['source']="${1#*=}"
                shift 1
                ;;
            '--source')
                dict['source']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--source' "${dict['source']}"
    [[ ! -d "${dict['prefix']}" ]] && _koopa_mkdir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    dict['target']="${dict['prefix']}/${dict['name']}"
    _koopa_assert_is_existing "${dict['source']}"
    _koopa_ln "${dict['source']}" "${dict['target']}"
    return 0
}

_koopa_link_in_man1() {
    _koopa_link_in_dir --prefix="$(_koopa_man_prefix)/man1" "$@"
}

_koopa_link_in_opt() {
    _koopa_link_in_dir --prefix="$(_koopa_opt_prefix)" "$@"
}

_koopa_list_app_versions() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_app_prefix)"
    if [[ ! -d "${dict['prefix']}" ]]
    then
        _koopa_alert_note "No apps are installed in '${dict['prefix']}'."
        return 0
    fi
    dict['str']="$( \
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_list_path_priority_unique() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['awk']="$(_koopa_locate_awk)"
    app['tac']="$(_koopa_locate_tac)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    dict['string']="$( \
        _koopa_print "${dict['string']//:/$'\n'}" \
        | "${app['tac']}" \
        | "${app['awk']}" '!a[$0]++' \
        | "${app['tac']}" \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_list_path_priority() {
    local -A app dict
    local -a all_arr unique_arr
    _koopa_assert_has_args_le "$#" 1
    app['awk']="$(_koopa_locate_awk)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    readarray -t all_arr <<< "$( \
        _koopa_print "${dict['string']//:/$'\n'}" \
    )"
    _koopa_is_array_non_empty "${all_arr[@]:-}" || return 1
    readarray -t unique_arr <<< "$( \
        _koopa_print "${all_arr[@]}" \
            | "${app['awk']}" '!a[$0]++' \
    )"
    _koopa_is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict['n_all']="${#all_arr[@]}"
    dict['n_unique']="${#unique_arr[@]}"
    dict['n_dupes']="$((dict['n_all'] - dict['n_unique']))"
    if [[ "${dict['n_dupes']}" -gt 0 ]]
    then
        _koopa_alert_note "$(_koopa_ngettext \
            --num="${dict['n_dupes']}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    _koopa_print "${all_arr[@]}"
    return 0
}

_koopa_ln() {
    local -A app dict
    local -a ln ln_args mkdir pos rm
    app['ln']="$(_koopa_locate_ln --allow-system --realpath)"
    dict['sudo']=0
    dict['target_dir']=''
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        ln=('_koopa_sudo' "${app['ln']}")
        mkdir=('_koopa_mkdir' '--sudo')
        rm=('_koopa_rm' '--sudo')
    else
        ln=("${app['ln']}")
        mkdir=('_koopa_mkdir')
        rm=('_koopa_rm')
    fi
    ln_args=('-f' '-n' '-s')
    [[ "${dict['verbose']}" -eq 1 ]] && ln_args+=('-v')
    ln_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        _koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            _koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        ln_args+=("${dict['target_dir']}")
    else
        _koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        _koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(_koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${ln[@]}" "${ln_args[@]}"
    return 0
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

_koopa_log_file() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['datetime']="$(_koopa_datetime)"
    dict['hostname']="$(_koopa_hostname)"
    dict['log_file']="${HOME:?}/logs/${dict['hostname']}/\
${dict['datetime']}.log"
    _koopa_touch "${dict['log_file']}"
    _koopa_print "${dict['log_file']}"
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

_koopa_lowercase() {
    local -A app
    local str
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        _koopa_print "$str" \
            | "${app['tr']}" '[:upper:]' '[:lower:]'
    done
    return 0
}

_koopa_major_minor_patch_version() {
    local str
    for str in "$@"
    do
        str="$( \
            _koopa_print "$str" \
            | cut -d '.' -f '1-3' \
        )"
        [[ -n "$str" ]] || return 1
        str="$( \
            _koopa_print "$str" \
            | cut -d '-' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        str="$( \
            _koopa_print "$str" \
            | cut -d 'p' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_major_minor_version() {
    local str
    for str in "$@"
    do
        str="$( \
            _koopa_print "$str" \
            | cut -d '.' -f '1-2' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_major_version() {
    local str
    for str in "$@"
    do
        str="$( \
            _koopa_print "$str" \
            | cut -d '.' -f '1' \
            | cut -d '-' -f '1' \
            | cut -d '+' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_make_build_string() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['arch']="$(_koopa_arch)"
    if _koopa_is_linux
    then
        dict['os_type']='linux-gnu'
    else
        dict['os_type']="$(_koopa_os_type)"
    fi
    _koopa_print "${dict['arch']}-${dict['os_type']}"
    return 0
}

_koopa_md5sum_check_parallel() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['md5sum']="$(_koopa_locate_md5sum)"
    app['sh']="$(_koopa_locate_sh)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    _koopa_find \
        --max-depth=1 \
        --min-depth=1 \
        --pattern='*.md5' \
        --prefix='.' \
        --print0 \
        --sort \
        --type='f' \
    | "${app['xargs']}" \
        -0 \
        -I {} \
        -P "${dict['jobs']}" \
            "${app['sh']}" -c "${app['md5sum']} -c {}"
    return 0
}

_koopa_md5sum_check_to_new_md5_file() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['md5sum']="$(_koopa_locate_md5sum)"
    app['tee']="$(_koopa_locate_tee)"
    _koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(_koopa_datetime)"
    dict['log_file']="md5sum-${dict['datetime']}.md5"
    _koopa_assert_is_not_file "${dict['log_file']}"
    _koopa_assert_is_file "$@"
    "${app['md5sum']}" "$@" 2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

_koopa_mem_gb() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    dict['str']="${KOOPA_MEM_GB:-}"
    if [[ -n "${dict['str']}" ]]
    then
        _koopa_print "${dict['str']}"
        return 0
    fi
    app['awk']="$(_koopa_locate_awk --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_macos
    then
        app['sysctl']="$(_koopa_macos_locate_sysctl)"
        _koopa_assert_is_executable "${app['sysctl']}"
        dict['mem']="$("${app['sysctl']}" -n 'hw.memsize')"
        dict['denom']=1073741824  # 1024^3; bytes
    elif _koopa_is_linux
    then
        dict['meminfo']='/proc/meminfo'
        _koopa_assert_is_file "${dict['meminfo']}"
        dict['mem']="$( \
            "${app['awk']}" '/MemTotal/ {print $2}' "${dict['meminfo']}" \
        )"
        dict['denom']=1048576  # 1024^2; KB
    else
        _koopa_stop 'Unsupported system.'
    fi
    dict['str']="$( \
        "${app['awk']}" \
            -v denom="${dict['denom']}" \
            -v mem="${dict['mem']}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_merge_pdf() {
    local -A app
    _koopa_assert_has_args "$#"
    app['gs']="$(_koopa_locate_gs)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    "${app['gs']}" \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}

_koopa_missing_arg() {
    _koopa_stop 'Missing required argument.'
}

_koopa_mkdir() {
    local -A app dict
    local -a mkdir mkdir_args pos
    app['mkdir']="$(_koopa_locate_mkdir --allow-system --realpath)"
    dict['sudo']=0
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    _koopa_assert_has_args "$#"
    mkdir_args=('-p')
    [[ "${dict['verbose']}" -eq 1 ]] && mkdir_args+=('-v')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir=('_koopa_sudo' "${app['mkdir']}")
    else
        mkdir=("${app['mkdir']}")
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}

_koopa_mktemp() {
    local -A app dict
    app['mktemp']="$(_koopa_locate_mktemp --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['mktemp']}" "$@")"
    [[ -e "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_move_files_in_batch() {
    local -A app dict
    local files
    _koopa_assert_has_args_eq "$#" 3
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['num']=''
    dict['source_dir']=''
    dict['target_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--num' "${dict['num']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    _koopa_assert_is_dir "${dict['target_dir']}"
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    readarray -t files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
        | "${app['head']}" -n "${dict['num']}" \
    )"
    _koopa_is_array_non_empty "${files[@]:-}" || return 1
    _koopa_mv --target-directory="${dict['target_dir']}" "${files[@]}"
    return 0
}

_koopa_move_files_up_1_level() {
    local -A dict
    local -a files
    _koopa_assert_has_args_le "$#" 1
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    readarray -t files <<< "$( \
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --type='f' \
    )"
    _koopa_is_array_non_empty "${files[@]:-}" || return 1
    _koopa_mv --target-directory="${dict['prefix']}" "${files[@]}"
    return 0
}

_koopa_move_into_dated_dirs_by_filename() {
    local -a grep_array
    local file grep_string
    _koopa_assert_has_args "$#"
    grep_array=(
        '^([0-9]{4})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '(.+)$'
    )
    grep_string="$(_koopa_paste0 "${grep_array[@]}")"
    for file in "$@"
    do
        local -A dict
        dict['file']="$file"
        if [[ "${dict['file']}" =~ $grep_string ]]
        then
            dict['year']="${BASH_REMATCH[1]}"
            dict['month']="${BASH_REMATCH[3]}"
            dict['day']="${BASH_REMATCH[5]}"
            dict['subdir']="${dict['year']}/${dict['month']}/${dict['day']}"
            _koopa_mv --target-directory="${dict['subdir']}" "${dict['file']}"
        else
            _koopa_stop "Does not contain date: '${dict['file']}'."
        fi
    done
    return 0
}

_koopa_move_into_dated_dirs_by_timestamp() {
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        local subdir
        subdir="$(_koopa_stat_modified --format='%Y/%m/%d' "$file")"
        _koopa_mv --target-directory="$subdir" "$file"
    done
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

_koopa_mv() {
    local -A app dict
    local -a mkdir mv mv_args pos rm
    app['mv']="$(_koopa_locate_mv --allow-system --realpath)"
    _koopa_is_macos && app['mv']='/bin/mv'
    _koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    dict['target_dir']=''
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir=('_koopa_mkdir' '--sudo')
        mv=('_koopa_sudo' "${app['mv']}")
        rm=('_koopa_rm' '--sudo')
    else
        mkdir=('_koopa_mkdir')
        mv=("${app['mv']}")
        rm=('_koopa_rm')
    fi
    mv_args=('-f')
    [[ "${dict['verbose']}" -eq 1 ]] && mv_args+=('-v')
    mv_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$( \
            _koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        mv_args+=("${dict['target_dir']}")
    else
        _koopa_assert_has_args_eq "$#" 2
        dict['source_file']="$(_koopa_strip_trailing_slash "${1:?}")"
        _koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="$(_koopa_strip_trailing_slash "${2:?}")"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(_koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    "${mv[@]}" "${mv_args[@]}"
    return 0
}

_koopa_nfiletypes() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['sed']="$(_koopa_locate_sed --allow-system)"
    app['sort']="$(_koopa_locate_sort)"
    app['uniq']="$(_koopa_locate_uniq)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['out']="$( \
        _koopa_find \
            --exclude='.*' \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.*' \
            --prefix="${dict['prefix']}" \
            --type='f' \
        | "${app['sed']}" 's/.*\.//' \
        | "${app['sort']}" \
        | "${app['uniq']}" --count \
        | "${app['sort']}" --numeric-sort \
        | "${app['sed']}" 's/^ *//g' \
        | "${app['sed']}" 's/ /\t/g' \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_ngettext() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['middle']=' '
    dict['msg1']=''
    dict['msg2']=''
    dict['num']=''
    dict['prefix']=''
    dict['str']=''
    dict['suffix']=''
    while (("$#"))
    do
        case "$1" in
            '--middle='*)
                dict['middle']="${1#*=}"
                shift 1
                ;;
            '--middle')
                dict['middle']="${2:?}"
                shift 2
                ;;
            '--msg1='*)
                dict['msg1']="${1#*=}"
                shift 1
                ;;
            '--msg1')
                dict['msg1']="${2:?}"
                shift 2
                ;;
            '--msg2='*)
                dict['msg2']="${1#*=}"
                shift 1
                ;;
            '--msg2')
                dict['msg2']="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--suffix='*)
                dict['suffix']="${1#*=}"
                shift 1
                ;;
            '--suffix')
                dict['suffix']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--middle' "${dict['middle']}"  \
        '--msg1' "${dict['msg1']}"  \
        '--msg2' "${dict['msg2']}"  \
        '--num' "${dict['num']}"
    case "${dict['num']}" in
        '1')
            dict['msg']="${dict['msg1']}"
            ;;
        *)
            dict['msg']="${dict['msg2']}"
            ;;
    esac
    dict['str']="${dict['prefix']}${dict['num']}${dict['middle']}\
${dict['msg']}${dict['suffix']}"
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_os_id() {
    local str
    str="$(_koopa_os_string | cut -d '-' -f 1)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_os_string() {
    local id release_file str version
    id=''
    version=''
    if _koopa_is_macos
    then
        id='macos'
        version="$(_koopa_major_version "$(_koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        release_file='/etc/os-release'
        if [[ -r "$release_file" ]]
        then
            id="$( \
                awk -F= \
                    '$1=="ID" { print $2 ;}' \
                    "$release_file" \
                | tr -d '"' \
            )"
            version="$( \
                awk -F= \
                    '$1=="VERSION_ID" { print $2 ;}' \
                    "$release_file" \
                | tr -d '"' \
            )"
            if [[ -n "$version" ]]
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
    [[ -n "$id" ]] || return 1
    str="$id"
    if [[ -n "$version" ]]
    then
        str="${str}-${version}"
    fi
    _koopa_print "$str"
    return 0
}

_koopa_os_type() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    app['uname']="$(_koopa_locate_uname --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['uname']}" -s \
        | "${app['tr']}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_pager() {
    local -A app
    local -a args
    _koopa_assert_has_args "$#"
    app['less']="$(_koopa_locate_less --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    args=("$@")
    _koopa_assert_is_file "${args[-1]}"
    "${app['less']}" -R "${args[@]}"
    return 0
}

_koopa_parallel() {
    local -A app dict
    local -a parallel_args
    _koopa_assert_has_args "$#"
    app['parallel']="$(_koopa_locate_parallel --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arg_file']=''
    dict['command']=''
    dict['jobs']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--arg-file='*)
                dict['arg_file']="${1#*=}"
                shift 1
                ;;
            '--arg-file')
                dict['arg_file']="${2:?}"
                shift 2
                ;;
            '--command='*)
                dict['command']="${1#*=}"
                shift 1
                ;;
            '--command')
                dict['command']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--arg-file' "${dict['arg_file']}" \
        '--command' "${dict['command']}" \
        '--jobs' "${dict['jobs']}"
    _koopa_assert_is_matching_fixed \
        --pattern='{}' \
        --string="${dict['command']}"
    _koopa_assert_is_file "${dict['arg_file']}"
    dict['arg_file']="$(_koopa_realpath "${dict['arg_file']}")"
    parallel_args+=(
        '--arg-file' "${dict['arg_file']}"
        '--bar'
        '--colsep' ' '
        '--eta'
        '--jobs' "${dict['jobs']}"
        '--keep-order'
        '--progress'
        '--will-cite'
        "${dict['command']}"
    )
    "${app['parallel']}" "${parallel_args[@]}"
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

_koopa_parse_url() {
    local -A app
    local -a curl_args pos
    _koopa_assert_has_args "$#"
    app['curl']="$(_koopa_locate_curl --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    curl_args=(
        '--disable'
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
        '--silent'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--insecure' | \
            '--list-only')
                curl_args+=("$1")
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
    _koopa_assert_has_args_eq "$#" 1
    curl_args+=("${1:?}")
    "${app['curl']}" "${curl_args[@]}"
    return 0
}

_koopa_paste() {
    local -a pos
    local IFS sep str
    sep=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sep='*)
                sep="${1#*=}"
                shift 1
                ;;
            '--sep')
                sep="${2:?}"
                shift 2
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    IFS=''
    str="${*/#/$sep}"
    str="${str:${#sep}}"
    _koopa_print "$str"
    return 0
}

_koopa_paste0() {
    _koopa_paste --sep='' "$@"
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

_koopa_private_installers_s3_uri() {
    _koopa_assert_has_no_args "$#"
    _koopa_print 's3://private.koopa.acidgenomics.com/installers'
}

_koopa_progress_bar() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    [[ "${COLUMNS:?}" -lt 40 ]] && return 0
    app['bc']="$(_koopa_locate_bc)"
    app['echo']="$(_koopa_locate_echo)"
    app['tr']="$(_koopa_locate_tr)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bar_char_done']='#'
    dict['bar_char_todo']='-'
    dict['bar_pct_scale']=1
    dict['bar_size']="$((COLUMNS-20))"
    dict['current']="${1:?}"
    dict['total']="${2:?}"
    dict['percent']="$( \
        "${app['bc']}" <<< \
            "scale=${dict['bar_pct_scale']}; \
            100 * ${dict['current']} / ${dict['total']}" \
    )"
    dict['percent_str']="$( \
        printf "%0.${dict['bar_pct_scale']}f" "${dict['percent']}"
    )"
    dict['done']="$( \
        "${app['bc']}" <<< \
            "scale=0; \
            ${dict['bar_size']} * ${dict['percent']} / 100" \
    )"
    dict['todo']="$( \
        "${app['bc']}" <<< \
            "scale=0; ${dict['bar_size']} - ${dict['done']}" \
    )"
    dict['done_sub_bar']=$( \
        printf "%${dict['done']}s" | \
        "${app['tr']}" ' ' "${dict['bar_char_done']}" \
    )
    dict['todo_sub_bar']=$( \
        printf "%${dict['todo']}s" \
        | "${app['tr']}" ' ' "${dict['bar_char_todo']}" \
    )
    >&2 "${app['echo']}" -en "\r\
Progress \
[${dict['done_sub_bar']}${dict['todo_sub_bar']}] \
${dict['percent_str']}% "
    if [[ "${dict['total']}" -eq "${dict['current']}" ]]
    then
        printf '\n'
        _koopa_alert_success 'DONE!'
    fi
    return 0
}

_koopa_public_ip_address() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['dig']="$(_koopa_locate_dig --allow-missing)"
    if [[ -x "${app['dig']}" ]]
    then
        str="$( \
            "${app['dig']}" +short \
                'myip.opendns.com' \
                '@resolver1.opendns.com' \
                -4 \
        )"
    else
        str="$(_koopa_parse_url 'https://ipecho.net/plain')"
    fi
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_push_all_app_builds() {
    local -A dict
    local -a app_names
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    readarray -t app_names <<< "$( \
        _koopa_find \
            --days-modified-within=7 \
            --min-depth=1 \
            --max-depth=1 \
            --prefix="${dict['opt_prefix']}" \
            --sort \
            --type='l' \
        | _koopa_basename \
    )"
    if _koopa_is_array_empty "${app_names[@]}"
    then
        _koopa_stop 'No apps were built recently.'
    fi
    _koopa_push_app_build "${app_names[@]}"
    return 0
}

_koopa_push_app_build() {
    local -A app dict
    local name
    _koopa_assert_has_args "$#"
    _koopa_assert_can_push_binary
    app['aws']="$(_koopa_locate_aws)"
    app['tar']="$(_koopa_locate_tar --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch2)" # e.g. 'amd64'.
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['os_string']="$(_koopa_os_string)"
    dict['profile']='acidgenomics'
    dict['s3_bucket']='s3://private.koopa.acidgenomics.com/binaries'
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    for name in "$@"
    do
        local -A dict2
        dict2['name']="$name"
        dict2['prefix']="$( \
            _koopa_realpath "${dict['opt_prefix']}/${dict2['name']}" \
        )"
        _koopa_assert_is_dir "${dict2['prefix']}"
        if [[ -f "${dict2['prefix']}/.koopa-binary" ]]
        then
            _koopa_alert_note "'${dict2['name']}' was installed as a binary."
            continue
        fi
        dict2['version']="$(_koopa_basename "${dict2['prefix']}")"
        dict2['local_tar']="${dict['tmp_dir']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['s3_rel_path']="/${dict['os_string']}/${dict['arch']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['remote_tar']="${dict['s3_bucket']}${dict2['s3_rel_path']}"
        _koopa_alert "Pushing '${dict2['prefix']}' to '${dict2['remote_tar']}'."
        _koopa_mkdir "${dict['tmp_dir']}/${dict2['name']}"
        _koopa_alert "Creating archive at '${dict2['local_tar']}'."
        "${app['tar']}" \
            -Pcvvz \
            -f "${dict2['local_tar']}" \
            "${dict2['prefix']}/"
        _koopa_alert "Copying to S3 at '${dict2['remote_tar']}'."
        "${app['aws']}" s3 \
            --profile="${dict['profile']}" \
            cp \
                "${dict2['local_tar']}" \
                "${dict2['remote_tar']}"
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_random_string() {
    local -A app dict
    app['head']="$(_koopa_locate_head --allow-system)"
    app['md5sum']="$(_koopa_locate_md5sum --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['length']=10
    dict['seed']="${RANDOM:?}"
    while (("$#"))
    do
        case "$1" in
            '--length='*)
                dict['length']="${1#*=}"
                shift 1
                ;;
            '--length')
                dict['length']="${2:?}"
                shift 2
                ;;
            '--seed='*)
                dict['seed']="${1#*=}"
                shift 1
                ;;
            '--seed')
                dict['seed']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${dict['length']}" -le 32 ]] || return 1
    dict['str']="$( \
        _koopa_print "${dict['seed']}" \
        | "${app['md5sum']}" \
        | "${app['head']}" -c "${dict['length']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_read_prompt_yn() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 2
    dict['input']="${2:?}"
    dict['no']="$(_koopa_print_red 'no')"
    dict['no_default']="$(_koopa_print_red_bold 'NO')"
    dict['prompt']="${1:?}"
    dict['yes']="$(_koopa_print_green 'yes')"
    dict['yes_default']="$(_koopa_print_green_bold 'YES')"
    case "${dict['input']}" in
        '0')
            dict['yn']="${dict['yes']}/${dict['no_default']}"
            ;;
        '1')
            dict['yn']="${dict['yes_default']}/${dict['no']}"
            ;;
        *)
            _koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    _koopa_print "${dict['prompt']}? [${dict['yn']}]: "
    return 0
}

_koopa_read_yn() {
    local -A dict
    local -a read_args
    _koopa_assert_has_args_eq "$#" 2
    dict['prompt']="$(_koopa_read_prompt_yn "$@")"
    dict['default']="$(_koopa_int_to_yn "${2:?}")"
    read_args=(
        '-e'
        '-i' "${dict['default']}"
        '-p' "${dict['prompt']}"
        '-r'
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    case "${dict['choice']}" in
        '1' | \
        'T' | \
        'TRUE' | \
        'True' | \
        'Y' | \
        'YES' | \
        'Yes' | \
        'true' | \
        'y' | \
        'yes')
            dict['int']=1
            ;;
        '0' | \
        'F' | \
        'FALSE' | \
        'False' | \
        'N' | \
        'NO' | \
        'No' | \
        'false' | \
        'n' | \
        'no')
            dict['int']=0
            ;;
        *)
            _koopa_stop "Invalid 'yes/no' choice: '${dict['choice']}'."
            ;;
    esac
    _koopa_print "${dict['int']}"
    return 0
}

_koopa_read() {
    local -A dict
    local -a read_args
    _koopa_assert_has_args_eq "$#" 2
    dict['default']="${2:-}"
    dict['prompt']="${1:?} [${dict['default']}]: "
    read_args+=(
        '-e'
        '-i' "${dict['default']}"
        '-p' "${dict['prompt']}"
        '-r'
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    _koopa_print "${dict['choice']}"
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

_koopa_relink() {
    local -A dict
    local -a ln pos rm sudo
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    _koopa_assert_has_args_eq "$#" 2
    ln=('_koopa_ln')
    rm=('_koopa_rm')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        ln+=('--sudo')
        rm+=('--sudo')
    fi
    dict['source_file']="${1:?}"
    dict['dest_file']="${2:?}"
    [[ -e "${dict['source_file']}" ]] || return 0
    [[ -L "${dict['dest_file']}" ]] && return 0
    "${rm[@]}" "${dict['dest_file']}"
    "${ln[@]}" "${dict['source_file']}" "${dict['dest_file']}"
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

_koopa_rename_from_csv() {
    local file line
    _koopa_assert_has_args "$#"
    file="${1:?}"
    _koopa_assert_is_file_type --ext='csv' "$file"
    while read -r line
    do
        local from to
        from="${line%,*}"
        to="${line#*,}"
        _koopa_mv "$from" "$to"
    done < "$file"
    return 0
}

_koopa_rename_lowercase() {
    local -A app dict
    local -a pos
    _koopa_assert_has_args "$#"
    app['rename']="$(_koopa_locate_rename)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']='y/A-Z/a-z/'
    dict['recursive']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict['recursive']=1
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
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        _koopa_assert_has_args_le "$#" 1
        dict['prefix']="${1:-.}"
        _koopa_assert_is_dir "${dict['prefix']}"
        _koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --sort \
            --type='f' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
        _koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --type='d' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
    else
        "${app['rename']}" \
            --force \
            --verbose \
            "${dict['pattern']}" \
            "$@"
    fi
    return 0
}

_koopa_reset_permissions() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['chmod']="$(_koopa_locate_chmod)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group']="$(_koopa_group_name)"
    dict['prefix']="${1:?}"
    dict['user']="$(_koopa_user_name)"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    _koopa_chown --recursive \
        "${dict['user']}:${dict['group']}" \
        "${dict['prefix']}"
    _koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='d' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    _koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rw,g=rw,o=r' {}
    _koopa_find \
        --pattern='*.sh' \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

_koopa_rg_sort() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['rg']="$(_koopa_locate_rg)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    dict['str']="$( \
        "${app['rg']}" \
            --pretty \
            --sort 'path' \
            "${dict['pattern']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_rg_unique() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['rg']="$(_koopa_locate_rg)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    dict['str']="$( \
        "${app['rg']}" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "${dict['pattern']}" \
        | "${app['sort']}" --unique \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_rm() {
    local -A app bool
    local -a pos rm rm_args
    app['rm']="$(_koopa_locate_rm --allow-system --realpath)"
    bool['sudo']=0
    bool['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--quiet' | \
            '-q')
                bool['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                bool['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                bool['verbose']=1
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
    _koopa_assert_has_args "$#"
    rm_args=('-f' '-r')
    [[ "${bool['verbose']}" -eq 1 ]] && rm_args+=('-v')
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        rm+=('_koopa_sudo' "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}

_koopa_roff() {
    local -A app dict
    local -a files
    _koopa_assert_has_no_args "$#"
    app['ronn']="$(_koopa_locate_ronn)"
    _koopa_assert_is_executable "${app[@]}"
    dict['man_prefix']="$(_koopa_man_prefix)"
    readarray -t files <<< "$( \
        _koopa_find \
            --pattern='*.ronn' \
            --prefix="${dict['man_prefix']}" \
            --sort \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${files[@]}"
    "${app['ronn']}" --roff "${files[@]}"
    return 0
}

_koopa_rsync_ignore() {
    local -A dict
    local -a rsync_args
    _koopa_assert_has_args "$#"
    dict['ignore_local']='.gitignore'
    dict['ignore_global']="${HOME}/.gitignore"
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict['ignore_local']}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict['ignore_local']}"
        )
    fi
    if [[ -f "${dict['ignore_global']}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict['ignore_global']}")
    fi
    _koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}

_koopa_rsync() {
    local -A app dict
    local -a rsync_args
    _koopa_assert_has_args "$#"
    app['rsync']="$(_koopa_locate_rsync)"
    _koopa_assert_is_executable "${app[@]}"
    dict['source_dir']=''
    dict['target_dir']=''
    rsync_args=(
        '--human-readable'
        '--progress'
        '--protect-args'
        '--recursive'
        '--stats'
        '--verbose'
    )
    if _koopa_is_macos
    then
        rsync_args+=('--iconv=utf-8,utf-8-mac')
    fi
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--exclude')
                rsync_args+=("--exclude=${2:?}")
                shift 2
                ;;
            '--filter='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--filter')
                rsync_args+=("--filter=${2:?}")
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--log-file='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--archive' | \
            '--copy-links' | \
            '--delete' | \
            '--delete-before' | \
            '--dry-run' | \
            '--size-only')
                rsync_args+=("$1")
                shift 1
                ;;
            '--sudo')
                rsync_args+=('--rsync-path' 'sudo rsync')
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    if [[ -d "${dict['source_dir']}" ]]
    then
        dict['source_dir']="$(_koopa_realpath "${dict['source_dir']}")"
    fi
    if [[ -d "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(_koopa_realpath "${dict['target_dir']}")"
    fi
    dict['source_dir']="$(_koopa_strip_trailing_slash "${dict['source_dir']}")"
    dict['target_dir']="$(_koopa_strip_trailing_slash "${dict['target_dir']}")"
    rsync_args+=("${dict['source_dir']}/" "${dict['target_dir']}/")
    _koopa_dl 'rsync args' "${rsync_args[*]}"
    "${app['rsync']}" "${rsync_args[@]}"
    return 0
}

_koopa_run_if_installed() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! _koopa_is_installed "$arg"
        then
            _koopa_alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(_koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}

_koopa_rust_cargo_config_file() {
    _koopa_print "${HOME:?}/.cargo/config.toml"
}

_koopa_sanitize_version() {
    local str
    _koopa_assert_has_args "$#"
    for str in "$@"
    do
        _koopa_str_detect_regex \
            --string="$str" \
            --pattern='[.0-9]+' \
            || return 1
        str="$( \
            _koopa_sub \
                --pattern='^([.0-9]+).*$' \
                --regex \
                --replacement='\1' \
                "$str" \
        )"
        _koopa_print "$str"
    done
    return 0
}

_koopa_script_name() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$( \
        caller \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    dict['bn']="$(_koopa_basename "${dict['file']}")"
    [[ -n "${dict['bn']}" ]] || return 0
    _koopa_print "${dict['bn']}"
    return 0
}

_koopa_script_parent_dir() {
    local script
    _koopa_assert_has_no_args "$#"
    script="${BASH_SOURCE[1]}"
    [[ -f "$script" ]] || return 1
    script="$(_koopa_realpath "$script")"
    _koopa_parent_dir "$script"
    return 0
}

_koopa_script_source() {
    local script
    _koopa_assert_has_no_args "$#"
    script="${BASH_SOURCE[1]}"
    [[ -f "$script" ]] || return 1
    _koopa_realpath "$script"
    return 0
}

_koopa_shared_ext() {
    local str
    if _koopa_is_macos
    then
        str='dylib'
    else
        str='so'
    fi
    _koopa_print "$str"
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

_koopa_snake_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        _koopa_gsub \
            --pattern='[^A-Za-z0-9_]' \
            --regex \
            --replacement='_' \
            "$@" \
        | _koopa_lowercase \
    )"
    _koopa_is_array_non_empty "${out[@]:-}" || return 1
    _koopa_print "${out[@]}"
    return 0
}

_koopa_sort_lines() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['vim']="$(_koopa_locate_vim)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c ':sort' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

_koopa_source_dir() {
    local file prefix
    _koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    _koopa_assert_is_dir "$prefix"
    for file in "${prefix}/"*'.sh'
    do
        [[ -f "$file" ]] || continue
        . "$file"
    done
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

_koopa_spell() {
    local -A app
    _koopa_assert_has_args "$#"
    app['aspell']="$(_koopa_locate_aspell)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
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

_koopa_stat_access_human() {
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    local -A app dict
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%A'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sp'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_stat_access_octal() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%a'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%OLp'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_stat_group_id() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['format_string']='%g'
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_stat_group_name() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%G'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sg'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_stat_modified() {
    local -A app dict
    local -a pos timestamps
    local timestamp
    _koopa_assert_has_args "$#"
    app['date']="$(_koopa_locate_date)"
    app['stat']="$(_koopa_locate_stat)"
    _koopa_assert_is_executable "${app[@]}"
    dict['format']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--format='*)
                dict['format']="${1#*=}"
                shift 1
                ;;
            '--format')
                dict['format']="${2:?}"
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
    _koopa_assert_is_set '--format' "${dict['format']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    readarray -t timestamps <<< "$( \
        "${app['stat']}" --format='%Y' "$@" \
    )"
    for timestamp in "${timestamps[@]}"
    do
        local string
        string="$( \
            "${app['date']}" -d "@${timestamp}" +"${dict['format']}" \
        )"
        [[ -n "$string" ]] || return 1
        _koopa_print "$string"
    done
    return 0
}

_koopa_stat_user_id() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['format_string']='%u'
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_stat_user_name() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%U'
    elif _koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Su'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_status_fail() {
    _koopa_status 'FAIL' 'red' "$@" >&2
}

_koopa_status_note() {
    _koopa_status 'NOTE' 'yellow' "$@"
}

_koopa_status_ok() {
    _koopa_status 'OK' 'green' "$@"
}

_koopa_status() {
    local -A dict
    local string
    _koopa_assert_has_args_ge "$#" 3
    dict['label']="$(printf '%10s\n' "${1:?}")"
    dict['color']="$(_koopa_ansi_escape "${2:?}")"
    dict['nocolor']="$(_koopa_ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        string="${dict['color']}${dict['label']}${dict['nocolor']} | ${string}"
        _koopa_print "$string"
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

_koopa_str_unique_by_colon() {
    local -A app
    local str str2
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            _koopa_print "$str" \
                | "${app['tr']}" ':' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ':' \
                | _koopa_strip_right --pattern=':' \
        )"
        [[ -n "$str2" ]] || return 1
        _koopa_print "$str2"
    done
    return 0
}

_koopa_str_unique_by_semicolon() {
    local -A app
    local str str2
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            _koopa_print "$str" \
                | "${app['tr']}" ';' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ';' \
                | _koopa_strip_right --pattern=';' \
        )"
        [[ -n "$str2" ]] || return 1
        _koopa_print "$str2"
    done
    return 0
}

_koopa_str_unique_by_space() {
    local -A app
    local str str2
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            _koopa_print "$str" \
                | "${app['tr']}" ' ' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ' ' \
                | _koopa_strip_right --pattern=' ' \
        )"
        [[ -n "$str2" ]] || return 1
        _koopa_print "$str2"
    done
    return 0
}

_koopa_strip_left() {
    local -A dict
    local -a pos
    local str
    dict['pattern']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
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
    _koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str##"${dict['pattern']}"}"
    done
    return 0
}

_koopa_strip_right() {
    local -A dict
    local -a pos
    local str
    dict['pattern']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
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
    _koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str%%"${dict['pattern']}"}"
    done
    return 0
}

_koopa_strip_trailing_slash() {
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    _koopa_strip_right --pattern='/' "$@"
    return 0
}

_koopa_sub() {
    local -A app bool dict
    local -a out pos
    local str
    app['perl']="$(_koopa_locate_perl --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['global']=0
    bool['regex']=0
    dict['pattern']=''
    dict['replace']=''
    dict['tail']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict['replace']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replace']="${2:-}"
                shift 2
                ;;
            '--fixed')
                bool['regex']=0
                shift 1
                ;;
            '--global')
                bool['global']=1
                shift 1
                ;;
            '--regex')
                bool['regex']=1
                shift 1
                ;;
            '--'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    [[ "${bool['global']}" -eq 1 ]] && dict['tail']='g'
    if [[ "${bool['regex']}" -eq 1 ]]
    then
        dict['pattern']="${dict['pattern']//\//\\\/}"
        dict['replace']="${dict['replace']//\//\\\/}"
        dict['expr']="s/${dict['pattern']}/${dict['replace']}/${dict['tail']}"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replace']}'; \
            s/\$pattern/\$replacement/${dict['tail']}; \
        "
    fi
    for str in "$@"
    do
        if [[ -z "$str" ]]
        then
            out+=("$str")
            continue
        fi
        out+=(
            "$( \
                printf '%s' "$str" \
                | LANG=C "${app['perl']}" -p -e "${dict['expr']}" \
            )"
        )
    done
    _koopa_print "${out[@]}"
    return 0
}

_koopa_sudo_append_string() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(_koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        _koopa_mkdir --sudo "${dict['parent_dir']}"
    fi
    if [[ ! -f "${dict['file']}" ]]
    then
        _koopa_touch --sudo "${dict['file']}"
    fi
    _koopa_print "${dict['string']}" \
        | _koopa_sudo "${app['tee']}" -a "${dict['file']}" >/dev/null
    return 0
}

_koopa_sudo_trigger() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_is_root && return 0
    _koopa_has_passwordless_sudo && return 0
    _koopa_is_admin || return 1
    app['sudo']="$(_koopa_locate_sudo)"
    _koopa_assert_is_executable "${app['sudo']}"
    "${app['sudo']}" -v
    return 0
}

_koopa_sudo_write_string() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(_koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        _koopa_mkdir --sudo "${dict['parent_dir']}"
    fi
    if [[ ! -f "${dict['file']}" ]]
    then
        _koopa_touch --sudo "${dict['file']}"
    fi
    _koopa_print "${dict['string']}" \
        | _koopa_sudo "${app['tee']}" "${dict['file']}" >/dev/null
    return 0
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

_koopa_tar_multiple_dirs() {
    local -A app dict
    local -a dirs pos
    local dir
    _koopa_assert_has_args "$#"
    app['tar']="$(_koopa_locate_tar --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['delete']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--delete')
                dict['delete']=1
                shift 1
                ;;
            '--no-delete' | \
            '--keep')
                dict['delete']=0
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
    _koopa_assert_is_dir "$@"
    readarray -t dirs <<< "$(_koopa_realpath "$@")"
    (
        for dir in "${dirs[@]}"
        do
            local bn
            bn="$(_koopa_basename "$dir")"
            _koopa_alert "Compressing '${dir}'."
            _koopa_cd "$(_koopa_dirname "$dir")"
            "${app['tar']}" -czf "${bn}.tar.gz" "${bn}/"
            [[ "${dict['delete']}" -eq 1 ]] && _koopa_rm "$dir"
        done
    )
    return 0
}

_koopa_test_find_files_by_ext() {
    local -A dict
    local -a all_files
    _koopa_assert_has_args "$#"
    dict['ext']="${1:?}"
    dict['pattern']="\.${dict['ext']}$"
    readarray -t all_files <<< "$(_koopa_test_find_files)"
    dict['files']="$( \
        _koopa_print "${all_files[@]}" \
        | _koopa_grep \
            --pattern="${dict['pattern']}" \
            --regex \
        || true \
    )"
    if [[ -z "${dict['files']}" ]]
    then
        _koopa_stop "Failed to find test files with extension '${dict['ext']}'."
    fi
    _koopa_print "${dict['files']}"
    return 0
}

_koopa_test_find_files_by_shebang() {
    local -A app dict
    local -a all_files files
    local file
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head)"
    app['tr']="$(_koopa_locate_tr)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    readarray -t all_files <<< "$(_koopa_test_find_files)"
    files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        shebang="$( \
            "${app['tr']}" --delete '\0' < "$file" \
                | "${app['head']}" -n 1 \
                || true \
        )"
        [[ -n "$shebang" ]] || continue
        if _koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict['pattern']}"
        then
            files+=("$file")
        fi
    done
    if _koopa_is_array_empty "${files[@]}"
    then
        _koopa_stop "Failed to find files with pattern '${dict['pattern']}'."
    fi
    _koopa_print "${files[@]}"
    return 0
}

_koopa_test_find_files() {
    local -A dict
    local -a files
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_koopa_prefix)"
    readarray -t files <<< "$( \
        _koopa_find \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='common.sh' \
            --exclude='coverage/**' \
            --exclude='etc/**' \
            --exclude='libexec/**' \
            --exclude='opt/**' \
            --exclude='share/**' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${files[@]:-}"
    then
        _koopa_stop 'Failed to find any test files.'
    fi
    _koopa_print "${files[@]}"
}

_koopa_test_grep() {
    local -A app dict
    local -a failures pos
    local file
    _koopa_assert_has_args "$#"
    app['grep']="$(_koopa_locate_grep)"
    _koopa_assert_is_executable "${app[@]}"
    dict['ignore']=''
    dict['name']=''
    dict['pattern']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ignore='*)
                dict['ignore']="${1#*=}"
                shift 1
                ;;
            '--ignore')
                dict['ignore']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
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
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--pattern' "${dict['pattern']}"
    failures=()
    for file in "$@"
    do
        local x
        if [[ -n "${dict['ignore']}" ]]
        then
            if "${app['grep']}" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${dict['ignore']}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "${app['grep']}" -HPn \
                --binary-files='without-match' \
                "${dict['pattern']}" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        _koopa_status_fail "${dict['name']} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    _koopa_status_ok "${dict['name']} [${#}]"
    return 0
}

_koopa_test_true_color() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['awk']}" 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
    return 0
}

_koopa_test() {
    local prefix
    _koopa_assert_has_no_args "$#"
    prefix="$(_koopa_tests_prefix)"
    (
        _koopa_cd "$prefix"
        ./linter
        ./shunit2
    )
    return 0
}

_koopa_tex_version() {
    local -A app
    local str
    _koopa_assert_has_args_le "$#" 1
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['tex']="${1:-}"
    [[ -z "${app['tex']}" ]] && app['tex']="$(_koopa_locate_tex)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['tex']}" --version \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '(' -f '2' \
            | "${app['cut']}" -d ')' -f '1' \
            | "${app['cut']}" -d ' ' -f '3' \
            | "${app['cut']}" -d '/' -f '1' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_tmp_dir_in_wd() {
    _koopa_init_dir "$(_koopa_tmp_string)"
    return 0
}

_koopa_tmp_dir() {
    local x
    _koopa_assert_has_no_args "$#"
    x="$(_koopa_mktemp -d)"
    _koopa_assert_is_dir "$x"
    x="$(_koopa_realpath "$x")"
    _koopa_print "$x"
    return 0
}

_koopa_tmp_file_in_wd() {
    local -A dict
    dict['ext']=''
    dict['file']="$(_koopa_tmp_string)"
    while (("$#"))
    do
        case "$1" in
            '--ext='*)
                dict['ext']="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict['ext']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict['ext']}" ]]
    then
        dict['file']="${dict['file']}.${dict['ext']}"
    fi
    _koopa_touch "${dict['file']}"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_realpath "${dict['file']}"
    return 0
}

_koopa_tmp_file() {
    local x
    _koopa_assert_has_no_args "$#"
    x="$(_koopa_mktemp)"
    _koopa_assert_is_file "$x"
    x="$(_koopa_realpath "$x")"
    _koopa_print "$x"
    return 0
}

_koopa_tmp_log_file() {
    _koopa_assert_has_no_args "$#"
    _koopa_tmp_file
    return 0
}

_koopa_tmp_string() {
    _koopa_print ".koopa-tmp-$(_koopa_random_string)"
    return 0
}

_koopa_to_string() {
    _koopa_assert_has_args "$#"
    _koopa_paste --sep=', ' "$@"
    return 0
}

_koopa_today() {
    local str
    str="$(date '+%Y-%m-%d')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_touch() {
    local -A app dict
    local -a mkdir pos touch
    _koopa_assert_has_args "$#"
    app['touch']="$(_koopa_locate_touch --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    _koopa_assert_has_args "$#"
    mkdir=('_koopa_mkdir')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir+=('--sudo')
        touch=('_koopa_sudo' "${app['touch']}")
    else
        touch=("${app['touch']}")
    fi
    for file in "$@"
    do
        local dn
        if [[ -e "$file" ]]
        then
            _koopa_assert_is_not_dir "$file"
            _koopa_assert_is_not_symlink "$file"
        fi
        dn="$(_koopa_dirname "$file")"
        if [[ ! -d "$dn" ]] && \
            _koopa_str_detect_fixed \
                --string="$dn" \
                --pattern='/'
        then
            "${mkdir[@]}" "$dn"
        fi
        "${touch[@]}" "$file"
    done
    return 0
}

_koopa_trim_ws() {
    local str
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
        _koopa_print "$str"
    done
    return 0
}

_koopa_umask() {
    umask 0002
    return 0
}

_koopa_unlink_in_bin() {
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_bin_prefix)" \
        "$@"
}

_koopa_unlink_in_dir() {
    local -A dict
    local -a names pos
    local name
    _koopa_assert_has_args "$#"
    dict['allow_missing']=0
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--allow-missing')
                dict['allow_missing']=1
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
    _koopa_assert_has_args "$#"
    _koopa_assert_is_set '--prefix' "${dict['prefix']}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    names=("$@")
    for name in "${names[@]}"
    do
        local file
        file="${dict['prefix']}/${name}"
        if [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            if [[ -L "$file" ]]
            then
                _koopa_rm "$file"
            fi
        else
            _koopa_assert_is_symlink "$file"
            _koopa_rm "$file"
        fi
    done
    return 0
}

_koopa_unlink_in_man1() {
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_man_prefix)/man1" \
        "$@"
}

_koopa_unlink_in_opt() {
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_opt_prefix)" \
        "$@"
}

_koopa_user_id() {
    local string
    string="$(id -u)"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_user_name() {
    local str
    str="$(id -un)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_validate_json() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['python']="$(_koopa_locate_python)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}

_koopa_version_pattern() {
    _koopa_assert_has_no_args "$#"
    _koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}

_koopa_view_latest_tmp_log_file() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="${TMPDIR:-/tmp}"
    dict['user_id']="$(_koopa_user_id)"
    dict['log_file']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict['user_id']}-*" \
            --prefix="${dict['tmp_dir']}" \
            --sort \
            --type='f' \
        | "${app['tail']}" -n 1 \
    )"
    if [[ ! -f "${dict['log_file']}" ]]
    then
        _koopa_stop "No koopa log file detected in '${dict['tmp_dir']}'."
    fi
    _koopa_alert "Viewing '${dict['log_file']}'."
    _koopa_pager +G "${dict['log_file']}"
    return 0
}

_koopa_walk() {
    local walk
    walk="$(_koopa_bin_prefix)/walk"
    [[ -x "$walk" ]] || return 1
    cd "$("$walk" "$@")" || return 1
    return 0
}

_koopa_warn_if_export() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if _koopa_is_export "$arg"
        then
            _koopa_warn "'${arg}' is exported."
        fi
    done
    return 0
}

_koopa_warn() {
    _koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}

_koopa_wget_recursive() {
    local -A app dict
    local -a wget_args
    _koopa_assert_has_args "$#"
    app['wget']="$(_koopa_locate_wget)"
    _koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(_koopa_datetime)"
    dict['password']=''
    dict['url']=''
    dict['user']=''
    while (("$#"))
    do
        case "$1" in
            '--password='*)
                dict['password']="${1#*=}"
                shift 1
                ;;
            '--password')
                dict['password']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict['user']="${1#*=}"
                shift 1
                ;;
            '--user')
                dict['user']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--password' "${dict['password']}" \
        '--url' "${dict['url']}" \
        '--user' "${dict['user']}"
    dict['log_file']="wget-${dict['datetime']}.log"
    dict['password']="${dict['password']@Q}"
    wget_args=(
        "--output-file=${dict['log_file']}"
        "--password=${dict['password']}"
        "--user=${dict['user']}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict['url']}"/*
    )
    "${app['wget']}" "${wget_args[@]}"
    return 0
}

_koopa_which_function() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    dict['input_key']="${1:?}"
    if _koopa_is_function "${dict['input_key']}"
    then
        _koopa_print "${dict['input_key']}"
        return 0
    fi
    dict['key']="${dict['input_key']}"
    dict['key']="${dict['key']//-/_}"
    dict['key']="${dict['key']//\./}"
    dict['os_id']="$(_koopa_os_id)"
    if _koopa_is_function "_koopa_${dict['os_id']}_${dict['key']}"
    then
        dict['fun']="_koopa_${dict['os_id']}_${dict['key']}"
    elif _koopa_is_rhel_like && \
        _koopa_is_function "_koopa_rhel_${dict['key']}"
    then
        dict['fun']="_koopa_rhel_${dict['key']}"
    elif _koopa_is_debian_like && \
        _koopa_is_function "_koopa_debian_${dict['key']}"
    then
        dict['fun']="_koopa_debian_${dict['key']}"
    elif _koopa_is_fedora_like && \
        _koopa_is_function "_koopa_fedora_${dict['key']}"
    then
        dict['fun']="_koopa_fedora_${dict['key']}"
    elif _koopa_is_linux && \
        _koopa_is_function "_koopa_linux_${dict['key']}"
    then
        dict['fun']="_koopa_linux_${dict['key']}"
    else
        dict['fun']="_koopa_${dict['key']}"
    fi
    _koopa_is_function "${dict['fun']}" || return 1
    _koopa_print "${dict['fun']}"
    return 0
}

_koopa_which_realpath() {
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        cmd="$(_koopa_which "$cmd")"
        [[ -n "$cmd" ]] || return 1
        cmd="$(_koopa_realpath "$cmd")"
        [[ -x "$cmd" ]] || return 1
        _koopa_print "$cmd"
    done
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

_koopa_write_string() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(_koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        _koopa_mkdir "${dict['parent_dir']}"
    fi
    _koopa_print "${dict['string']}" > "${dict['file']}"
    return 0
}

_koopa_zsh_compaudit_set_permissions() {
    local -A dict
    local -a prefixes
    local prefix
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_owner
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['user_id']="$(_koopa_user_id)"
    prefixes=(
        "${dict['koopa_prefix']}/lang/zsh"
        "${dict['opt_prefix']}/zsh/share/zsh"
    )
    for prefix in "${prefixes[@]}"
    do
        local access stat_user_id
        [[ -d "$prefix" ]] || continue
        stat_user_id="$(_koopa_stat_user_id "$prefix")"
        if [[ "$stat_user_id" != "${dict['user_id']}" ]]
        then
            _koopa_alert "Changing ownership at '${prefix}' from \
'${stat_user_id}' to '${dict['user_id']}'."
            _koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
        fi
        access="$(_koopa_stat_access_octal "$prefix")"
        access="${access: -3}"
        case "$access" in
            '700' | \
            '744' | \
            '755')
                ;;
            *)
                _koopa_alert "Fixing write access at '${prefix}'."
                _koopa_chmod --recursive --verbose 'go-w' "$prefix"
                ;;
        esac
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

_koopa_is_alpine() {
    _koopa_is_os 'alpine'
}

_koopa_is_amd64() {
    case "$(_koopa_arch)" in
        'amd64' | 'x86_64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_koopa_is_arch() {
    _koopa_is_os 'arch'
}

_koopa_is_arm64() {
    case "$(_koopa_arch)" in
        'aarch64' | 'arm64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_koopa_is_array_empty() {
    ! _koopa_is_array_non_empty "$@"
}

_koopa_is_array_non_empty() {
    local -a arr
    [[ "$#" -gt 0 ]] || return 1
    arr=("$@")
    [[ "${#arr[@]}" -gt 0 ]] || return 1
    [[ -n "${arr[0]}" ]] || return 1
    return 0
}

_koopa_is_aws_ec2_instance() {
    local -A app
    _koopa_is_linux || return 1
    app['ec2_metadata']="$(_koopa_linux_locate_ec2_metadata --allow-missing)"
    [[ -x "${app['ec2_metadata']}" ]]
}

_koopa_is_aws_ec2() {
    [[ -x '/usr/bin/ec2metadata' ]] && return 0
    [[ "$(hostname -d)" == 'ec2.internal' ]] && return 0
    return 1
}

_koopa_is_aws_s3_uri() {
    local pattern string
    _koopa_assert_has_args "$#"
    pattern='s3://'
    for string in "$@"
    do
        _koopa_str_detect_fixed \
            --pattern="$pattern" \
            --string="$string" \
        || return 1
    done
    return 0
}

_koopa_is_bootstrap_current() {
    local -A dict
    dict['bootstrap_prefix']="$(_koopa_bootstrap_prefix)"
    dict['installed_version_file']="${dict['bootstrap_prefix']}/VERSION"
    dict['expected_version_file']="${KOOPA_PREFIX:?}/etc/koopa/bootstrap-version.txt"
    [[ -f "${dict['expected_version_file']}" ]] || return 1
    [[ -f "${dict['installed_version_file']}" ]] || return 1
    dict['expected_version']="$(cat "${dict['expected_version_file']}")"
    dict['installed_version']="$(cat "${dict['installed_version_file']}")"
    [[ "${dict['installed_version']}" == "${dict['expected_version']}" ]]
}

_koopa_is_broken_symlink() {
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        if [[ -L "$file" ]] && [[ ! -e "$file" ]]
        then
            continue
        fi
        return 1
    done
    return 0
}

_koopa_is_compressed_file() {
    local pattern string
    _koopa_assert_has_args "$#"
    pattern="$(_koopa_compress_ext_pattern)"
    for string in "$@"
    do
        [[ -f "$string" ]] || return 1
        _koopa_str_detect_regex \
            --pattern="$pattern" \
            --string="$string" \
        || return 1
    done
    return 0
}

_koopa_is_conda_env_active() {
    [[ "${CONDA_SHLVL:-1}" -gt 1 ]] && return 0
    [[ "${CONDA_DEFAULT_ENV:-base}" != 'base' ]] && return 0
    return 1
}

_koopa_is_debian_like() {
    _koopa_is_os_like 'debian'
}

_koopa_is_docker() {
    [[ "${KOOPA_IS_DOCKER:-0}" -eq 1 ]] && return 0
    [[ -f '/.dockerenv' ]] && return 0
    return 1
}

_koopa_is_doom_emacs_installed() {
    local init_file prefix
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed 'emacs' || return 1
    prefix="$(_koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    _koopa_file_detect_fixed --file="$init_file" --pattern='doom-emacs'
}

_koopa_is_empty_dir() {
    local prefix
    _koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        local out
        [[ -d "$prefix" ]] || return 1
        out="$(\
            _koopa_find \
            --empty \
            --engine='find' \
            --max-depth=0 \
            --min-depth=0 \
            --prefix="$prefix" \
            --type='d'
        )"
        [[ -n "$out" ]] || return 1
    done
    return 0
}

_koopa_is_existing_url() {
    local -A app
    local url
    _koopa_assert_has_args "$#"
    _koopa_is_url "$@" || return 1
    app['curl']="$(_koopa_locate_curl --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for url in "$@"
    do
        "${app['curl']}" \
            --disable \
            --fail \
            --head \
            --location \
            --output /dev/null \
            --silent \
            "$url" \
            || return 1
        continue
    done
    return 0
}

_koopa_is_export() {
    local arg exports
    _koopa_assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        _koopa_str_detect_regex \
            --string="$exports" \
            --pattern="\b${arg}\b=" \
        || return 1
    done
    return 0
}

_koopa_is_fedora_like() {
    _koopa_is_os_like 'fedora'
}

_koopa_is_file_system_case_sensitive() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['find']="$(_koopa_locate_find)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${PWD:?}"
    dict['tmp_stem']='.koopa.tmp.'
    dict['file1']="${dict['tmp_stem']}checkcase"
    dict['file2']="${dict['tmp_stem']}checkCase"
    _koopa_touch "${dict['file1']}" "${dict['file2']}"
    dict['count']="$( \
        "${app['find']}" \
            "${dict['prefix']}" \
            -maxdepth 1 \
            -mindepth 1 \
            -name "${dict['file1']}" \
        | "${app['wc']}" -l \
    )"
    _koopa_rm "${dict['tmp_stem']}"*
    [[ "${dict['count']}" -eq 2 ]]
}

_koopa_is_file_type() {
    local -A dict
    local -a pos
    local file
    dict['ext']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ext='*)
                dict['ext']="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict['ext']="${2:?}"
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
    _koopa_assert_is_set '--ext' "${dict['ext']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        _koopa_str_detect_regex \
            --string="$file" \
            --pattern="\.${dict['ext']}$" \
        || return 1
    done
    return 0
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

_koopa_is_git_repo_top_level() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        [[ -d "$arg" ]] || return 1
        [[ -e "${arg}/.git" ]] || return 1
    done
    return 0
}

_koopa_is_git_repo() {
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    (
        for repo in "$@"
        do
            [[ -d "$repo" ]] || return 1
            _koopa_is_git_repo_top_level "$repo" || return 1
            _koopa_cd "$repo"
            "${app['git']}" rev-parse --git-dir >/dev/null 2>&1 || return 1
        done
        return 0
    )
}

_koopa_is_github_ssh_enabled() {
    _koopa_assert_has_no_args "$#"
    _koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

_koopa_is_gitlab_ssh_enabled() {
    _koopa_assert_has_no_args "$#"
    _koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

_koopa_is_gnu() {
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local str
        _koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        _koopa_str_detect_fixed --pattern='GNU' --string="$str" || return 1
    done
    return 0
}

_koopa_is_install_subshell() {
    [[ "${KOOPA_INSTALL_APP_SUBSHELL:-0}" -eq 1 ]]
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

_koopa_is_koopa_app() {
    local app_prefix str
    _koopa_assert_has_args "$#"
    app_prefix="$(_koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        [[ -e "$str" ]] || return 1
        str="$(_koopa_realpath "$str")"
        _koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}

_koopa_is_linux() {
    [[ "$(uname -s)" == 'Linux' ]]
}

_koopa_is_lmod_active() {
    [[ -n "${LOADEDMODULES:-}" ]]
}

_koopa_is_macos() {
    [[ "$(uname -s)" == 'Darwin' ]]
}

_koopa_is_opensuse() {
    _koopa_is_os 'opensuse'
}

_koopa_is_os_like() {
    local file id
    id="${1:?}"
    _koopa_is_os "$id" && return 0
    file='/etc/os-release'
    [[ -r "$file" ]] || return 1
    if grep 'ID=' "$file" | grep -q "$id"
    then
        return 0
    fi
    if grep 'ID_LIKE=' "$file" | grep -q "$id"
    then
        return 0
    fi
    return 1
}

_koopa_is_os() {
    [[ "$(_koopa_os_id)" == "${1:?}" ]]
}

_koopa_is_owner() {
    local -A dict
    dict['prefix']="$(_koopa_koopa_prefix)"
    dict['owner_id']="$(_koopa_stat_user_id "${dict['prefix']}")"
    dict['user_id']="$(_koopa_user_id)"
    [[ "${dict['user_id']}" == "${dict['owner_id']}" ]]
}

_koopa_is_powerful_machine() {
    local cores
    _koopa_assert_has_no_args "$#"
    cores="$(_koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

_koopa_is_python_venv_active() {
    [[ -n "${VIRTUAL_ENV:-}" ]] && [[ -n "${VIRTUAL_ENV_PROMPT:-}" ]]
}

_koopa_is_r_package_installed() {
    local -A app dict
    local pkg
    _koopa_assert_has_args "$#"
    app['r']="$(_koopa_locate_r)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(_koopa_r_packages_prefix "${app['r']}")"
    for pkg in "$@"
    do
        [[ -d "${dict['prefix']}/${pkg}" ]] || return 1
    done
    return 0
}

_koopa_is_recent() {
    local -A app dict
    local file
    _koopa_assert_has_args "$#"
    app['find']="$(_koopa_locate_find)"
    _koopa_assert_is_executable "${app[@]}"
    dict['days']=14
    for file in "$@"
    do
        local exists
        [[ -e "$file" ]] || return 1
        exists="$( \
            "${app['find']}" "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${dict['days']}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
}

_koopa_is_rhel_like() {
    _koopa_is_os_like 'rhel'
}

_koopa_is_root() {
    [[ "$(_koopa_user_id)" -eq 0 ]]
}

_koopa_is_rstudio() {
    [[ -n "${RSTUDIO:-}" ]]
}

_koopa_is_set_nounset() {
    _koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

_koopa_is_shared_install() {
    ! _koopa_is_user_install
}

_koopa_is_spacemacs_installed() {
    local init_file prefix
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed 'emacs' || return 1
    prefix="$(_koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    _koopa_file_detect_fixed --file="$init_file" --pattern='Spacemacs'
}

_koopa_is_ssh_enabled() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['ssh']="$(_koopa_locate_ssh --allow-missing --allow-system)"
    [[ -x "${app['ssh']}" ]] || return 1
    dict['url']="${1:?}"
    dict['pattern']="${2:?}"
    dict['str']="$( \
        "${app['ssh']}" -T \
            -o StrictHostKeyChecking='no' \
            "${dict['url']}" 2>&1 \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_str_detect_fixed \
        --string="${dict['str']}" \
        --pattern="${dict['pattern']}"
}

_koopa_is_subshell() {
    [[ "${KOOPA_SUBSHELL:-0}" -gt 0 ]]
}

_koopa_is_symlink() {
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        if [[ -L "$file" ]] && [[ -e "$file" ]]
        then
            continue
        fi
        return 1
    done
    return 0
}

_koopa_is_tty() {
    _koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_is_ubuntu_like() {
    _koopa_is_os_like 'ubuntu'
}

_koopa_is_url() {
    local string
    _koopa_assert_has_args "$#"
    for string in "$@"
    do
        _koopa_str_detect_fixed \
            --pattern='://' \
            --string="$string" \
            || return 1
        continue
    done
    return 0
}

_koopa_is_user_install() {
    _koopa_str_detect_fixed \
       --pattern="${HOME:?}" \
       --string="$(_koopa_koopa_prefix)"
}

_koopa_is_variable_defined() {
    local -A dict
    local var
    _koopa_assert_has_args "$#"
    dict['nounset']="$(_koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for var in "$@"
    do
        local x value
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "${x:-}" ]] || return 1
        value="${!var}"
        [[ -n "${value:-}" ]] || return 1
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_is_verbose() {
    [[ "${KOOPA_VERBOSE:-0}" -eq 1 ]]
}

_koopa_linux_delete_cache() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_docker
    then
        _koopa_stop 'Cache removal only supported inside Docker images.'
    fi
    _koopa_alert 'Removing caches, logs, and temporary files.'
    _koopa_rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if _koopa_is_debian_like
    then
        _koopa_rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}

_koopa_linux_fix_sudo_setrlimit_error() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['file']='/etc/sudo.conf'
    dict['string']='Set disable_coredump false'
    _koopa_sudo_append_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}

_koopa_linux_locate_ec2_metadata() {
    local app
    if _koopa_is_ubuntu_like
    then
        app='/usr/bin/ec2metadata'
    else
        app='/usr/bin/ec2-metadata'
    fi
    _koopa_locate_app "$app" "$@"
}

_koopa_linux_locate_ldd() {
    _koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}

_koopa_locate_7z() {
    _koopa_locate_app \
        --app-name='p7zip' \
        --bin-name='7z' \
        "$@"
}

_koopa_locate_anaconda_conda() {
    _koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='conda' \
        --no-allow-koopa-bin \
        "$@"
}

_koopa_locate_anaconda_python() {
    _koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='python3' \
        --no-allow-koopa-bin \
        "$@"
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

_koopa_locate_ar() {
    _koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ar' \
        "$@"
}

_koopa_locate_ascp() {
    _koopa_locate_app \
        --app-name='aspera-connect' \
        --bin-name='ascp' \
        "$@"
}

_koopa_locate_aspell() {
    _koopa_locate_app \
        --app-name='aspell' \
        --bin-name='aspell' \
        "$@"
}

_koopa_locate_autoreconf() {
    _koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoreconf' \
        "$@"
}

_koopa_locate_autoupdate() {
    _koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoupdate' \
        "$@"
}

_koopa_locate_awk() {
    _koopa_locate_app \
        --app-name='gawk' \
        --bin-name='awk' \
        "$@"
}

_koopa_locate_aws() {
    _koopa_locate_app \
        --app-name='aws-cli' \
        --bin-name='aws' \
        "$@"
}

_koopa_locate_basename() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gbasename' \
        --system-bin-name='basename' \
        "$@"
}

_koopa_locate_bash() {
    _koopa_locate_app \
        --app-name='bash' \
        --bin-name='bash' \
        "$@"
}

_koopa_locate_bc() {
    _koopa_locate_app \
        --app-name='bc' \
        --bin-name='bc' \
        "$@"
}

_koopa_locate_bedtools() {
    _koopa_locate_app \
        --app-name='bedtools' \
        --bin-name='bedtools' \
        "$@"
}

_koopa_locate_bowtie2_build() {
    _koopa_locate_app \
        --app-name='bowtie2' \
        --bin-name='bowtie2-build' \
        "$@"
}

_koopa_locate_bowtie2() {
    _koopa_locate_app \
        --app-name='bowtie2' \
        --bin-name='bowtie2' \
        "$@"
}

_koopa_locate_brew() {
    _koopa_locate_app \
        "$(_koopa_homebrew_prefix)/bin/brew" \
        "$@"
}

_koopa_locate_brotli() {
    _koopa_locate_app \
        --app-name='brotli' \
        --bin-name='brotli' \
        "$@"
}

_koopa_locate_bundle() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='bundle' \
        "$@"
}

_koopa_locate_bunzip2() {
    _koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bunzip2' \
        "$@"
}

_koopa_locate_bzip2() {
    _koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bzip2' \
        "$@"
}

_koopa_locate_cabal() {
    _koopa_locate_app \
        --app-name='haskell-cabal' \
        --bin-name='cabal' \
        "$@"
}

_koopa_locate_cargo() {
    _koopa_locate_app \
        --app-name='rust' \
        --bin-name='cargo' \
        "$@"
}

_koopa_locate_cat() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcat' \
        --system-bin-name='cat' \
        "$@"
}

_koopa_locate_cc() {
    local str
    if _koopa_is_macos
    then
        str='/usr/bin/clang'
    else
        str='/usr/bin/gcc'
    fi
    _koopa_locate_app "$str"
}

_koopa_locate_chezmoi() {
    _koopa_locate_app \
        --app-name='chezmoi' \
        --bin-name='chezmoi' \
        "$@"
}

_koopa_locate_chgrp() {
    _koopa_locate_app \
        '/usr/bin/chgrp' \
        "$@"
}

_koopa_locate_chmod() {
    _koopa_locate_app \
        '/bin/chmod' \
        "$@"
}

_koopa_locate_chown() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/usr/sbin/chown')
    else
        args+=('/bin/chown')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_locate_clang() {
    _koopa_locate_app \
        --app-name='llvm' \
        --bin-name='clang' \
        "$@"
}

_koopa_locate_clangxx() {
    _koopa_locate_app \
        --app-name='llvm' \
        --bin-name='clang++' \
        "$@"
}

_koopa_locate_cmake() {
    _koopa_locate_app \
        --app-name='cmake' \
        --bin-name='cmake' \
        "$@"
}

_koopa_locate_compress() {
    _koopa_locate_app \
        '/usr/bin/compress' \
        "$@"
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

_koopa_locate_convmv() {
    _koopa_locate_app \
        --app-name='convmv' \
        --bin-name='convmv' \
        "$@"
}

_koopa_locate_corepack() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='corepack' \
        "$@"
}

_koopa_locate_cp() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcp' \
        --system-bin-name='cp' \
        "$@"
}

_koopa_locate_cpan() {
    _koopa_locate_app \
        --app-name='perl' \
        --bin-name='cpan' \
        "$@"
}

_koopa_locate_ctest() {
    _koopa_locate_app \
        --app-name='cmake' \
        --bin-name='ctest' \
        "$@"
}

_koopa_locate_curl() {
    _koopa_locate_app \
        --app-name='curl' \
        --bin-name='curl' \
        "$@"
}

_koopa_locate_cut() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcut' \
        --system-bin-name='cut' \
        "$@"
}

_koopa_locate_cxx() {
    local str
    if _koopa_is_macos
    then
        str='/usr/bin/clang++'
    else
        str='/usr/bin/g++'
    fi
    _koopa_locate_app "$str"
}

_koopa_locate_date() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdate' \
        --system-bin-name='date' \
        "$@"
}

_koopa_locate_df() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdf' \
        --system-bin-name='df' \
        "$@"
}

_koopa_locate_dig() {
    _koopa_locate_app \
        --app-name='bind' \
        --bin-name='dig' \
        "$@"
}

_koopa_locate_dirname() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdirname' \
        --system-bin-name='dirname' \
        "$@"
}

_koopa_locate_docker() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        if [[ -x "${HOME:?}/.docker/bin/docker" ]]
        then
            args+=("${HOME:?}/.docker/bin/docker")
        else
            args+=('/usr/local/bin/docker')
        fi
    else
        args+=('/usr/bin/docker')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_locate_doom() {
    _koopa_locate_app \
        "$(_koopa_doom_emacs_prefix)/bin/doom" \
        "$@"
}

_koopa_locate_du() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdu' \
        --system-bin-name='du' \
        "$@"
}

_koopa_locate_echo() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gecho' \
        --system-bin-name='echo' \
        "$@"
}

_koopa_locate_efetch() {
    _koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='efetch' \
        "$@"
}

_koopa_locate_emacs() {
    _koopa_locate_app \
        --app-name='emacs' \
        --bin-name='emacs' \
        "$@"
}

_koopa_locate_env() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='genv' \
        --system-bin-name='env' \
        "$@"
}

_koopa_locate_esearch() {
    _koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='esearch' \
        "$@"
}

_koopa_locate_exiftool() {
    _koopa_locate_app \
        --app-name='exiftool' \
        --bin-name='exiftool' \
        "$@"
}

_koopa_locate_fasterq_dump() {
    _koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='fasterq-dump' \
        "$@"
}

_koopa_locate_fd() {
    _koopa_locate_app \
        --app-name='fd-find' \
        --bin-name='fd' \
        "$@"
}

_koopa_locate_ffmpeg() {
    _koopa_locate_app \
        --app-name='ffmpeg' \
        --bin-name='ffmpeg' \
        "$@"
}

_koopa_locate_find() {
    _koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gfind' \
        --system-bin-name='find' \
        "$@"
}

_koopa_locate_fish() {
    _koopa_locate_app \
        --app-name='fish' \
        --bin-name='fish' \
        "$@"
}

_koopa_locate_flake8() {
    _koopa_locate_app \
        --app-name='flake8' \
        --bin-name='flake8' \
        "$@"
}

_koopa_locate_gcc() {
    _koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gcc' \
        "$@"
}

_koopa_locate_gcloud() {
    _koopa_locate_app \
        --app-name='google-cloud-sdk' \
        --bin-name='gcloud' \
        "$@"
}

_koopa_locate_gcxx() {
    _koopa_locate_app \
        --app-name='gcc' \
        --bin-name='g++' \
        "$@"
}

_koopa_locate_gdal_config() {
    _koopa_locate_app \
        --app-name='gdal' \
        --bin-name='gdal-config' \
        "$@"
}

_koopa_locate_gem() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='gem' \
        "$@"
}

_koopa_locate_geos_config() {
    _koopa_locate_app \
        --app-name='geos' \
        --bin-name='geos-config' \
        "$@"
}

_koopa_locate_gfortran() {
    if _koopa_is_macos
    then
        _koopa_locate_app \
            '/opt/gfortran/bin/gfortran' \
            "$@"
    else
        _koopa_locate_app \
            --app-name='gcc' \
            --bin-name='gfortran' \
            "$@"
    fi
}

_koopa_locate_gh() {
    _koopa_locate_app \
        --app-name='gh' \
        --bin-name='gh' \
        "$@"
}

_koopa_locate_ghcup() {
    _koopa_locate_app \
        --app-name='haskell-ghcup' \
        --bin-name='ghcup' \
        "$@"
}

_koopa_locate_git() {
    _koopa_locate_app \
        --app-name='git' \
        --bin-name='git' \
        "$@"
}

_koopa_locate_go() {
    _koopa_locate_app \
        --app-name='go' \
        --bin-name='go' \
        "$@"
}

_koopa_locate_gpg_agent() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-agent' \
        "$@"
}

_koopa_locate_gpg_connect_agent() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-connect-agent' \
        "$@"
}

_koopa_locate_gpg() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg' \
        "$@"
}

_koopa_locate_gpgconf() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpgconf' \
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

_koopa_locate_gs() {
    _koopa_locate_app \
        --app-name='ghostscript' \
        --bin-name='gs' \
        "$@"
}

_koopa_locate_gsl_config() {
    _koopa_locate_app \
        --app-name='gsl' \
        --bin-name='gsl-config' \
        "$@"
}

_koopa_locate_gunzip() {
    _koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gunzip' \
        "$@"
}

_koopa_locate_gzip() {
    _koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gzip' \
        "$@"
}

_koopa_locate_h5cc() {
    _koopa_locate_app \
        --app-name='hdf5' \
        --bin-name='h5cc' \
        "$@"
}

_koopa_locate_head() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ghead' \
        --system-bin-name='head' \
        "$@"
}

_koopa_locate_hisat2_build() {
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2-build' \
        "$@"
}

_koopa_locate_hisat2_extract_exons() {
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_exons.py' \
        "$@"
}

_koopa_locate_hisat2_extract_splice_sites() {
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_splice_sites.py' \
        "$@"
}

_koopa_locate_hisat2() {
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2' \
        "$@"
}

_koopa_locate_hostname() {
    _koopa_locate_app \
        '/bin/hostname' \
        "$@"
}

_koopa_locate_icu_config() {
    _koopa_locate_app \
        --app-name='icu4c' \
        --bin-name='icu-config' \
        "$@"
}

_koopa_locate_id() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gid' \
        --system-bin-name='id' \
        "$@"
}

_koopa_locate_install() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ginstall' \
        "$@"
}

_koopa_locate_jar() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='jar' \
        "$@"
}

_koopa_locate_java() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='java' \
        "$@"
}

_koopa_locate_javac() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='javac' \
        "$@"
}

_koopa_locate_jq() {
    _koopa_locate_app \
        --app-name='jq' \
        --bin-name='jq' \
        "$@"
}

_koopa_locate_julia() {
    _koopa_locate_app \
        --app-name='julia' \
        --bin-name='julia' \
        "$@"
}

_koopa_locate_kallisto() {
    _koopa_locate_app \
        --app-name='kallisto' \
        --bin-name='kallisto' \
        "$@"
}

_koopa_locate_koopa() {
    _koopa_locate_app \
        "$(_koopa_koopa_prefix)/bin/koopa" \
        "$@"
}

_koopa_locate_ld() {
    _koopa_locate_app \
        '/usr/bin/ld' \
        "$@"
}

_koopa_locate_less() {
    _koopa_locate_app \
        --app-name='less' \
        --bin-name='less' \
        "$@"
}

_koopa_locate_lesspipe() {
    _koopa_locate_app \
        --app-name='lesspipe' \
        --bin-name='lesspipe.sh' \
        "$@"
}

_koopa_locate_lfs() {
    _koopa_locate_app \
        '/usr/bin/lfs' \
        "$@"
}

_koopa_locate_libtool() {
    _koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtool' \
        --system-bin-name='libtool' \
        "$@"
}

_koopa_locate_libtoolize() {
    _koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtoolize' \
        "$@"
}

_koopa_locate_ln() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gln' \
        --system-bin-name='ln' \
        "$@"
}

_koopa_locate_locale() {
    _koopa_locate_app \
        '/usr/bin/locale' \
        "$@"
}

_koopa_locate_localedef() {
    if _koopa_is_alpine
    then
        _koopa_alpine_locate_localedef "$@"
    else
        _koopa_locate_app \
            '/usr/bin/localedef' \
            "$@"
    fi
}

_koopa_locate_lpr() {
    _koopa_locate_app \
        '/usr/bin/lpr' \
        "$@"
}

_koopa_locate_ls() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gls' \
        --system-bin-name='ls' \
        "$@"
}

_koopa_locate_lua() {
    _koopa_locate_app \
        --app-name='lua' \
        --bin-name='lua' \
        "$@"
}

_koopa_locate_luac() {
    _koopa_locate_app \
        --app-name='lua' \
        --bin-name='luac' \
        "$@"
}

_koopa_locate_luajit() {
    _koopa_locate_app \
        --app-name='luajit' \
        --bin-name='luajit' \
        "$@"
}

_koopa_locate_luarocks() {
    _koopa_locate_app \
        --app-name='luarocks' \
        --bin-name='luarocks' \
        "$@"
}

_koopa_locate_lz4() {
    _koopa_locate_app \
        --app-name='lz4' \
        --bin-name='lz4' \
        "$@"
}

_koopa_locate_lzip() {
    _koopa_locate_app \
        --app-name='lzip' \
        --bin-name='lzip' \
        "$@"
}

_koopa_locate_lzma() {
    _koopa_locate_app \
        --app-name='xz' \
        --bin-name='lzma' \
        "$@"
}

_koopa_locate_magick_core_config() {
    _koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='MagickCore-config' \
        "$@"
}

_koopa_locate_magick() {
    _koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='magick' \
        "$@"
}

_koopa_locate_make() {
    _koopa_locate_app \
        --app-name='make' \
        --bin-name='gmake' \
        --system-bin-name='make' \
        "$@"
}

_koopa_locate_mamba() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='mamba' \
        "$@"
}

_koopa_locate_man() {
    _koopa_locate_app \
        --app-name='man-db' \
        --bin-name='gman' \
        --system-bin-name='man' \
        "$@"
}

_koopa_locate_md5sum() {
    local system_bin_name
    if _koopa_is_macos
    then
        system_bin_name='md5'
    else
        system_bin_name='md5sum'
    fi
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmd5sum' \
        --system-bin-name="$system_bin_name" \
        "$@"
}

_koopa_locate_meson() {
    _koopa_locate_app \
        --app-name='meson' \
        --bin-name='meson' \
        "$@"
}

_koopa_locate_minimap2() {
    _koopa_locate_app \
        --app-name='minimap2' \
        --bin-name='minimap2' \
        "$@"
}

_koopa_locate_miso_exon_utils() {
    _koopa_locate_app \
        --app-name='misopy' \
        --bin-name='exon_utils' \
        "$@"
}

_koopa_locate_miso_index_gff() {
    _koopa_locate_app \
        --app-name='misopy' \
        --bin-name='index_gff' \
        "$@"
}

_koopa_locate_miso_pe_utils() {
    _koopa_locate_app \
        --app-name='misopy' \
        --bin-name='pe_utils' \
        "$@"
}

_koopa_locate_miso() {
    _koopa_locate_app \
        --app-name='misopy' \
        --bin-name='miso' \
        "$@"
}

_koopa_locate_mkdir() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmkdir' \
        --system-bin-name='mkdir' \
        "$@"
}

_koopa_locate_mktemp() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmktemp' \
        --system-bin-name='mktemp' \
        "$@"
}

_koopa_locate_mount_s3() {
    _koopa_locate_app \
        '/usr/bin/mount-s3' \
        "$@"
}

_koopa_locate_msgfmt() {
    _koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgfmt' \
        "$@"
}

_koopa_locate_msgmerge() {
    _koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgmerge' \
        "$@"
}

_koopa_locate_mv() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmv' \
        --system-bin-name='mv' \
        "$@"
}

_koopa_locate_neofetch() {
    _koopa_locate_app \
        --app-name='neofetch' \
        --bin-name='neofetch' \
        "$@"
}

_koopa_locate_newgrp() {
    _koopa_locate_app \
        '/usr/bin/newgrp' \
        "$@"
}

_koopa_locate_nim() {
    _koopa_locate_app \
        --app-name='nim' \
        --bin-name='nim' \
        "$@"
}

_koopa_locate_nimble() {
    _koopa_locate_app \
        --app-name='nim' \
        --bin-name='nimble' \
        "$@"
}

_koopa_locate_ninja() {
    _koopa_locate_app \
        --app-name='ninja' \
        --bin-name='ninja' \
        "$@"
}

_koopa_locate_node() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='node' \
        "$@"
}

_koopa_locate_npm() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='npm' \
        "$@"
}

_koopa_locate_nproc() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnproc' \
        --system-bin-name='nproc' \
        "$@"
}

_koopa_locate_numfmt() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnumfmt' \
        --system-bin-name='numfmt' \
        "$@"
}

_koopa_locate_od() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='god' \
        --system-bin-name='od' \
        "$@"
}

_koopa_locate_open() {
    _koopa_locate_app \
        '/usr/bin/open' \
        "$@"
}

_koopa_locate_openssl() {
    _koopa_locate_app \
        --app-name='openssl' \
        --bin-name='openssl' \
        "$@"
}

_koopa_locate_parallel() {
    _koopa_locate_app \
        --app-name='parallel' \
        --bin-name='parallel' \
        "$@"
}

_koopa_locate_passwd() {
    _koopa_locate_app \
        '/usr/bin/passwd' \
        "$@"
}

_koopa_locate_paste() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gpaste' \
        --system-bin-name='paste' \
        "$@"
}

_koopa_locate_patch() {
    _koopa_locate_app \
        --app-name='patch' \
        --bin-name='patch' \
        "$@"
}

_koopa_locate_pbzip2() {
    _koopa_locate_app \
        --app-name='pbzip2' \
        --bin-name='pbzip2' \
        "$@"
}

_koopa_locate_pcre2_config() {
    _koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2-config' \
        "$@"
}

_koopa_locate_pcregrep() {
    _koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2grep' \
        "$@"
}

_koopa_locate_perl() {
    _koopa_locate_app \
        --app-name='perl' \
        --bin-name='perl' \
        "$@"
}

_koopa_locate_pigz() {
    _koopa_locate_app \
        --app-name='pigz' \
        --bin-name='pigz' \
        "$@"
}

_koopa_locate_pkg_config() {
    _koopa_locate_app \
        --app-name='pkg-config' \
        --bin-name='pkg-config' \
        "$@"
}

_koopa_locate_prettier() {
    _koopa_locate_app \
        --app-name='prettier' \
        --bin-name='prettier' \
        "$@"
}

_koopa_locate_proj() {
    _koopa_locate_app \
        --app-name='proj' \
        --bin-name='proj' \
        "$@"
}

_koopa_locate_pup() {
    _koopa_locate_app \
        --app-name='pup' \
        --bin-name='pup' \
        "$@"
}

_koopa_locate_pyenv() {
    _koopa_locate_app \
        --app-name='pyenv' \
        --bin-name='pyenv' \
        "$@"
}

_koopa_locate_pylint() {
    _koopa_locate_app \
        --app-name='pylint' \
        --bin-name='pylint' \
        "$@"
}

_koopa_locate_pytest() {
    _koopa_locate_app \
        --app-name='pytest' \
        --bin-name='pytest' \
        "$@"
}

_koopa_locate_python() {
    local -A dict
    dict['python_version']="$(_koopa_python_major_minor_version)"
    _koopa_locate_app \
        --app-name="python${dict['python_version']}" \
        --bin-name="python${dict['python_version']}" \
        --system-bin-name='python3' \
        "$@"
}

_koopa_locate_python310() {
    _koopa_locate_app \
        --app-name='python3.10' \
        --bin-name='python3.10' \
        "$@"
}

_koopa_locate_python311() {
    _koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}

_koopa_locate_python312() {
    _koopa_locate_app \
        --app-name='python3.12' \
        --bin-name='python3.12' \
        "$@"
}

_koopa_locate_python313() {
    _koopa_locate_app \
        --app-name='python3.13' \
        --bin-name='python3.13' \
        "$@"
}

_koopa_locate_python314() {
    _koopa_locate_app \
        --app-name='python3.14' \
        --bin-name='python3.14' \
        "$@"
}

_koopa_locate_r() {
    _koopa_locate_app \
        --app-name='r' \
        --bin-name='R' \
        "$@"
}

_koopa_locate_ranlib() {
    _koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ranlib' \
        "$@"
}

_koopa_locate_rbenv() {
    _koopa_locate_app \
        --app-name='rbenv' \
        --bin-name='rbenv' \
        "$@"
}

_koopa_locate_readlink() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='greadlink' \
        --system-bin-name='readlink' \
        "$@"
}

_koopa_locate_realpath() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grealpath' \
        --system-bin-name='realpath' \
        "$@"
}

_koopa_locate_rename() {
    _koopa_locate_app \
        --app-name='rename' \
        --bin-name='rename' \
        "$@"
}

_koopa_locate_rev() {
    _koopa_locate_app \
        '/usr/bin/rev' \
        "$@"
}

_koopa_locate_rg() {
    _koopa_locate_app \
        --app-name='ripgrep' \
        --bin-name='rg' \
        "$@"
}

_koopa_locate_rm() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grm' \
        --system-bin-name='rm' \
        "$@"
}

_koopa_locate_rmats() {
    _koopa_locate_app \
        --app-name='rmats' \
        --bin-name='rmats' \
        "$@"
}

_koopa_locate_ronn() {
    _koopa_locate_app \
        --app-name='ronn-ng' \
        --bin-name='ronn' \
        "$@"
}

_koopa_locate_rscript() {
    _koopa_locate_app \
        --app-name='r' \
        --bin-name='Rscript' \
        "$@"
}

_koopa_locate_rsem_calculate_expression() {
    _koopa_locate_app \
        --app-name='rsem' \
        --bin-name='rsem-calcualte-expression' \
        "$@"
}

_koopa_locate_rsem_prepare_reference() {
    _koopa_locate_app \
        --app-name='rsem' \
        --bin-name='rsem-prepare-reference' \
        "$@"
}

_koopa_locate_rsync() {
    _koopa_locate_app \
        --app-name='rsync' \
        --bin-name='rsync' \
        "$@"
}

_koopa_locate_ruby() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='ruby' \
        "$@"
}

_koopa_locate_rustc() {
    _koopa_locate_app \
        --app-name='rust' \
        --bin-name='rustc' \
        "$@"
}

_koopa_locate_salmon() {
    _koopa_locate_app \
        --app-name='salmon' \
        --bin-name='salmon' \
        "$@"
}

_koopa_locate_sam_dump() {
    _koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='sam-dump' \
        "$@"
}

_koopa_locate_sambamba() {
    _koopa_locate_app \
        --app-name='sambamba' \
        --bin-name='sambamba' \
        "$@"
}

_koopa_locate_samtools() {
    _koopa_locate_app \
        --app-name='samtools' \
        --bin-name='samtools' \
        "$@"
}

_koopa_locate_scons() {
    _koopa_locate_app \
        --app-name='scons' \
        --bin-name='scons' \
        "$@"
}

_koopa_locate_scp() {
    local -a args
    if _koopa_is_macos
    then
        args+=('/usr/bin/scp')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=scp'
        )
    fi
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_locate_sed() {
    _koopa_locate_app \
        --app-name='sed' \
        --bin-name='gsed' \
        --system-bin-name='sed' \
        "$@"
}

_koopa_locate_sh() {
    _koopa_locate_app \
        '/bin/sh' \
        "$@"
}

_koopa_locate_shellcheck() {
    _koopa_locate_app \
        --app-name='shellcheck' \
        --bin-name='shellcheck' \
        "$@"
}

_koopa_locate_shunit2() {
    _koopa_locate_app \
        --app-name='shunit2' \
        --bin-name='shunit2' \
        "$@"
}

_koopa_locate_sort() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gsort' \
        --system-bin-name='sort' \
        "$@"
}

_koopa_locate_sox() {
    _koopa_locate_app \
        --app-name='sox' \
        --bin-name='sox' \
        "$@"
}

_koopa_locate_sra_prefetch() {
    _koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='prefetch' \
        "$@"
}

_koopa_locate_ssh_add() {
    _koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-add' \
        "$@"
}

_koopa_locate_ssh_keygen() {
    _koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-keygen' \
        "$@"
}

_koopa_locate_ssh() {
    _koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh' \
        "$@"
}

_koopa_locate_stack() {
    _koopa_locate_app \
        --app-name='haskell-stack' \
        --bin-name='stack' \
        "$@"
}

_koopa_locate_star() {
    _koopa_locate_app \
        --app-name='star' \
        --bin-name='STAR' \
        "$@"
}

_koopa_locate_stat() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gstat' \
        --system-bin-name='stat' \
        "$@"
}

_koopa_locate_strip() {
    _koopa_locate_app \
        '/usr/bin/strip' \
        "$@"
}

_koopa_locate_sudo() {
    _koopa_locate_app \
        '/usr/bin/sudo' \
        "$@"
}

_koopa_locate_svn() {
    _koopa_locate_app \
        --app-name='subversion' \
        --bin-name='svn' \
        "$@"
}

_koopa_locate_swift() {
    _koopa_locate_app \
        '/usr/bin/swift' \
        "$@"
}

_koopa_locate_swig() {
    _koopa_locate_app \
        --app-name='swig' \
        --bin-name='swig' \
        "$@"
}

_koopa_locate_system_python() {
    _koopa_locate_app \
        --only-system \
        --system-bin-name='python3' \
        "$@"
}

_koopa_locate_system_r() {
    local cmd
    if _koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/R'
    else
        cmd='/usr/bin/R'
    fi
    _koopa_locate_app "$cmd"
}

_koopa_locate_system_rscript() {
    local cmd
    if _koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/Rscript'
    else
        cmd='/usr/bin/Rscript'
    fi
    _koopa_locate_app "$cmd"
}

_koopa_locate_tac() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtac' \
        --system-bin-name='tac' \
        "$@"
}

_koopa_locate_tail() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtail' \
        --system-bin-name='tail' \
        "$@"
}

_koopa_locate_tar() {
    _koopa_locate_app \
        --app-name='tar' \
        --bin-name='gtar' \
        --system-bin-name='tar' \
        "$@"
}

_koopa_locate_tee() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtee' \
        --system-bin-name='tee' \
        "$@"
}

_koopa_locate_tex() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tex')
    else
        args+=('/usr/bin/tex')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_locate_texi2dvi() {
    _koopa_locate_app \
        --app-name='texinfo' \
        --bin-name='texi2dvi' \
        "$@"
}

_koopa_locate_tlmgr() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tlmgr')
    else
        args+=('/usr/bin/tlmgr')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_locate_touch() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtouch' \
        --system-bin-name='touch' \
        "$@"
}

_koopa_locate_tr() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtr' \
        --system-bin-name='tr' \
        "$@"
}

_koopa_locate_umount() {
    _koopa_locate_app \
        '/usr/bin/umount' \
        "$@"
}

_koopa_locate_uname() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guname' \
        --system-bin-name='uname' \
        "$@"
}

_koopa_locate_uncompress() {
    _koopa_locate_app \
        '/usr/bin/uncompress' \
        "$@"
}

_koopa_locate_uniq() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guniq' \
        --system-bin-name='uniq' \
        "$@"
}

_koopa_locate_unzip() {
    _koopa_locate_app \
        --app-name='unzip' \
        --bin-name='unzip' \
        --system-bin-name='unzip' \
        "$@"
}

_koopa_locate_uv() {
    _koopa_locate_app \
        --app-name='uv' \
        --bin-name='uv' \
        "$@"
}

_koopa_locate_vim() {
    _koopa_locate_app \
        --app-name='vim' \
        --bin-name='vim' \
        "$@"
}

_koopa_locate_wc() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwc' \
        --system-bin-name='wc' \
        "$@"
}

_koopa_locate_wget() {
    _koopa_locate_app \
        --app-name='wget' \
        --bin-name='wget' \
        "$@"
}

_koopa_locate_whoami() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwhoami' \
        --system-bin-name='whoami' \
        "$@"
}

_koopa_locate_xargs() {
    _koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gxargs' \
        --system-bin-name='xargs' \
        "$@"
}

_koopa_locate_xz() {
    _koopa_locate_app \
        --app-name='xz' \
        --bin-name='xz' \
        "$@"
}

_koopa_locate_yacc() {
    _koopa_locate_app \
        --app-name='bison' \
        --bin-name='yacc' \
        "$@"
}

_koopa_locate_yes() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gyes' \
        --system-bin-name='yes' \
        "$@"
}

_koopa_locate_yq() {
    _koopa_locate_app \
        --app-name='yq' \
        --bin-name='yq' \
        "$@"
}

_koopa_locate_yt_dlp() {
    _koopa_locate_app \
        --app-name='yt-dlp' \
        --bin-name='yt-dlp' \
        "$@"
}

_koopa_locate_zcat() {
    _koopa_locate_app \
        --app-name='gzip' \
        --bin-name='zcat' \
        "$@"
}

_koopa_locate_zip() {
    _koopa_locate_app \
        --app-name='zip' \
        --bin-name='zip' \
        --system-bin-name='zip' \
        "$@"
}

_koopa_locate_zstd() {
    _koopa_locate_app \
        --app-name='zstd' \
        --bin-name='zstd' \
        "$@"
}

_koopa_macos_clean_launch_services() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['lsregister']="$(_koopa_macos_locate_lsregister)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app['lsregister']}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['lsregister']}" \
        -kill \
        -lint \
        -seed \
        -f \
        -r \
        -v \
        -dump \
        -domain 'local' \
        -domain 'network' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['kill_all']}" 'Finder'
    _koopa_sudo "${app['kill_all']}" 'Dock'
    _koopa_alert_success 'Clean up was successful.'
    return 0
}

_koopa_macos_create_dmg() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['hdiutil']="$(_koopa_macos_locate_hdiutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['srcfolder']="${1:?}"
    _koopa_assert_is_dir "${dict['srcfolder']}"
    dict['srcfolder']="$(_koopa_realpath "${dict['srcfolder']}")"
    dict['volname']="$(_koopa_basename "${dict['volname']}")"
    dict['ov']="${dict['volname']}.dmg"
    "${app['hdiutil']}" create \
        -ov "${dict['ov']}" \
        -srcfolder "${dict['srcfolder']}" \
        -volname "${dict['volname']}"
    return 0
}

_koopa_macos_disable_touch_id_sudo() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        ! _koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        _koopa_alert_note "Touch ID not enabled in '${dict['file']}'."
        return 0
    fi
    _koopa_alert "Disabling Touch ID defined in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    _koopa_chmod --sudo '0444' "${dict['file']}"
    _koopa_alert_success 'Touch ID disabled for sudo.'
    return 0
}

_koopa_macos_enable_touch_id_sudo() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        _koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        _koopa_alert_note "Touch ID already enabled in '${dict['file']}'."
        return 0
    fi
    app['chflags']="$(_koopa_macos_locate_chflags)"
    app['sudo']="$(_koopa_locate_sudo)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert "Enabling Touch ID in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    "${app['sudo']}" "${app['chflags']}" noschg "${dict['file']}"
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    _koopa_chmod --sudo '0444' "${dict['file']}"
    "${app['sudo']}" "${app['chflags']}" schg "${dict['file']}"
    _koopa_alert_success 'Touch ID enabled for sudo.'
    return 0
}

_koopa_macos_flush_dns() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dscacheutil']="$(_koopa_macos_locate_dscacheutil)"
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Flushing DNS.'
    _koopa_sudo "${app['dscacheutil']}" -flushcache
    _koopa_sudo "${app['kill_all']}" -HUP 'mDNSResponder'
    _koopa_alert_success 'DNS flush was successful.'
    return 0
}

_koopa_macos_force_eject() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    _koopa_assert_is_admin
    app['diskutil']="$(_koopa_macos_locate_diskutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['mount']="/Volumes/${dict['name']}"
    _koopa_assert_is_dir "${dict['mount']}"
    _koopa_sudo "${app['diskutil']}" unmount force "${dict['mount']}"
    return 0
}

_koopa_macos_ifactive() {
    local -A app
    local str
    app['ifconfig']="$(_koopa_macos_locate_ifconfig)"
    app['pcregrep']="$(_koopa_locate_pcregrep)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['ifconfig']}" \
            | "${app['pcregrep']}" -M -o \
                '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_macos_list_launch_agents() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['ls']="$(_koopa_locate_ls)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['ls']}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

_koopa_macos_locate_automount() {
    _koopa_locate_app \
        '/usr/sbin/automount' \
        "$@"
}

_koopa_macos_locate_chflags() {
    _koopa_locate_app \
        '/usr/bin/chflags' \
        "$@"
}

_koopa_macos_locate_diskutil() {
    _koopa_locate_app \
        '/usr/sbin/diskutil' \
        "$@"
}

_koopa_macos_locate_dot_clean() {
    _koopa_locate_app \
        '/usr/sbin/dot_clean' \
        "$@"
}

_koopa_macos_locate_dscacheutil() {
    _koopa_locate_app \
        '/usr/bin/dscacheutil' \
        "$@"
}

_koopa_macos_locate_hdiutil() {
    _koopa_locate_app \
        '/usr/bin/hdiutil' \
        "$@"
}

_koopa_macos_locate_ifconfig() {
    _koopa_locate_app \
        '/sbin/ifconfig' \
        "$@"
}

_koopa_macos_locate_kill_all() {
    _koopa_locate_app \
        '/usr/bin/killAll' \
        "$@"
}

_koopa_macos_locate_lsregister() {
    _koopa_locate_app \
        "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister" \
        "$@"
}

_koopa_macos_locate_otool() {
    _koopa_locate_app \
        '/usr/bin/otool' \
        "$@"
}

_koopa_macos_locate_sysctl() {
    _koopa_locate_app \
        '/usr/sbin/sysctl' \
        "$@"
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

_koopa_macos_os_version() {
    local str
    str="$(/usr/bin/sw_vers -productVersion)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_macos_reload_autofs() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['automount']="$(_koopa_macos_locate_automount)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['automount']}" -vc
    return 0
}

_koopa_macos_sdk_prefix() {
    _koopa_print '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
    return 0
}

_koopa_macos_spotlight_find() {
    local pattern x
    _koopa_assert_has_args_le "$#" 2
    _koopa_assert_is_installed 'mdfind'
    pattern="${1:?}"
    dir="${2:-.}"
    _koopa_assert_is_dir "$dir"
    x="$( \
        mdfind \
            -name "$pattern" \
            -onlyin "$dir" \
    )"
    [[ -n "$x" ]] || return 1
    _koopa_print "$x"
    return 0
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

_koopa_print_ansi() {
    local color nocolor str
    color="$(_koopa_ansi_escape "${1:?}")"
    nocolor="$(_koopa_ansi_escape 'nocolor')"
    shift 1
    for str in "$@"
    do
        printf '%s%b%s\n' "$color" "$str" "$nocolor"
    done
    return 0
}

_koopa_print_black_bold() {
    _koopa_print_ansi 'black-bold' "$@"
    return 0
}

_koopa_print_black() {
    _koopa_print_ansi 'black' "$@"
    return 0
}

_koopa_print_blue_bold() {
    _koopa_print_ansi 'blue-bold' "$@"
    return 0
}

_koopa_print_blue() {
    _koopa_print_ansi 'blue' "$@"
    return 0
}

_koopa_print_cyan_bold() {
    _koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

_koopa_print_cyan() {
    _koopa_print_ansi 'cyan' "$@"
    return 0
}

_koopa_print_default_bold() {
    _koopa_print_ansi 'default-bold' "$@"
    return 0
}

_koopa_print_default() {
    _koopa_print_ansi 'default' "$@"
    return 0
}

_koopa_print_env() {
    export -p
    return 0
}

_koopa_print_green_bold() {
    _koopa_print_ansi 'green-bold' "$@"
    return 0
}

_koopa_print_green() {
    _koopa_print_ansi 'green' "$@"
    return 0
}

_koopa_print_magenta_bold() {
    _koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

_koopa_print_magenta() {
    _koopa_print_ansi 'magenta' "$@"
    return 0
}

_koopa_print_red_bold() {
    _koopa_print_ansi 'red-bold' "$@"
    return 0
}

_koopa_print_red() {
    _koopa_print_ansi 'red' "$@"
    return 0
}

_koopa_print_white_bold() {
    _koopa_print_ansi 'white-bold' "$@"
    return 0
}

_koopa_print_white() {
    _koopa_print_ansi 'white' "$@"
    return 0
}

_koopa_print_yellow_bold() {
    _koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

_koopa_print_yellow() {
    _koopa_print_ansi 'yellow' "$@"
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

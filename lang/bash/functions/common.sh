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

_koopa_activate_app_conda_env() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['app_name']="${1:?}"
    dict['prefix']="$(_koopa_app_prefix "${dict['app_name']}")"
    dict['libexec']="${dict['prefix']}/libexec"
    _koopa_assert_is_dir "${dict['libexec']}"
    _koopa_alert "Activating conda environment at '${dict['libexec']}'."
    _koopa_conda_activate_env "${dict['libexec']}"
    return 0
}

_koopa_activate_app() {
    local -A app dict
    local -a pos
    local app_name
    _koopa_assert_has_args "$#"
    app['pkg_config']="$(_koopa_locate_pkg_config --allow-missing)"
    dict['build_only']=0
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--build-only')
                dict['build_only']=1
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
    _koopa_assert_has_args "$#"
    CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}"
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    LDLIBS="${LDLIBS:-}"
    LIBRARY_PATH="${LIBRARY_PATH:-}"
    PATH="${PATH:-}"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app_name in "$@"
    do
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['prefix']="${dict['opt_prefix']}/${dict2['app_name']}"
        _koopa_assert_is_dir "${dict2['prefix']}"
        dict2['current_ver']="$(_koopa_app_version "${dict2['app_name']}")"
        dict2['expected_ver']="$(_koopa_app_json_version "${dict2['app_name']}")"
        if [[ "${#dict2['expected_ver']}" -eq 40 ]]
        then
            dict2['expected_ver']="${dict2['expected_ver']:0:7}"
        fi
        if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
        then
            _koopa_alert_note "'${dict2['app_name']}' version mismatch \
(${dict2['current_ver']} != ${dict2['expected_ver']}). \
Reinstalling to update."
            _koopa_cli_install --reinstall "${dict2['app_name']}" || \
                _koopa_stop "Failed to reinstall '${dict2['app_name']}'."
            dict2['current_ver']="$( \
                _koopa_app_version "${dict2['app_name']}" \
            )"
            if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
            then
                _koopa_stop "'${dict2['app_name']}' version mismatch \
persists after reinstall at '${dict2['prefix']}' \
(${dict2['current_ver']} != ${dict2['expected_ver']})."
            fi
        fi
        if _koopa_is_empty_dir "${dict2['prefix']}"
        then
            _koopa_stop "'${dict2['prefix']}' is empty."
        fi
        dict2['prefix']="$(_koopa_realpath "${dict2['prefix']}")"
        if [[ "${dict['build_only']}" -eq 1 ]]
        then
            _koopa_alert "Activating '${dict2['prefix']}' (build only)."
        else
            _koopa_alert "Activating '${dict2['prefix']}'."
        fi
        _koopa_add_to_path_start "${dict2['prefix']}/bin"
        readarray -t pkgconfig_dirs <<< "$( \
            _koopa_find \
                --pattern='pkgconfig' \
                --prefix="${dict2['prefix']}" \
                --sort \
                --type='d' \
            || true \
        )"
        if _koopa_is_array_non_empty "${pkgconfig_dirs[@]:-}"
        then
            _koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict['build_only']}" -eq 1 ]] && continue
        if _koopa_is_array_non_empty "${pkgconfig_dirs[@]:-}"
        then
            if [[ ! -x "${app['pkg_config']}" ]]
            then
                _koopa_stop "'pkg-config' is not installed."
            fi
            local -a pc_files
            readarray -t pc_files <<< "$( \
                _koopa_find \
                    --prefix="${dict2['prefix']}" \
                    --type='f' \
                    --pattern='*.pc' \
                    --sort \
            )"
            dict2['cflags']="$( \
                "${app['pkg_config']}" --cflags "${pc_files[@]}" \
            )"
            dict2['ldflags']="$( \
                "${app['pkg_config']}" --libs-only-L "${pc_files[@]}" \
            )"
            dict2['ldlibs']="$( \
                "${app['pkg_config']}" --libs-only-l "${pc_files[@]}" \
            )"
            if [[ -n "${dict2['cflags']}" ]]
            then
                CPPFLAGS="${CPPFLAGS} ${dict2['cflags']}"
            fi
            if [[ -n "${dict2['ldflags']}" ]]
            then
                LDFLAGS="${LDFLAGS} ${dict2['ldflags']}"
            fi
            if [[ -n "${dict2['ldlibs']}" ]]
            then
                LDLIBS="${LDLIBS} ${dict2['ldlibs']}"
            fi
        else
            if [[ -d "${dict2['prefix']}/include" ]]
            then
                CPPFLAGS="${CPPFLAGS} -I${dict2['prefix']}/include"
            fi
            if [[ -d "${dict2['prefix']}/lib" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib"
            fi
            if [[ -d "${dict2['prefix']}/lib64" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib64"
            fi
        fi
        if [[ -d "${dict2['prefix']}/lib" ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib" \
            )"
        fi
        if [[ -d "${dict2['prefix']}/lib64" ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib64" \
            )"
        fi
        _koopa_add_rpath_to_ldflags \
            "${dict2['prefix']}/lib" \
            "${dict2['prefix']}/lib64"
        if [[ -d "${dict2['prefix']}/lib/cmake" ]]
        then
            CMAKE_PREFIX_PATH="${dict2['prefix']};${CMAKE_PREFIX_PATH}"
        fi
    done
    if [[ -n "$LIBRARY_PATH" ]]
    then
        if [[ -d '/usr/lib64' ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib64' \
            )"
        fi
        if [[ -d '/usr/lib' ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib' \
            )"
        fi
    fi
    if [[ -n "$CMAKE_PREFIX_PATH" ]]
    then
        CMAKE_PREFIX_PATH="$( \
            _koopa_str_unique_by_semicolon "$CMAKE_PREFIX_PATH" \
        )"
        export CMAKE_PREFIX_PATH
    else
        unset -v CMAKE_PREFIX_PATH
    fi
    if [[ -n "$CPPFLAGS" ]]
    then
        CPPFLAGS="$(_koopa_str_unique_by_space "$CPPFLAGS")"
        export CPPFLAGS
    else
        unset -v CPPFLAGS
    fi
    if [[ -n "$LDFLAGS" ]]
    then
        LDFLAGS="$(_koopa_str_unique_by_space "$LDFLAGS")"
        export LDFLAGS
    else
        unset -v LDFLAGS
    fi
    if [[ -n "$LDLIBS" ]]
    then
        LDLIBS="$(_koopa_str_unique_by_space "$LDLIBS")"
        export LDLIBS
    else
        unset -v LDLIBS
    fi
    if [[ -n "$LIBRARY_PATH" ]]
    then
        LIBRARY_PATH="$(_koopa_str_unique_by_colon "$LIBRARY_PATH")"
        export LIBRARY_PATH
    else
        unset -v LIBRARY_PATH
    fi
    if [[ -n "$PATH" ]]
    then
        PATH="$(_koopa_str_unique_by_colon "$PATH")"
        export PATH
    else
        unset -v PATH
    fi
    if [[ -n "$PKG_CONFIG_PATH" ]]
    then
        PKG_CONFIG_PATH="$(_koopa_str_unique_by_colon "$PKG_CONFIG_PATH")"
        export PKG_CONFIG_PATH
    else
        unset -v PKG_CONFIG_PATH
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
    _koopa_is_alias 'asdf' && unalias 'asdf'
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
    _koopa_is_alias 'ln' && unalias 'ln'
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
    _koopa_is_alias 'br' && unalias 'br'
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
    _koopa_is_alias 'conda' && unalias 'conda'
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
    _koopa_is_alias 'ln' && unalias 'ln'
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
    _koopa_is_alias 'ln' && unalias 'ln'
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
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
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
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
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
    _koopa_is_alias 'rbenv' && unalias 'rbenv'
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
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
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
    _koopa_is_alias 'z' && unalias 'z'
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
    dict['_koopa_prefix']="${1:-}"
    dict['make_prefix']='/usr/local'
    if [[ -z "${dict['_koopa_prefix']}" ]]
    then
        dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    fi
    dict['source_link']="${dict['_koopa_prefix']}/bin/koopa"
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

_koopa_add_to_user_profile() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['file']="$(_koopa_find_user_profile)"
    _koopa_alert "Adding koopa activation to '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() {
    __kvar_xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$__kvar_xdg_config_home" ]
    then
        __kvar_xdg_config_home="\${HOME:?}/.config"
    fi
    __kvar_script="\${__kvar_xdg_config_home}/koopa/activate"
    if [ -r "\$__kvar_script" ]
    then
        . "\$__kvar_script"
    fi
    unset -v __kvar_script __kvar_xdg_config_home
    return 0
}

__koopa_activate_user_profile
END
    _koopa_append_string \
        --file="${dict['file']}" \
        --string="\n${dict['string']}"
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

_koopa_assert_are_identical() {
    _koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" != "${2:?}" ]]
    then
        _koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}

_koopa_assert_are_not_identical() {
    _koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" == "${2:?}" ]]
    then
        _koopa_stop "'${1}' is identical to '${2}'."
    fi
    return 0
}

_koopa_assert_can_install_binary() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_can_install_binary
    then
        _koopa_stop 'No binary file access.'
    fi
    return 0
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

_koopa_assert_has_file_ext() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_has_file_ext "$arg"
        then
            _koopa_stop "No file extension: '${arg}'."
        fi
    done
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

_koopa_assert_has_private_access() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_has_private_access
    then
        _koopa_stop 'User does not have access to koopa private S3 bucket.'
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

_koopa_assert_is_amd64() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_amd64
    then
        _koopa_stop 'Architecture is not AMD 64-bit (amd64, x86_64).'
    fi
    return 0
}

_koopa_assert_is_arm64() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_arm64
    then
        _koopa_stop 'Architecture is not ARM 64-bit (arm64, aarch64).'
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

_koopa_assert_is_compressed_file() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_compressed_file "$arg"
        then
            _koopa_stop "Not a compressed file: '${arg}'."
        fi
    done
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

_koopa_assert_is_existing_aws_s3_uri() {
    local -A dict
    local -a pos
    local arg
    _koopa_assert_has_args "$#"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
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
    for arg in "$@"
    do
        if ! _koopa_is_existing_aws_s3_uri \
            --profile="${dict['profile']}" \
            "$arg"
        then
            _koopa_stop "Not AWS S3 URI: '${arg}'."
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

_koopa_assert_is_function() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_function "$arg"
        then
            _koopa_stop "Not function: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_git_repo() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_git_repo "$arg"
        then
            _koopa_stop "Not a Git repo: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_github_ssh_enabled() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_github_ssh_enabled
    then
        _koopa_stop 'GitHub SSH access is not configured correctly.'
    fi
    return 0
}

_koopa_assert_is_gitlab_ssh_enabled() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_gitlab_ssh_enabled
    then
        _koopa_stop 'GitLab SSH access is not configured correctly.'
    fi
    return 0
}

_koopa_assert_is_gnu() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_gnu "$arg"
        then
            _koopa_stop "GNU ${arg} is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_install_subshell() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_install_subshell
    then
        _koopa_stop 'Unsupported command.'
    fi
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

_koopa_assert_is_interactive() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_interactive
    then
        _koopa_stop 'Shell is not interactive.'
    fi
    return 0
}

_koopa_assert_is_koopa_app() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_koopa_app "$arg"
        then
            _koopa_stop "Not koopa app: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_macos() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_macos
    then
        _koopa_stop 'macOS is required.'
    fi
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

_koopa_assert_is_ncbi_sra_toolkit_configured() {
    local conf_file
    conf_file="${HOME:?}/.ncbi/user-settings.mkfg"
    if [[ ! -f "$conf_file" ]]
    then
        _koopa_stop \
            "NCBI SRA Toolkit is not configured at '${conf_file}'." \
            "Run 'vdb-config --interactive' to resolve."
    fi
    return 0
}

_koopa_assert_is_non_existing() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            _koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_nonzero_file() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -s "$arg" ]]
        then
            _koopa_stop "Not non-zero file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_amd64() {
    _koopa_assert_has_no_args "$#"
    if _koopa_is_amd64
    then
        _koopa_stop 'AMD 64-bit (amd64, x86_64) architecture is not supported.'
    fi
    return 0
}

_koopa_assert_is_not_arm64() {
    _koopa_assert_has_no_args "$#"
    if _koopa_is_arm64
    then
        _koopa_stop 'ARM 64-bit architecture (arm64, aarch64) is not supported.'
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

_koopa_assert_is_not_installed() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if _koopa_is_installed "$arg"
        then
            local where
            where="$(_koopa_which_realpath "$arg")"
            _koopa_stop "'${arg}' is already installed at '${where}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_root() {
    _koopa_assert_has_no_args "$#"
    if _koopa_is_root
    then
        _koopa_stop 'root user detected.'
    fi
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

_koopa_assert_is_r_package_installed() {
    _koopa_assert_has_args "$#"
    if ! _koopa_is_r_package_installed "$@"
    then
        _koopa_stop "Required R packages missing: ${*}."
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

_koopa_assert_is_root() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_root
    then
        _koopa_stop 'root user is required.'
    fi
    return 0
}

_koopa_assert_is_set_2() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_set "$arg"
        then
            _koopa_stop "'${arg}' is unset."
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

_koopa_assert_is_writable() {
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            _koopa_stop "Not writable: '${arg}'."
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

_koopa_aws_batch_fetch_and_run() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$(_koopa_tmp_file)"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['url']="${BATCH_FILE_URL:?}"
    case "${dict['url']}" in
        'ftp://'* | \
        'http://'*)
            _koopa_download "${dict['url']}" "${dict['file']}"
            ;;
        's3://'*)
            "${app['aws']}" s3 cp \
                --profile "${dict['profile']}" \
                "${dict['url']}" "${dict['file']}"
            ;;
        *)
            _koopa_stop "Unsupported URL: '${dict['url']}'."
            ;;
    esac
    _koopa_chmod 'u+x' "${dict['file']}"
    "${dict['file']}"
    return 0
}

_koopa_aws_batch_list_jobs() {
    local -A app dict
    local -a job_queue_array status_array
    local status
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['account_id']="${AWS_BATCH_ACCOUNT_ID:-}"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['queue']="${AWS_BATCH_QUEUE:-}"
    dict['region']="${AWS_BATCH_REGION:-}"
    while (("$#"))
    do
        case "$1" in
            '--account-id='*)
                dict['account_id']="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict['account_id']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--queue='*)
                dict['queue']="${1#*=}"
                shift 1
                ;;
            '--queue')
                dict['queue']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict['account_id']}" \
        '--queue or AWS_BATCH_QUEUE' "${dict['queue']}" \
        '--region or AWS_BATCH_REGION' "${dict['region']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    _koopa_h1 "Checking AWS Batch job status for '${dict['profile']}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${dict['region']}"
        "${dict['account_id']}"
        "job-queue/${dict['queue']}"
    )
    status_array=(
        'SUBMITTED'
        'PENDING'
        'RUNNABLE'
        'STARTING'
        'RUNNING'
        'SUCCEEDED'
        'FAILED'
    )
    dict['job_queue']="$(_koopa_paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        _koopa_h2 "$status"
        "${app['aws']}" batch list-jobs \
            --job-queue "${dict['job_queue']}" \
            --job-status "$status" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}"
    done
    return 0
}

_koopa_aws_codecommit_list_repositories() {
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
        | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_aws_ec2_list_running_instances() {
    local -A app bool dict
    local -a filters
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    bool['name']=0
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--with-name')
                bool['name']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    if [[ "${bool['name']}" -eq 1 ]]
    then
        dict['query']="Reservations[*].Instances[*][Tags[?Key=='Name'].Value[],\
InstanceId,NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]"
        filters+=('Name=tag-key,Values=Name')
    else
        dict['query']='Reservations[*].Instances[*].[InstanceId]'
    fi
    filters+=('Name=instance-state-name,Values=running')
    dict['out']="$( \
        "${app['aws']}" ec2 describe-instances \
            --filters "${filters[@]}" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}" \
            --query "${dict['query']}" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}

_koopa_aws_ec2_map_instance_ids_to_names() {
    local -A app dict
    local -a ids names out
    app['aws']="$(_koopa_locate_aws)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    dict['json']="$( \
        "${app['aws']}" ec2 describe-instances \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
    )"
    readarray -t ids <<< "$( \
        _koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].InstanceId)"' \
    )"
    _koopa_assert_is_array_non_empty "${ids[@]}"
    readarray -t names <<< "$( \
        _koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].Tags[0].Value)"' \
    )"
    _koopa_assert_is_array_non_empty "${names[@]}"
    for i in "${!ids[@]}"
    do
        out+=("${ids[$i]} : ${names[$i]}")
    done
    _koopa_print "${out[@]}"
    return 0
}

_koopa_aws_ecr_login_private() {
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['account_id']="${AWS_ECR_ACCOUNT_ID:-}"
    dict['profile']="${AWS_ECR_PROFILE:-}"
    dict['region']="${AWS_ECR_REGION:-}"
    dict['repo_url']="${dict['account_id']}.dkr.ecr.${dict['region']}.\
amazonaws.com"
    while (("$#"))
    do
        case "$1" in
            '--account-id='*)
                dict['account_id']="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict['account_id']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--account-id or AWS_ECR_ACCOUNT_ID' "${dict['account_id']}" \
        '--profile or AWS_ECR_PROFILE' "${dict['profile']}" \
        '--region or AWS_ECR_REGION' "${dict['region']}"
    _koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" ecr get-login-password \
        --profile "${dict['profile']}" \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}

_koopa_aws_ecr_login_public() {
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_ECR_PROFILE:-}"
    dict['region']="${AWS_ECR_REGION:-}"
    dict['repo_url']='public.ecr.aws'
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--profile or AWS_ECR_PROFILE' "${dict['profile']}" \
        '--region or AWS_ECR_REGION' "${dict['region']}"
    _koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" ecr-public get-login-password \
        --profile "${dict['profile']}" \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}

_koopa_aws_s3_bucket() {
    local string
    _koopa_assert_has_args "$#"
    _koopa_is_aws_s3_uri "$@" || return 1
    string="$( \
        _koopa_sub \
            --pattern='^s3://([^/]+)/(.+)$' \
            --regex \
            --replacement='\1' \
            "$@" \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_aws_s3_cp_regex() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bucket_pattern']='^s3://.+/$'
    dict['pattern']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['source_prefix']=''
    dict['target_prefix']=''
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    if ! _koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['source_prefix']}" &&
        ! _koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['target_prefix']}"
    then
        _koopa_stop "Souce and or/target must match '${dict['bucket_pattern']}'."
    fi
    "${app['aws']}" s3 cp \
        --exclude '*' \
        --follow-symlinks \
        --include "${dict['pattern']}" \
        --profile "${dict['profile']}" \
        --recursive \
        "${dict['source_prefix']}" \
        "${dict['target_prefix']}"
    return 0
}

_koopa_aws_s3_delete_markers() {
    local -A app bool dict
    local i
    app['aws']="$(_koopa_locate_aws)"
    app['cut']="$(_koopa_locate_cut)"
    app['head']="$(_koopa_locate_head)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
    bool['dry_run']=0
    dict['bucket']=''
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            '--dry-run' | \
            '--dryrun')
                bool['dry_run']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        _koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(_koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dry_run']}" -eq 1 ]]
    then
        _koopa_alert_info 'Dry run mode enabled.'
    fi
    _koopa_alert "Removing deletion markers in \
's3://${dict['bucket']}/${dict['prefix']}/'."
    dict['json_file']="$(_koopa_tmp_file)"
    dict['query']='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}'
    _koopa_dl \
        'JSON file' "${dict['json_file']}" \
        'Query' "${dict['query']}"
    i=0
    while [[ -f "${dict['json_file']}" ]]
    do
        i=$((i+1))
        _koopa_alert_info "Batch ${i}"
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --max-items 1000 \
            --no-cli-pager \
            --output 'json' \
            --prefix "${dict['prefix']}" \
            --profile "${dict['profile']}" \
            --query="${dict['query']}" \
            2> /dev/null \
            > "${dict['json_file']}"
        if _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": null' \
        || _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": []'
        then
            _koopa_alert_note 'No deletion markers detected.'
            _koopa_rm "${dict['json_file']}"
            break
        fi
        dict['lines']="$( \
            "${app['wc']}" -l "${dict['json_file']}" \
            | "${app['cut']}" -d ' ' -f 1 \
        )"
        if [[ "${dict['lines']}" -gt 3997 ]]
        then
            dict['tmp_file']="$(_koopa_tmp_file)"
            "${app['head']}" \
                -n 3997 \
                "${dict['json_file']}" \
                > "${dict['tmp_file']}"
            _koopa_append_string \
                --file="${dict['tmp_file']}" \
                --string='        } ] }'
            _koopa_mv "${dict['tmp_file']}" "${dict['json_file']}"
        fi
        if [[ "${bool['dry_run']}" -eq 1 ]]
        then
            app['less']="$(_koopa_locate_less)"
            _koopa_assert_is_executable "${app['less']}"
            "${app['less']}" "${dict['json_file']}"
            break
        fi
        "${app['aws']}" s3api delete-objects \
            --bucket "${dict['bucket']}" \
            --delete "file://${dict['json_file']}" \
            --no-cli-pager \
            --profile "${dict['profile']}" \
            --region "${dict['region']}"
    done
    return 0
}

_koopa_aws_s3_delete_versioned_glacier_objects() {
    _koopa_aws_s3_delete_versioned_objects --glacier "$@"
}

_koopa_aws_s3_delete_versioned_objects() {
    local -A app bool dict
    local i
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    bool['dry_run']=0
    bool['glacier']=0
    dict['bucket']=''
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            '--dry-run' | \
            '--dryrun')
                bool['dry_run']=1
                shift 1
                ;;
            '--glacier')
                bool['glacier']=1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        _koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(_koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dry_run']}" -eq 1 ]]
    then
        _koopa_alert_info 'Dry run mode enabled.'
    fi
    _koopa_alert "Deleting outdated versioned objects in \
's3://${dict['bucket']}/${dict['prefix']}/'."
    dict['json_file']="$(_koopa_tmp_file)"
    if [[ "${bool['glacier']}" -eq 1 ]]
    then
        dict['version_query']="StorageClass=='GLACIER'"
    else
        dict['version_query']="IsLatest==\`false\`"
    fi
    dict['query']="{Objects: Versions[?${dict['version_query']}].\
{Key:Key,VersionId:VersionId}}"
    _koopa_dl \
        'JSON file' "${dict['json_file']}" \
        'Query' "${dict['query']}"
    i=0
    while [[ -f "${dict['json_file']}" ]]
    do
        i=$((i+1))
        _koopa_alert_info "Batch ${i}"
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --max-items 1000 \
            --no-cli-pager \
            --output 'json' \
            --prefix "${dict['prefix']}" \
            --profile "${dict['profile']}" \
            --query "${dict['query']}" \
            --region "${dict['region']}" \
            2> /dev/null \
            > "${dict['json_file']}"
        _koopa_assert_is_file "${dict['json_file']}"
        if _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": null' \
        || _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": []'
        then
            _koopa_alert_note 'No outdated versioned objects detected.'
            _koopa_rm "${dict['json_file']}"
            break
        fi
        if [[ "${bool['dry_run']}" -eq 1 ]]
        then
            app['less']="$(_koopa_locate_less)"
            _koopa_assert_is_executable "${app['less']}"
            "${app['less']}" "${dict['json_file']}"
            break
        fi
        "${app['aws']}" s3api delete-objects \
            --bucket "${dict['bucket']}" \
            --delete "file://${dict['json_file']}" \
            --no-cli-pager \
            --profile "${dict['profile']}" \
            --region "${dict['region']}"
    done
    return 0
}

_koopa_aws_s3_dot_clean() {
    local -A app bool dict
    local -a keys
    local key
    app['aws']="$(_koopa_locate_aws)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    bool['dryrun']=0
    dict['bucket']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            '--dry-run' | \
            '--dryrun')
                bool['dryrun']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        _koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(_koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dryrun']}" -eq 1 ]]
    then
        _koopa_alert_info 'Dry run mode enabled.'
    fi
    _koopa_alert "Fetching objects in '${dict['bucket']}'."
    dict['json']="$( \
        "${app['aws']}" s3api list-objects \
            --bucket "${dict['bucket']}" \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --query "Contents[?contains(Key,'/.')].Key" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        _koopa_alert_note "No dot files in '${dict['bucket']}'."
        return 0
    fi
    readarray -t keys <<< "$( \
        _koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[]' \
    )"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#keys[@]}" \
        --msg1='object' \
        --msg2='objects' \
        --suffix=' detected.' \
    )"
    for key in "${keys[@]}"
    do
        local s3uri
        s3uri="s3://${dict['bucket']}/${key}"
        _koopa_alert "Deleting '${s3uri}'."
        [[ "${bool['dryrun']}" -eq 1 ]] && continue
        "${app['aws']}" s3 rm \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
            "$s3uri"
    done
    return 0
}

_koopa_aws_s3_find() {
    local -A dict
    local -a exclude_arr include_arr ls_args
    local pattern str
    _koopa_assert_has_args "$#"
    dict['exclude']=0
    dict['include']=0
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
    exclude_arr=()
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                dict['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                dict['include']=1
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                dict['include']=1
                include_arr+=("${2:?}")
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    _koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    ls_args=(
        '--prefix' "${dict['prefix']}"
        '--profile' "${dict['profile']}"
        '--type' 'f'
    )
    [[ "${dict['recursive']}" -eq 1 ]] && ls_args+=('--recursive')
    str="$(_koopa_aws_s3_ls "${ls_args[@]}")"
    [[ -n "$str" ]] || return 1
    if [[ "${dict['exclude']}" -eq 1 ]]
    then
        for pattern in "${exclude_arr[@]}"
        do
            if _koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    _koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                _koopa_grep \
                    --invert-match \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    if [[ "${dict['include']}" -eq 1 ]]
    then
        for pattern in "${include_arr[@]}"
        do
            if _koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    _koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                _koopa_grep \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    _koopa_print "$str"
    return 0
}

_koopa_aws_s3_key() {
    local string
    _koopa_assert_has_args "$#"
    _koopa_is_aws_s3_uri "$@" || return 1
    string="$( \
        _koopa_sub \
            --pattern='^s3://([^/]+)/(.+)$' \
            --regex \
            --replacement='\2' \
            "$@" \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_aws_s3_list_large_files() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['aws']="$(_koopa_locate_aws)"
    app['jq']="$(_koopa_locate_jq)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bucket']=''
    dict['num']='20'
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--num' "${dict['num']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        _koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(_koopa_strip_trailing_slash "${dict['bucket']}")"
    dict['awk_string']="NR<=${dict['num']} {print \$1}"
    dict['str']="$( \
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --output 'json' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
        | "${app['jq']}" \
            --raw-output \
            '.Versions[] | "\(.Key)\t \(.Size)"' \
        | "${app['sort']}" --key=2 --numeric-sort --reverse \
        | "${app['awk']}" "${dict['awk_string']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_aws_s3_ls() {
    local -A app dict
    local -a ls_args
    local str
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['aws']="$(_koopa_locate_aws)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
    dict['type']=''
    ls_args=()
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
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
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    _koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    case "${dict['type']}" in
        '')
            dict['dirs']=1
            dict['files']=1
            ;;
        'd')
            dict['dirs']=1
            dict['files']=0
            ;;
        'f')
            dict['dirs']=0
            dict['files']=1
            ;;
        *)
            _koopa_stop "Unsupported type: '${dict['type']}'."
            ;;
    esac
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        ls_args+=('--recursive')
        if [[ "${dict['type']}" == 'd' ]]
        then
            _koopa_stop 'Recursive directory listing is not supported.'
        fi
    fi
    str="$( \
        "${app['aws']}" s3 ls \
            --profile "${dict['profile']}" \
            "${ls_args[@]}" \
            "${dict['prefix']}" \
            2>/dev/null \
    )"
    [[ -n "$str" ]] || return 1
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        dict['bucket_prefix']="$( \
            _koopa_grep \
                --only-matching \
                --pattern='^s3://[^/]+' \
                --regex \
                --string="${dict['prefix']}" \
        )"
        files="$( \
            _koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            _koopa_print "$files" \
                | "${app['awk']}" '{print $4}' \
                | "${app['awk']}" 'NF' \
                | "${app['sed']}" "s|^|${dict['bucket_prefix']}/|g" \
                | _koopa_grep --pattern='^s3://.+[^/]$' --regex \
        )"
        _koopa_print "$files"
        return 0
    fi
    if [[ "${dict['dirs']}" -eq 1 ]]
    then
        dirs="$( \
            _koopa_grep \
                --only-matching \
                --pattern='^\s+PRE\s.+/$' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                _koopa_print "$dirs" \
                    | "${app['sed']}" 's|^ \+PRE ||g' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            _koopa_print "$dirs"
        fi
    fi
    if [[ "${dict['files']}" -eq 1 ]]
    then
        files="$( \
            _koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$files" ]]
        then
            files="$( \
                _koopa_print "$files" \
                    | "${app['awk']}" '{print $4}' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            _koopa_print "$files"
        fi
    fi
    return 0
}

_koopa_aws_s3_mv_to_parent() {
    local -A app dict
    local -a files
    local file prefix
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict['profile']}"
        '--prefix' "${dict['prefix']}"
    _koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    dict['str']="$( \
        _koopa_aws_s3_ls \
            --prefix="${dict['prefix']}" \
            --profile="${dict['profile']}" \
    )"
    if [[ -z "${dict['str']}" ]]
    then
        _koopa_stop "No content detected in '${dict['prefix']}'."
    fi
    readarray -t files <<< "${dict['str']}"
    for file in "${files[@]}"
    do
        local -A dict2
        dict2['bn']="$(_koopa_basename "$file")"
        dict2['dn1']="$(_koopa_dirname "$file")"
        dict2['dn2']="$(_koopa_dirname "${dict2['dn1']}")"
        dict2['target']="${dict2['dn2']}/${dict2['bn']}"
        "${app['aws']}" s3 mv \
            --profile "${dict['profile']}" \
            --recursive \
            "${dict2['file']}" \
            "${dict2['target']}"
    done
    return 0
}

_koopa_aws_s3_sync() {
    local -A app dict
    local -a exclude_args exclude_patterns pos sync_args
    local pattern
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    exclude_patterns=(
        '*.Rproj/*'
        '*.swp'
        '*.tmp'
        '.*'
        '.DS_Store'
        '.Rproj.user/*'
        '._*'
        '.git/*'
    )
    pos=()
    sync_args=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                exclude_patterns+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_patterns+=("${2:?}")
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            '--delete' | \
            '--dryrun' | \
            '--exact-timestamps' | \
            '--follow-symlinks' | \
            '--no-follow-symlinks' | \
            '--no-progress' | \
            '--only-show-errors' | \
            '--size-only' | \
            '--quiet')
                sync_args+=("$1")
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
    if [[ "$#" -gt 0 ]]
    then
        _koopa_assert_has_args_eq "$#" 2
        _koopa_assert_has_no_flags "$@"
        sync_args+=("$@")
    else
        sync_args+=(
            "${dict['source_prefix']}"
            "${dict['target_prefix']}"
        )
    fi
    exclude_args=()
    for pattern in "${exclude_patterns[@]}"
    do
        exclude_args+=(
            "--exclude=${pattern}"
            "--exclude=*/${pattern}"
        )
    done
    "${app['aws']}" s3 sync \
        --profile "${dict['profile']}" \
        "${exclude_args[@]}" \
        "${sync_args[@]}"
    return 0
}

_koopa_cli_app() {
    local -A dict
    dict['key']=''
    case "${1:-}" in
        '--help' | \
        '-h')
            _koopa_help "$(_koopa_man_prefix)/man1/app.1"
            ;;
        'aws')
            case "${2:-}" in
                'batch')
                    case "${3:-}" in
                        'fetch-and-run' | \
                        'list-jobs')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'codecommit')
                    case "${3:-}" in
                        'list-repositories')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'ec2')
                    case "${3:-}" in
                        'instance-id' | \
                        'list-running-instances' | \
                        'map-instance-ids-to-names' | \
                        'stop')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        'suspend')
                            _koopa_defunct 'ec2 stop'
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'ecr')
                    case "${3:-}" in
                        'login-public' | \
                        'login-private')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                's3')
                    case "${3:-}" in
                        'delete-markers' | \
                        'delete-versioned-glacier-objects' | \
                        'delete-versioned-objects' | \
                        'dot-clean' | \
                        'find' | \
                        'list-large-files' | \
                        'ls' | \
                        'mv-to-parent' | \
                        'sync')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bioconda')
            case "${2:-}" in
                'autobump-recipe')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bowtie2')
            case "${2:-}" in
                'align')
                    case "${3:-}" in
                        'paired-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'brew')
            case "${2:-}" in
                'cleanup' | \
                'dump-brewfile' | \
                'outdated' | \
                'reset-core-repo' | \
                'reset-permissions' | \
                'uninstall-all-brews' | \
                'upgrade-brews' | \
                'version')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'conda')
            case "${2:-}" in
                'create-env' | \
                'remove-env')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'docker')
            case "${2:-}" in
                'build' | \
                'build-all-tags' | \
                'prune-all-images' | \
                'prune-old-images' | \
                'remove' | \
                'run')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ftp')
            case "${2:-}" in
                'mirror')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'git')
            case "${2:-}" in
                'pull' | \
                'push-submodules' | \
                'rename-master-to-main' | \
                'reset' | \
                'reset-fork-to-upstream' | \
                'rm-submodule' | \
                'rm-untracked')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'gpg')
            case "${2:-}" in
                'prompt' | \
                'reload' | \
                'restart')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'hisat2' | \
        'star')
            case "${2:-}" in
                'align')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'jekyll')
            case "${2:-}" in
                'serve')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'kallisto')
            case "${2:-}" in
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'md5sum')
            case "${2:-}" in
                'check-to-new-md5-file')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'miso')
            case "${2:-}" in
                'index' | \
                'run')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'r')
            case "${2:-}" in
                'bioconda-check' | \
                'check')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'rmats')
            dict['key']="${1:?}"
            shift 1
            ;;
        'rnaeditingindexer')
            dict['key']="${1:?}"
            shift 1
            ;;
        'rsem')
            case "${2:-}" in
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'bam')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'salmon')
            case "${2:-}" in
                'detect-fastq-library-type' | \
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'bam' | \
                        'paired-end' | \
                        'single-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            _koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ssh')
            case "${2:-}" in
                'generate-key')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'wget')
            case "${2:-}" in
                'recursive')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    _koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        *)
            _koopa_cli_invalid_arg "$@"
            ;;
    esac
    [[ -z "${dict['key']}" ]] && _koopa_cli_invalid_arg "$@"
    dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
    if ! _koopa_is_function "${dict['fun']}"
    then
        _koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

_koopa_cli_configure() {
    local -a flags pos
    local app stem
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--verbose')
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
    stem='configure'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
        if ! _koopa_is_function "${dict['fun']}"
        then
            _koopa_stop "Unsupported app: '${app}'."
        fi
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict['fun']}" "${flags[@]:-}"
        else
            "${dict['fun']}"
        fi
    done
    return 0
}

_koopa_cli_develop() {
    local -A dict
    dict['key']=''
    case "${1:-}" in
        'log')
            dict['key']='view-latest-tmp-log-file'
            shift 1
            ;;
        'cache-functions' | \
        'edit-app-json' | \
        'prune-app-binaries' | \
        'push-all-app-builds' | \
        'push-app-build' | \
        'roff')
            dict['key']="${1:?}"
            shift 1
            ;;
    esac
    [[ -z "${dict['key']}" ]] && _koopa_cli_invalid_arg "$@"
    dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
    if ! _koopa_is_function "${dict['fun']}"
    then
        _koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

_koopa_cli_install() {
    local -A dict
    local -a flags pos
    local app
    _koopa_assert_has_args "$#"
    dict['stem']='install'
    case "${1:-}" in
        'koopa')
            shift 1
            _koopa_install_koopa "$@"
            return 0
            ;;
        'private' | 'system' | 'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
        'app' | 'shared-apps')
            _koopa_stop 'Unsupported command.'
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--bootstrap' | \
            '--reinstall' | \
            '--verbose')
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
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict2
        dict2['app']="$app"
        dict2['key']="${dict['stem']}-${dict2['app']}"
        dict2['fun']="$(_koopa_which_function "${dict2['key']}" || true)"
        if ! _koopa_is_function "${dict2['fun']}"
        then
            _koopa_stop "Unsupported app: '${dict2['app']}'."
        fi
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2['fun']}" "${flags[@]}"
        else
            "${dict2['fun']}"
        fi
    done
    return 0
}

_koopa_cli_invalid_arg() {
    if [[ "$#" -eq 0 ]]
    then
        _koopa_stop "Missing required argument. \
Check autocompletion of supported arguments with <TAB>."
    else
        _koopa_stop "Invalid and/or incomplete argument: '${*}'.\n\
Check autocompletion of supported arguments with <TAB>."
    fi
}

_koopa_cli_reinstall() {
    local -A dict
    local -a pos
    _koopa_assert_has_args "$#"
    dict['mode']='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--all')
                _koopa_invalid_arg "$1"
                ;;
            '--all-revdeps')
                dict['mode']='all-revdeps'
                shift 1
                ;;
            '--only-revdeps')
                dict['mode']='only-revdeps'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${dict['mode']}" in
        'all-revdeps' | \
        'all-reverse-dependencies')
            _koopa_reinstall_all_revdeps "$@"
            ;;
        'default')
            _koopa_cli_install --reinstall "$@"
            ;;
        'only-revdeps' | \
        'only-reverse-dependencies')
            _koopa_reinstall_only_revdeps "$@"
            ;;
    esac
    return 0
}

_koopa_cli_system() {
    local -A dict
    dict['key']=''
    case "${1:-}" in
        'check')
            dict['key']='check-system'
            shift 1
            ;;
        'info')
            dict['key']='system-info'
            shift 1
            ;;
        'list')
            case "${2:-}" in
                'app-versions' | \
                'dotfiles' | \
                'launch-agents' | \
                'path-priority' | \
                'programs')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
            esac
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    dict['key']='koopa-prefix'
                    shift 1
                    ;;
                'koopa')
                    dict['key']='koopa-prefix'
                    shift 2
                    ;;
                *)
                    dict['key']="${2}-prefix"
                    shift 2
                    ;;
            esac
            ;;
        'version')
            dict['key']='get-version'
            shift 1
            ;;
        'which')
            dict['key']='which-realpath'
            shift 1
            ;;
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'hostname' | \
        'os-string' | \
        'prune-apps' | \
        'switch-to-develop' | \
        'test' | \
        'zsh-compaudit-set-permissions')
            dict['key']="${1:?}"
            shift 1
            ;;
        'cache-functions' | \
        'edit-app-json' | \
        'prune-app-binaries')
            _koopa_defunct "koopa develop ${1:?}"
            ;;
    esac
    if [[ -z "${dict['key']}" ]]
    then
        if _koopa_is_linux
        then
            case "${1:-}" in
                'delete-cache' | \
                'fix-sudo-setrlimit-error')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        elif _koopa_is_macos
        then
            case "${1:-}" in
                'spotlight')
                    dict['key']='spotlight-find'
                    shift 1
                    ;;
                'clean-launch-services' | \
                'create-dmg' | \
                'disable-touch-id-sudo' | \
                'enable-touch-id-sudo' | \
                'flush-dns' | \
                'force-eject' | \
                'ifactive' | \
                'list-launch-agents' | \
                'reload-autofs')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "${dict['key']}" ]] && _koopa_cli_invalid_arg "$@"
    dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
    if ! _koopa_is_function "${dict['fun']}"
    then
        _koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

_koopa_cli_uninstall() {
    local -a flags pos
    local app stem
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--verbose')
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
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
    else
        set -- 'koopa'
    fi
    stem='uninstall'
    case "$1" in
        'private' | \
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
        if ! _koopa_is_function "${dict['fun']}"
        then
            _koopa_stop "Unsupported app: '${app}'."
        fi
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict['fun']}" "${flags[@]:-}"
        else
            "${dict['fun']}"
        fi
    done
    return 0
}

_koopa_cli_update() {
    local app stem
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='update'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
        if ! _koopa_is_function "${dict['fun']}"
        then
            _koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
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
    _koopa_python_script 'app-dependencies.py' "$@"
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
    _koopa_python_script 'app-json.py' "$@"
    return 0
}

_koopa_app_reverse_dependencies() {
    _koopa_assert_has_args_eq "$#" 1
    _koopa_python_script 'app-reverse-dependencies.py' "$@"
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

_koopa_bowtie2_align_paired_end_per_sample() {
    local -A app bool dict
    _koopa_assert_has_args "$#"
    app['bowtie2']="$(_koopa_locate_bowtie2)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "bowtie2 requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['index_base']="${dict['index_dir']}/bowtie2"
    _koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(_koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(_koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(_koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(_koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['sample_bn']="$(_koopa_basename "${dict['output_dir']}")"
    dict['sam_file']="${dict['output_dir']}/${dict['sample_bn']}.sam"
    dict['bam_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.bam' \
            "${dict['sam_file']}" \
    )"
    dict['log_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.log' \
            "${dict['sam_file']}" \
    )"
    _koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['fastq_r1_file']}"
    then
        bool['tmp_fastq_r1_file']=1
        dict['tmp_fastq_r1_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['fastq_r1_file']}" \
            --output-file="${dict['tmp_fastq_r1_file']}"
        dict['fastq_r1_file']="${dict['tmp_fastq_r1_file']}"
    fi
    if _koopa_is_compressed_file "${dict['fastq_r2_file']}"
    then
        bool['tmp_fastq_r2_file']=1
        dict['tmp_fastq_r2_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['fastq_r2_file']}" \
            --output-file="${dict['tmp_fastq_r2_file']}"
        dict['fastq_r2_file']="${dict['tmp_fastq_r2_file']}"
    fi
    align_args+=(
        '--local'
        '--sensitive-local'
        '--rg-id' "${dict['id']}"
        '--rg' 'PL:illumina'
        '--rg' "PU:${dict['id']}"
        '--rg' "SM:${dict['id']}"
        '--threads' "${dict['threads']}"
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-X' 2000
        '-q'
        '-x' "${dict['index_base']}"
    )
    _koopa_dl 'Align args' "${align_args[*]}"
    "${app['bowtie2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r2_file']}"
    fi
    _koopa_samtools_convert_sam_to_bam "${dict['sam_file']}"
    _koopa_samtools_sort_bam "${dict['bam_file']}"
    _koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}

_koopa_bowtie2_align_paired_end() {
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running bowtie2 align.'
    _koopa_dl \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement="${dict['fastq_r2_tail']}" \
                "${dict2['fastq_r1_file']}" \
        )"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_r1_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_bowtie2_align_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'bowtie2 align was successful.'
    return 0
}

_koopa_bowtie2_index() {
    local -A app dict
    local -a index_args
    _koopa_assert_has_args "$#"
    app['bowtie2_build']="$(_koopa_locate_bowtie2_build)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_file "${dict['genome_fasta_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating bowtie2 index at '${dict['output_dir']}'."
    dict['index_base']="${dict['output_dir']}/bowtie2"
    dict['log_file']="${dict['output_dir']}/index.log"
    index_args=(
        "--threads=${dict['threads']}"
        '--verbose'
        "${dict['genome_fasta_file']}"
        "${dict['index_base']}"
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['bowtie2_build']}" "${index_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

_koopa_brew_doctor() {
    local -A app
    local -a all_checks disabled_checks enabled_checks
    app['brew']="$(_koopa_locate_brew)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    app['uniq']="$(_koopa_locate_uniq --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    disabled_checks=(
        'check_for_stray_dylibs'
        'check_for_stray_headers'
        'check_for_stray_las'
        'check_for_stray_pcs'
        'check_for_stray_static_libs'
        'check_user_path_1'
        'check_user_path_2'
        'check_user_path_3'
    )
    readarray -t all_checks <<< "$("${app['brew']}" doctor --list-checks)"
    readarray -t enabled_checks <<< "$( \
        _koopa_print "${all_checks[@]}" "${disabled_checks[@]}" \
            | "${app['tr']}" ' ' '\n' \
            | "${app['sort']}" \
            | "${app['uniq']}" -u \
    )"
    _koopa_assert_is_array_non_empty "${enabled_checks[@]}"
    "${app['brew']}" config || true
    "${app['brew']}" doctor "${enabled_checks[@]}" || true
    return 0
}

_koopa_brew_dump_brewfile() {
    local -A app
    local today
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    today="$(_koopa_today)"
    "${app['brew']}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

_koopa_brew_outdated() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['brew']}" outdated --quiet)"
    _koopa_print "$str"
    return 0
}

_koopa_brew_reset_core_repo() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['repo']='homebrew/core'
    dict['prefix']="$("${app['brew']}" --repo "${dict['repo']}")"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_alert "Resetting git repo at '${dict['prefix']}'."
    (
        local -A dict2
        _koopa_cd "${dict['prefix']}"
        dict2['branch']="$(_koopa_git_default_branch "${PWD:?}")"
        dict2['origin']='origin'
        "${app['git']}" checkout -q "${dict2['branch']}"
        "${app['git']}" branch -q \
            "${dict2['branch']}" \
            -u "${dict2['origin']}/${dict2['branch']}"
        "${app['git']}" reset -q --hard \
            "${dict2['origin']}/${dict2['branch']}"
    )
    return 0
}

_koopa_brew_reset_permissions() {
    local -A bool dict
    local -a dirs
    local dir
    _koopa_assert_has_no_args "$#"
    _koopa_is_linux && return 0
    bool['reset']=0
    dict['group_name']="$(_koopa_admin_group_name)"
    dict['prefix']="$(_koopa_homebrew_prefix)"
    dict['user_id']="$(_koopa_user_id)"
    dict['user_name']="$(_koopa_user_name)"
    _koopa_alert 'Checking permissions.'
    _koopa_assert_is_dir "${dict['prefix']}/Cellar"
    dict['stat_user_id']="$(_koopa_stat_user_id "${dict['prefix']}/Cellar")"
    if [[ "${dict['stat_user_id']}" != "${dict['user_id']}" ]]
    then
        _koopa_stop "Homebrew is not owned by current user \
('${dict['user_name']}')."
    fi
    dirs=(
        "${dict['prefix']}/bin"
        "${dict['prefix']}/etc"
        "${dict['prefix']}/etc/bash_completion.d"
        "${dict['prefix']}/include"
        "${dict['prefix']}/lib"
        "${dict['prefix']}/lib/pkgconfig"
        "${dict['prefix']}/sbin"
        "${dict['prefix']}/share"
        "${dict['prefix']}/share/doc"
        "${dict['prefix']}/share/info"
        "${dict['prefix']}/share/locale"
        "${dict['prefix']}/share/man"
        "${dict['prefix']}/share/man/man1"
        "${dict['prefix']}/share/man/man3"
        "${dict['prefix']}/share/man/man5"
        "${dict['prefix']}/share/zsh"
        "${dict['prefix']}/share/zsh/site-functions"
        "${dict['prefix']}/var/homebrew/linked"
        "${dict['prefix']}/var/homebrew/locks"
    )
    for dir in "${dirs[@]}"
    do
        [[ "${bool['reset']}" -eq 1 ]] && continue
        [[ -d "$dir" ]] || continue
        [[ "$(_koopa_stat_user_id "$dir")" == "${dict['user_id']}" ]] \
            && continue
        bool['reset']=1
    done
    bool['reset']=0 && return 0
    _koopa_alert "Resetting ownership of files in \
'${dict['prefix']}' to '${dict['user_name']}:${dict['group_name']}'."
    _koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${dict['user_name']}:${dict['group_name']}" \
        "${dict['prefix']}/"*
    return 0
}

_koopa_brew_uninstall_all_brews() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
    while [[ "$("${app['brew']}" list --formulae | "${app['wc']}" -l)" -gt 0 ]]
    do
        local brews
        readarray -t brews <<< "$("${app['brew']}" list --formulae)"
        "${app['brew']}" uninstall \
            --force \
            --ignore-dependencies \
            "${brews[@]}"
    done
    return 0
}

_koopa_brew_upgrade_brews() {
    local -A app
    local -a brews
    local brew
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Checking brews.'
    readarray -t brews <<< "$(_koopa_brew_outdated)"
    _koopa_is_array_non_empty "${brews[@]:-}" || return 0
    _koopa_dl \
        "$(_koopa_ngettext \
            --num="${#brews[@]}" \
            --middle=' outdated ' \
            --msg1='brew' \
            --msg2='brews' \
        )" \
        "$(_koopa_to_string "${brews[@]}")"
    "${app['brew']}" reinstall --force "${brews[@]}"
    return 0
}

_koopa_brew_version() {
    local -A app
    local brew
    _koopa_assert_has_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    for brew in "$@"
    do
        local str
        str="$( \
            "${app['brew']}" info --json "$brew" \
                | "${app['jq']}" --raw-output '.[].versions.stable'
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_build_go_package() {
    local -A app dict
    local -a build_args
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'go'
    app['go']="$(_koopa_locate_go)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bin_name']=''
    dict['build_cmd']=''
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['ldflags']=''
    dict['mod']=''
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tags']=''
    dict['url']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--build-cmd='*)
                dict['build_cmd']="${1#*=}"
                shift 1
                ;;
            '--build-cmd')
                dict['build_cmd']="${2:?}"
                shift 2
                ;;
            '--ldflags='*)
                dict['ldflags']="${1#*=}"
                shift 1
                ;;
            '--ldflags')
                dict['ldflags']="${2:?}"
                shift 2
                ;;
            '--mod='*)
                dict['mod']="${1#*=}"
                shift 1
                ;;
            '--mod')
                dict['mod']="${2:?}"
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
            '--tags='*)
                dict['tags']="${1#*=}"
                shift 1
                ;;
            '--tags')
                dict['tags']="${2:?}"
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
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}" \
        '--version' "${dict['version']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    [[ -z "${dict['bin_name']}" ]] && dict['bin_name']="${dict['name']}"
    if [[ -n "${dict['ldflags']}" ]]
    then
        build_args+=('-ldflags' "${dict['ldflags']}")
    fi
    if [[ -n "${dict['mod']}" ]]
    then
        build_args+=('-mod' "${dict['mod']}")
    fi
    if [[ -n "${dict['tags']}" ]]
    then
        build_args+=('-tags' "${dict['tags']}")
    fi
    build_args+=('-o' "${dict['prefix']}/bin/${dict['bin_name']}")
    if [[ -n "${dict['build_cmd']}" ]]
    then
        build_args+=("${dict['build_cmd']}")
    fi
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    _koopa_dl 'go build args' "${build_args[*]}"
    "${app['go']}" build "${build_args[@]}"
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
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
    local dir
    _koopa_assert_has_args_ge "$#" 2
    dict['target_file']="${1:?}"
    shift 1
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
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
        for dir in "$@"
        do
            [[ -d "$dir" ]] || continue
            "${app['find']}" "$dir" \
                -type 'f' -name '*.sh' -print0 \
            | "${app['sort']}" -z \
            | "${app['xargs']}" -0 "${app['cat']}" \
            | "${app['grep']}" -Eiv '^(\s+)?#'
        done
    } | "${app['cat']}" -s > "${dict['target_file']}"
    return 0
}

_koopa_cache_functions() {
    local -A dict
    local dir
    _koopa_assert_has_no_args "$#"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['_koopa_prefix']}/lang"
    dict['bash_functions']="${dict['lang_prefix']}/bash/functions"
    dict['sh_functions']="${dict['lang_prefix']}/sh/functions"
    _koopa_assert_is_dir \
        "${dict['_koopa_prefix']}" \
        "${dict['lang_prefix']}" \
        "${dict['bash_functions']}" \
        "${dict['sh_functions']}"
    _koopa_cache_functions_dirs \
        "${dict['bash_functions']}/activate.sh" \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/alias" \
        "${dict['bash_functions']}/core" \
        "${dict['bash_functions']}/export" \
        "${dict['bash_functions']}/is" \
        "${dict['bash_functions']}/macos" \
        "${dict['bash_functions']}/prefix" \
        "${dict['bash_functions']}/xdg"
    _koopa_cache_functions_dirs \
        "${dict['bash_functions']}/common.sh" \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/add" \
        "${dict['bash_functions']}/alert" \
        "${dict['bash_functions']}/alias" \
        "${dict['bash_functions']}/assert" \
        "${dict['bash_functions']}/aws" \
        "${dict['bash_functions']}/cli" \
        "${dict['bash_functions']}/core" \
        "${dict['bash_functions']}/current" \
        "${dict['bash_functions']}/docker" \
        "${dict['bash_functions']}/export" \
        "${dict['bash_functions']}/find" \
        "${dict['bash_functions']}/git" \
        "${dict['bash_functions']}/install" \
        "${dict['bash_functions']}/is" \
        "${dict['bash_functions']}/locate" \
        "${dict['bash_functions']}/macos" \
        "${dict['bash_functions']}/prefix" \
        "${dict['bash_functions']}/print" \
        "${dict['bash_functions']}/python" \
        "${dict['bash_functions']}/r" \
        "${dict['bash_functions']}/reinstall" \
        "${dict['bash_functions']}/salmon" \
        "${dict['bash_functions']}/uninstall" \
        "${dict['bash_functions']}/xdg"
    _koopa_cache_functions_dir \
        "${dict['bash_functions']}/os/linux/alpine" \
        "${dict['bash_functions']}/os/linux/arch" \
        "${dict['bash_functions']}/os/linux/common" \
        "${dict['bash_functions']}/os/linux/debian" \
        "${dict['bash_functions']}/os/linux/fedora" \
        "${dict['bash_functions']}/os/linux/opensuse" \
        "${dict['bash_functions']}/os/linux/rhel" \
        "${dict['bash_functions']}/os/macos"
    _koopa_cache_functions_dir \
        "${dict['sh_functions']}"
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

_koopa_check_system() {
    local -A bool dict
    _koopa_assert_has_no_args "$#"
    bool['warnings']=0
    _koopa_check_build_system
    dict['bootstrap_prefix']="$(_koopa_bootstrap_prefix)"
    if [[ -d "${dict['bootstrap_prefix']}" ]]
    then
        dict['expected_version_file']="${KOOPA_PREFIX:?}/etc/koopa/\
bootstrap-version.txt"
        dict['installed_version_file']="${dict['bootstrap_prefix']}/VERSION"
        if [[ -f "${dict['expected_version_file']}" ]] \
            && [[ -f "${dict['installed_version_file']}" ]]
        then
            dict['expected_version']="$( \
                cat "${dict['expected_version_file']}" \
            )"
            dict['installed_version']="$( \
                cat "${dict['installed_version_file']}" \
            )"
            if [[ "${dict['installed_version']}" \
                != "${dict['expected_version']}" ]]
            then
                _koopa_warn "koopa bootstrap is out of date: \
${dict['installed_version']} != ${dict['expected_version']}."
                _koopa_warn "Run 'koopa install user bootstrap' to update."
                bool['warnings']=1
            fi
        else
            _koopa_warn 'koopa bootstrap is out of date.'
            _koopa_warn "Run 'koopa install user bootstrap' to update."
            bool['warnings']=1
        fi
    fi
    if _koopa_is_macos
    then
        dict['expected_r_version']="$( \
            _koopa_app_json_version 'r' \
        )"
        local r_bin
        for r_bin in \
            '/usr/local/bin/R' \
            '/Library/Frameworks/R.framework/Resources/bin/R'
        do
            [[ -x "$r_bin" ]] || continue
            dict['installed_r_version']="$( \
                _koopa_r_version "$r_bin" \
            )"
            if [[ "${dict['installed_r_version']}" \
                != "${dict['expected_r_version']}" ]]
            then
                _koopa_warn "System R is out of date at '${r_bin}': \
${dict['installed_r_version']} != ${dict['expected_r_version']}."
                bool['warnings']=1
            fi
        done
        dict['py_maj_min_ver']="$( \
            _koopa_python_major_minor_version \
        )"
        dict['expected_python_version']="$( \
            _koopa_app_json_version \
                "python${dict['py_maj_min_ver']}" \
        )"
        local python_bin
        for python_bin in \
            '/usr/local/bin/python3' \
            '/Library/Frameworks/Python.framework/Versions/Current/bin/python3'
        do
            [[ -x "$python_bin" ]] || continue
            dict['installed_python_version']="$( \
                _koopa_get_version "$python_bin" \
            )"
            if [[ "${dict['installed_python_version']}" \
                != "${dict['expected_python_version']}" ]]
            then
                _koopa_warn "System Python is out of date \
at '${python_bin}': ${dict['installed_python_version']} \
!= ${dict['expected_python_version']}."
                bool['warnings']=1
            fi
        done
    fi
    _koopa_python_script 'check-system.py'
    _koopa_check_disk '/'
    if [[ "${bool['warnings']}" -eq 1 ]]
    then
        _koopa_warn 'System checks completed with warnings.'
        return 1
    fi
    _koopa_alert_success 'System passed all checks.'
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

_koopa_cli() {
    local -A bool dict
    _koopa_assert_has_args "$#"
    bool['nested']=0
    case "${!#}" in
        '--help' | \
        '-h')
            set -- "${@:1:$(($#-1))}"
            dict['key']="$(_koopa_paste --sep='/' "$@")"
            dict['man_file']="$(_koopa_man_prefix)/man1/koopa/${dict['key']}.1"
            _koopa_assert_is_file "${dict['man_file']}"
            _koopa_help "${dict['man_file']}"
            ;;
    esac
    case "${1:?}" in
        '--version' | \
        '-V' | \
        'version')
            dict['key']='koopa-version'
            shift 1
            ;;
        'header' | \
        'install-all-apps' | \
        'install-default-apps')
            dict['key']="$1"
            shift 1
            ;;
        'app' | \
        'configure' | \
        'develop' | \
        'install' | \
        'reinstall' | \
        'system' | \
        'uninstall' | \
        'update')
            bool['nested']=1
            dict['key']="cli-${1}"
            shift 1
            ;;
        *)
            _koopa_cli_invalid_arg "$@"
            ;;
    esac
    if [[ "${bool['nested']}"  -eq 1 ]]
    then
        dict['fun']="_koopa_${dict['key']//-/_}"
        _koopa_assert_is_function "${dict['fun']}"
    else
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
    fi
    if ! _koopa_is_function "${dict['fun']}"
    then
        _koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
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

_koopa_cmake_build() {
    local -A app dict
    local -a build_deps cmake_args cmake_std_args pos
    _koopa_assert_has_args "$#"
    build_deps=('cmake')
    app['cmake']="$(_koopa_locate_cmake)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bin_dir']=''
    dict['build_dir']=''
    dict['generator']='Unix Makefiles'
    dict['include_dir']=''
    dict['jobs']="$(_koopa_cpu_count)"
    dict['lib_dir']=''
    dict['prefix']=''
    dict['source_dir']="$(_koopa_realpath "${PWD:?}")"
    cmake_std_args=()
    pos=()
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
            '--build-dir='*)
                dict['build_dir']="${1#*=}"
                shift 1
                ;;
            '--build-dir')
                dict['build_dir']="${2:?}"
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
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
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
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--ninja')
                dict['generator']='Ninja'
                shift 1
                ;;
            '-D'*)
                pos+=("$1")
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--source-dir' "${dict['source_dir']}"
    _koopa_assert_is_dir "${dict['source_dir']}"
    if [[ -z "${dict['build_dir']}" ]]
    then
        dict['build_dir']="${dict['source_dir']}-cmake-$(_koopa_random_string)"
    fi
    dict['build_dir']="$(_koopa_init_dir "${dict['build_dir']}")"
    cmake_std_args+=("--prefix=${dict['prefix']}")
    if [[ -n "${dict['bin_dir']}" ]]
    then
        cmake_std_args+=("--bin-dir=${dict['bin_dir']}")
    fi
    if [[ -n "${dict['include_dir']}" ]]
    then
        cmake_std_args+=("--include-dir=${dict['include_dir']}")
    fi
    if [[ -n "${dict['lib_dir']}" ]]
    then
        cmake_std_args+=("--lib-dir=${dict['lib_dir']}")
    fi
    readarray -t cmake_args <<< "$(_koopa_cmake_std_args "${cmake_std_args[@]}")"
    [[ "$#" -gt 0 ]] && cmake_args+=("$@")
    case "${dict['generator']}" in
        'Ninja')
            build_deps+=('ninja')
            ;;
        'Unix Makefiles')
            build_deps+=('make')
            ;;
        *)
            _koopa_stop 'Unsupported generator.'
            ;;
    esac
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_print_env
    _koopa_dl \
        'CMake args' "${cmake_args[*]}" \
        'build dir' "${dict['build_dir']}" \
        'source dir' "${dict['source_dir']}"
    "${app['cmake']}" -LH \
        '-B' "${dict['build_dir']}" \
        '-G' "${dict['generator']}" \
        '-S' "${dict['source_dir']}" \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build "${dict['build_dir']}" \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" \
        --install "${dict['build_dir']}" \
        --prefix "${dict['prefix']}"
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

_koopa_conda_activate_env() { # {{{1
    local -A bool dict
    _koopa_assert_has_args_eq "$#" 1
    if _koopa_is_conda_env_active
    then
        _koopa_stop 'Conda environment is already active.'
    fi
    bool['nounset']="$(_koopa_boolean_nounset)"
    dict['env']="${1:?}"
    [[ "${bool['nounset']}" -eq 1 ]] && set +u
    _koopa_activate_conda
    conda activate "${dict['env']}"
    [[ "${bool['nounset']}" -eq 1 ]] && set -u
    return 0
}

_koopa_conda_bin_names() {
    _koopa_assert_has_args_eq "$#" 1
    _koopa_python_script 'conda-bin-names.py' "$@"
    return 0
}

_koopa_conda_create_env() {
    local -A app bool dict
    local -a pos
    local string
    _koopa_assert_has_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['force']=0
    bool['latest']=0
    bool['tmp_pkg_cache_prefix']=0
    dict['env_prefix']="$(_koopa_conda_env_prefix)"
    dict['pkg_cache_prefix']="${CONDA_PKGS_DIRS:-}"
    dict['prefix']=''
    dict['yaml_file']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--channel='*)
                pos+=("$1")
                shift 1
                ;;
            '--channel')
                pos+=("$1" "$2")
                shift 2
                ;;
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
                shift 2
                ;;
            '--package-cache-prefix='*)
                dict['pkg_cache_prefix']="${1#*=}"
                shift 1
                ;;
            '--package-cache-prefix')
                dict['pkg_cache_prefix']="${2:?}"
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
            '--force' | \
            '--reinstall')
                bool['force']=1
                shift 1
                ;;
            '--latest')
                bool['latest']=1
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
    if [[ -z "${dict['pkg_cache_prefix']}" ]]
    then
        bool['tmp_pkg_cache_prefix']=1
        dict['pkg_cache_prefix']="$(_koopa_tmp_dir)"
    fi
    _koopa_dl 'conda package cache' "${dict['pkg_cache_prefix']}"
    export CONDA_PKGS_DIRS="${dict['pkg_cache_prefix']}"
    if [[ -n "${dict['yaml_file']}" ]]
    then
        _koopa_assert_has_no_args "$#"
        _koopa_assert_is_dir "${dict['prefix']}"
        [[ "${bool['force']}" -eq 0 ]] || return 1
        [[ "${bool['latest']}" -eq 0 ]] || return 1
        _koopa_assert_is_file "${dict['yaml_file']}"
        dict['yaml_file']="$(_koopa_realpath "${dict['yaml_file']}")"
        _koopa_dl 'conda recipe file' "${dict['yaml_file']}"
        "${app['conda']}" env create \
            --file "${dict['yaml_file']}" \
            --prefix "${dict['prefix']}" \
            --quiet
        return 0
    elif [[ -n "${dict['prefix']}" ]]
    then
        _koopa_assert_has_args "$#"
        _koopa_assert_is_dir "${dict['prefix']}"
        [[ "${bool['force']}" -eq 0 ]] || return 1
        [[ "${bool['latest']}" -eq 0 ]] || return 1
        "${app['conda']}" create \
            --prefix "${dict['prefix']}" \
            --quiet \
            --yes \
            "$@"
        return 0
    fi
    _koopa_assert_has_args "$#"
    [[ -z "${dict['yaml_file']}" ]] || return 1
    for string in "$@"
    do
        local -A dict2
        dict2['env_string']="${string//@/=}"
        if [[ "${bool['latest']}" -eq 1 ]]
        then
            if _koopa_str_detect_fixed \
                --string="${dict2['env_string']}" \
                --pattern='='
            then
                _koopa_stop "Don't specify version when using '--latest'."
            fi
            _koopa_alert "Obtaining latest version for '${dict2['env_string']}'."
            dict2['env_version']="$( \
                _koopa_conda_env_latest_version "${dict2['env_string']}" \
            )"
            [[ -n "${dict2['env_version']}" ]] || return 1
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        elif ! _koopa_str_detect_fixed \
            --string="${dict2['env_string']}" \
            --pattern='='
        then
            dict2['env_version']="$( \
                _koopa_app_json_version "${dict2['env_string']}" \
                || true \
            )"
            if [[ -z "${dict2['env_version']}" ]]
            then
                _koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        fi
        dict2['env_name']="$( \
            _koopa_print "${dict2['env_string']//=/@}" \
            | "${app['cut']}" -d '@' -f '1-2' \
        )"
        dict2['env_prefix']="${dict['env_prefix']}/${dict2['env_name']}"
        if [[ -d "${dict2['env_prefix']}" ]]
        then
            if [[ "${bool['force']}" -eq 1 ]]
            then
                _koopa_conda_remove_env "${dict2['env_name']}"
            else
                _koopa_alert_note "Conda environment '${dict2['env_name']}' \
exists at '${dict2['env_prefix']}'."
                continue
            fi
        fi
        _koopa_alert_install_start \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
        "${app['conda']}" create \
            --name="${dict2['env_name']}" \
            --quiet \
            --yes \
            "${dict2['env_string']}"
        _koopa_alert_install_success \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
    done
    if [[ "${bool['tmp_pkg_cache_prefix']}" -eq 1 ]]
    then
        _koopa_rm "${dict['pkg_cache_prefix']}"
    fi
    return 0
}

_koopa_conda_deactivate() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['env_name']="${CONDA_DEFAULT_ENV:-}"
    dict['nounset']="$(_koopa_boolean_nounset)"
    if [[ -z "${dict['env_name']}" ]]
    then
        _koopa_stop 'conda is not active.'
    fi
    _koopa_assert_is_function 'conda'
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    conda deactivate
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_conda_env_latest_version() {
    local -A app dict
    local str
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk)"
    app['conda']="$(_koopa_locate_conda)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:?}"
    str="$( \
        "${app['conda']}" search --quiet "${dict['env_name']}" \
            | "${app['tail']}" -n 1 \
            | "${app['awk']}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
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

_koopa_conda_remove_env() {
    local -A app dict
    local name
    _koopa_assert_has_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    dict['nounset']="$(_koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict['prefix']="$(_koopa_conda_env_prefix "$name")"
        _koopa_assert_is_dir "${dict['prefix']}"
        dict['name']="$(_koopa_basename "${dict['prefix']}")"
        _koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        "${app['conda']}" env remove --name="${dict['name']}" --yes
        [[ -d "${dict['prefix']}" ]] && _koopa_rm "${dict['prefix']}"
        _koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_configure_app() {
    local -A bool dict
    local -a pos
    bool['verbose']=0
    dict['config_fun']='main'
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
    pos=()
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '-*')
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    case "${dict['mode']}" in
        'shared')
            _koopa_assert_is_owner
            ;;
        'system')
            _koopa_assert_is_owner
            _koopa_assert_is_admin
            ;;
        'user')
            _koopa_assert_is_not_root
            ;;
    esac
    dict['config_file']="$(_koopa_bash_prefix)/include/configure/\
${dict['platform']}/${dict['mode']}/${dict['name']}.sh"
    _koopa_assert_is_file "${dict['config_file']}"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    (
        case "${dict['mode']}" in
            'system')
                _koopa_add_to_path_end '/usr/sbin' '/sbin'
                ;;
        esac
        _koopa_cd "${dict['tmp_dir']}"
        source "${dict['config_file']}"
        _koopa_assert_is_function "${dict['config_fun']}"
        "${dict['config_fun']}" "$@"
    )
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_configure_r() {
    _koopa_configure_app \
        --name='r' \
        "$@"
}

_koopa_configure_system_r() {
    local -A app
    app['r']="$(_koopa_locate_system_r)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_configure_r "${app['r']}"
    return 0
}

_koopa_configure_user_dotfiles() {
    _koopa_configure_app \
        --name='dotfiles' \
        --user \
        "$@"
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

_koopa_delete_broken_symlinks() {
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a files
        local file
        readarray -t files <<< "$(_koopa_find_broken_symlinks "$prefix")"
        _koopa_is_array_non_empty "${files[@]:-}" || continue
        _koopa_alert_note "Removing ${#files[@]} broken symlinks."
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            _koopa_alert "Removing '${file}'."
            _koopa_rm "$file"
        done
    done
    return 0
}

_koopa_delete_dotfile() {
    local -A dict
    local -a pos
    local name
    _koopa_assert_has_args "$#"
    dict['config']=0
    dict['xdg_config_home']="$(_koopa_xdg_config_home)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--config')
                dict['config']=1
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
    for name in "$@"
    do
        local filepath
        if [[ "${dict['config']}" -eq 1 ]]
        then
            filepath="${dict['xdg_config_home']}/${name}"
        else
            filepath="${HOME:?}/.${name}"
        fi
        if [[ -L "$filepath" ]]
        then
            _koopa_alert "Removing '${filepath}'."
            _koopa_rm "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            _koopa_warn "Not a symlink: '${filepath}'."
        fi
    done
    return 0
}

_koopa_delete_empty_dirs() {
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(_koopa_find_empty_dirs "$prefix")" ]]
        do
            local -a dirs
            local dir
            readarray -t dirs <<< "$(_koopa_find_empty_dirs "$prefix")"
            _koopa_is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                _koopa_alert "Deleting '${dir}'."
                _koopa_rm "$dir"
            done
        done
    done
    return 0
}

_koopa_delete_named_subdirs() {
    local -A dict
    local -a matches
    _koopa_assert_has_args_eq "$#" 2
    dict['prefix']="${1:?}"
    dict['subdir_name']="${2:?}"
    readarray -t matches <<< "$( \
        _koopa_find \
            --pattern="${dict['subdir_name']}" \
            --prefix="${dict['prefix']}" \
            --type='d' \
    )"
    _koopa_is_array_non_empty "${matches[@]:-}" || return 1
    _koopa_print "${matches[@]}"
    _koopa_rm "${matches[@]}"
    return 0
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

_koopa_disable_passwordless_sudo() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['group']="$(_koopa_admin_group_name)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -f "${dict['file']}" ]]
    then
        _koopa_alert "Removing sudo permission file at '${dict['file']}'."
        _koopa_rm --sudo "${dict['file']}"
    fi
    _koopa_alert_success 'Passwordless sudo is disabled.'
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

_koopa_enable_passwordless_sudo() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['group']="$(_koopa_admin_group_name)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -e "${dict['file']}" ]]
    then
        _koopa_alert_success "Passwordless sudo for '${dict['group']}' group \
already enabled at '${dict['file']}'."
        return 0
    fi
    _koopa_alert "Modifying '${dict['file']}' to include '${dict['group']}'."
    dict['string']="%${dict['group']} ALL=(ALL:ALL) NOPASSWD:ALL"
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    _koopa_chmod --sudo '0440' "${dict['file']}"
    _koopa_alert_success "Passwordless sudo enabled for '${dict['group']}' \
at '${dict['file']}'."
    return 0
}

_koopa_enable_shell_for_all_users() {
    local -A dict
    local -a apps
    local app
    _koopa_assert_has_args "$#"
    _koopa_is_admin || return 0
    dict['etc_file']='/etc/shells'
    dict['user']="$(_koopa_user_name)"
    apps=("$@")
    for app in "${apps[@]}"
    do
        if _koopa_file_detect_fixed \
            --file="${dict['etc_file']}" \
            --pattern="$app"
        then
            continue
        fi
        _koopa_alert "Updating '${dict['etc_file']}' to include '${app}'."
        _koopa_sudo_append_string \
            --file="${dict['etc_file']}" \
            --string="$app"
        _koopa_alert_info "Run 'chsh -s ${app} ${dict['user']}' to change the \
default shell."
    done
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

_koopa_fasta_generate_chromosomes_file() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['grep']="$(_koopa_locate_grep)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_file']=''
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict['output_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-file' "${dict['output_file']}"
    _koopa_assert_is_not_file "${dict['output_file']}"
    _koopa_assert_is_file "${dict['genome_fasta_file']}"
    _koopa_alert "Generating '${dict['output_file']}' from \
'${dict['genome_fasta_file']}'."
    "${app['grep']}" '^>' \
        <(_koopa_decompress --stdout "${dict['genome_fasta_file']}") \
        | "${app['cut']}" -d ' ' -f '1' \
        > "${dict['output_file']}"
    "${app['sed']}" \
        -i.bak \
        's/>//g' \
        "${dict['output_file']}"
    _koopa_assert_is_file "${dict['output_file']}"
    return 0
}

_koopa_fasta_generate_decoy_transcriptome_file() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_file']=''
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict['output_file']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-file' "${dict['output_file']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_not_file "${dict['output_file']}"
    _koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['transcriptome_fasta_file']}"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    _koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['genome_fasta_file']}"
    _koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['output_file']}"
    _koopa_alert "Generating decoy-aware transcriptome \
at '${dict['output_file']}'."
    _koopa_dl \
        'Genome FASTA file' "${dict['genome_fasta_file']}" \
        'Transcriptome FASTA file' "${dict['transcriptome_fasta_file']}"
    "${app['cat']}" \
        "${dict['transcriptome_fasta_file']}" \
        "${dict['genome_fasta_file']}" \
        > "${dict['output_file']}"
    _koopa_assert_is_file "${dict['output_file']}"
    return 0
}

_koopa_fasta_has_alt_contigs() {
    local -A bool dict
    _koopa_assert_has_args_eq "$#" 1
    bool['tmp_file']=0
    dict['file']="${1:?}"
    dict['status']=1
    _koopa_assert_is_file "${dict['file']}"
    if _koopa_is_compressed_file "${dict['file']}"
    then
        bool['tmp_file']=1
        dict['tmp_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['file']}" \
            --output-file="${dict['tmp_file']}"
        dict['file']="${dict['tmp_file']}"
    fi
    if _koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' ALT_' \
    || _koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' alternate locus group ' \
    || _koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' rl:alt-scaffold '
    then
        dict['status']=0
    fi
    if [[ "${bool['tmp_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['file']}"
    fi
    return "${dict['status']}"
}

_koopa_fasta_pattern() {
    _koopa_print '\.(fa|fasta|fna)'
    return 0
}

_koopa_fastq_detect_quality_score() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['od']="$(_koopa_locate_od --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$( \
            "${app['head']}" -n 1000 \
                <(_koopa_decompress --stdout "$file") \
            | "${app['awk']}" '{if(NR%4==0) printf("%s",$0);}' \
            | "${app['od']}" \
                --address-radix='n' \
                --format='u1' \
            | "${app['awk']}" 'BEGIN{min=100;max=0;} \
                {for(i=1;i<=NF;i++) \
                    {if($i>max) max=$i; \
                        if($i<min) min=$i;}}END \
                    {if(max<=74 && min<59) \
                        print "Phred+33"; \
                    else if(max>73 && min>=64) \
                        print "Phred+64"; \
                    else if(min>=59 && min<64 && max>73) \
                        print "Solexa+64"; \
                    else print "Unknown"; \
                }' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_fastq_lanepool() {
    local -A app dict
    local -a bns fastq_files head out tail
    local bn file i
    app['cat']="$(_koopa_locate_cat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']='*_L001_*.fastq*'
    dict['prefix']='lanepool'
    dict['source_dir']=''
    dict['target_dir']=''
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
        '--prefix' "${dict['prefix']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    _koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(_koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['pattern']}" \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_files[@]}"
    then
        _koopa_stop "No lane-split FASTQ files matching pattern \
'${dict['pattern']}' in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    for file in "${fastq_files[@]}"
    do
        bns+=("$(_koopa_basename "$file")")
    done
    for bn in "${bns[@]}"
    do
        head+=("${bn//_L001_*/}")
        tail+=("${bn//*_L001_/}")
        out+=("${dict['target_dir']}/${dict['prefix']}_${bn//_L001/}")
    done
    for i in "${!fastq_files[@]}"
    do
        "${app['cat']}" \
            "${dict['source_dir']}/${head[$i]}_L"*"_${tail[$i]}" \
            > "${out[$i]}"
    done
    return 0
}

_koopa_fastq_number_of_reads() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local num
        num="$( \
            "${app['wc']}" -l \
                <(_koopa_decompress --stdout "$file") \
            | "${app['awk']}" '{print $1/4}' \
        )"
        [[ -n "$num" ]] || return 1
        _koopa_print "$num"
    done
    return 0
}

_koopa_fastq_read_length() {
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk)"
    app['head']="$(_koopa_locate_head)"
    app['sort']="$(_koopa_locate_sort)"
    app['uniq']="$(_koopa_locate_uniq)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local length
        length="$( \
            _koopa_decompress --stdout "$file" \
                | "${app['awk']}" 'NR%4==2 {print length}' \
                | "${app['sort']}" -n \
                | "${app['uniq']}" -c \
                | "${app['sort']}" -hr \
                | "${app['head']}" -1 \
                | "${app['awk']}" '{print $2}' \
        )"
        [[ -n "$length" ]] || return 1
        _koopa_print "$length"
    done
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

_koopa_gpg_prompt() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['gpg']="$(_koopa_locate_gpg --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    printf '' | "${app['gpg']}" -s
    return 0
}

_koopa_gpg_reload() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['gpg_connect_agent']="$(_koopa_locate_gpg_connect_agent)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['gpg_connect_agent']}" reloadagent '/bye'
    return 0
}

_koopa_gpg_restart() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['gpgconf']="$(_koopa_locate_gpgconf)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['gpgconf']}" --kill 'gpg-agent'
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
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    if [[ "${dict['ssl_cert_file']}" == "${dict['_koopa_prefix']}/"* ]]
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

_koopa_hisat2_align_paired_end_per_sample() {
    local -A app bool dict
    local -a align_args
    app['hisat2']="$(_koopa_locate_hisat2)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['salmon_index_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--salmon-index-dir='*)
                dict['salmon_index_dir']="${1#*=}"
                shift 1
                ;;
            '--salmon-index-dir')
                dict['salmon_index_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_assert_is_set '--salmon-index-dir' "${dict['salmon_index_dir']}"
        _koopa_assert_is_dir "${dict['salmon_index_dir']}"
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['hisat2_idx']="${dict['index_dir']}/index"
    _koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(_koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(_koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(_koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(_koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['sample_bn']="$(_koopa_basename "${dict['output_dir']}")"
    dict['sam_file']="${dict['output_dir']}/${dict['sample_bn']}.sam"
    dict['bam_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.bam' \
            "${dict['sam_file']}" \
    )"
    dict['log_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.log' \
            "${dict['sam_file']}" \
    )"
    _koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['fastq_r1_file']}"
    then
        bool['tmp_fastq_r1_file']=1
        dict['tmp_fastq_r1_file']="$(_koopa_tmp_file_in_wd --ext='fastq')"
        _koopa_decompress \
            --input-file="${dict['fastq_r1_file']}" \
            --output-file="${dict['tmp_fastq_r1_file']}"
        dict['fastq_r1_file']="${dict['tmp_fastq_r1_file']}"
    fi
    if _koopa_is_compressed_file "${dict['fastq_r2_file']}"
    then
        bool['tmp_fastq_r2_file']=1
        dict['tmp_fastq_r2_file']="$(_koopa_tmp_file_in_wd --ext='fastq')"
        _koopa_decompress \
            --input-file="${dict['fastq_r2_file']}" \
            --output-file="${dict['tmp_fastq_r2_file']}"
        dict['fastq_r2_file']="${dict['tmp_fastq_r2_file']}"
    fi
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_alert 'Detecting FASTQ library type with salmon.'
        dict['lib_type']="$( \
            _koopa_salmon_detect_fastq_library_type \
                --fastq-r1-file="${dict['fastq_r1_file']}" \
                --fastq-r2-file="${dict['fastq_r2_file']}" \
                --index-dir="${dict['salmon_index_dir']}" \
        )"
    fi
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_hisat2 "${dict['lib_type']}" \
    )"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        _koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    align_args+=(
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    _koopa_dl 'Align args' "${align_args[*]}"
    "${app['hisat2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r2_file']}"
    fi
    _koopa_samtools_convert_sam_to_bam "${dict['sam_file']}"
    _koopa_samtools_sort_bam "${dict['bam_file']}"
    _koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}

_koopa_hisat2_align_paired_end() {
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    dict['salmon_index_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--salmon-index-dir='*)
                dict['salmon_index_dir']="${1#*=}"
                shift 1
                ;;
            '--salmon-index-dir')
                dict['salmon_index_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_assert_is_set '--salmon-index-dir' "${dict['salmon_index_dir']}"
        _koopa_assert_is_dir "${dict['salmon_index_dir']}"
        dict['salmon_index_dir']="$( \
            _koopa_realpath "${dict['salmon_index_dir']}" \
        )"
    fi
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running HISAT2 aligner.'
    _koopa_dl \
        'Mode' 'paired-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement="${dict['fastq_r2_tail']}" \
                "${dict2['fastq_r1_file']}" \
        )"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_r1_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_hisat2_align_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}" \
            --salmon-index-dir="${dict['salmon_index_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

_koopa_hisat2_align_single_end_per_sample() {
    local -A app bool dict
    local -a align_args
    _koopa_assert_has_args "$#"
    app['hisat2']="$(_koopa_locate_hisat2)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_file']=0
    dict['fastq_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['hisat2_idx']="${dict['index_dir']}/index"
    _koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(_koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(_koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['sample_bn']="$(_koopa_basename "${dict['output_dir']}")"
    dict['sam_file']="${dict['output_dir']}/${dict['sample_bn']}.sam"
    dict['bam_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.bam' \
            "${dict['sam_file']}" \
    )"
    dict['log_file']="$( \
        _koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.log' \
            "${dict['sam_file']}" \
    )"
    _koopa_alert "Quantifying '${dict['fastq_bn']}' in '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['fastq_file']}"
    then
        bool['tmp_fastq_file']=1
        dict['tmp_fastq_file']="$(_koopa_tmp_file_in_wd --ext='fastq')"
        _koopa_decompress \
            --input-file="${dict['fastq_file']}" \
            --output-file="${dict['tmp_fastq_file']}"
        dict['fastq_file']="${dict['tmp_fastq_file']}"
    fi
    align_args+=(
        '-S' "${dict['sam_file']}"
        '-U' "${dict['fastq_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_hisat2 "${dict['lib_type']}" \
    )"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        _koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    _koopa_dl 'Align args' "${align_args[*]}"
    "${app['hisat2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r2_file']}"
    fi
    _koopa_samtools_convert_sam_to_bam "${dict['sam_file']}"
    _koopa_samtools_sort_bam "${dict['bam_file']}"
    _koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}

_koopa_hisat2_align_single_end() {
    local -A app bool dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running HISAT2 aligner.'
    _koopa_dl \
        'Mode' 'single-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        local -A dict2
        dict2['fastq_file']="$fastq_file"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_hisat2_align_single_end_per_sample \
            --fastq-file="${dict2['fastq_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

_koopa_hisat2_fastq_quality_format() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['fastq_file']="${1:?}"
    _koopa_assert_is_file "${dict['fastq_file']}"
    dict['format']="$(_koopa_fastq_detect_quality_score "${dict['fastq_file']}")"
    case "${dict['format']}" in
        'Phred+33')
            dict['flag']='--phred33'
            ;;
        'Phred+64')
            dict['flag']='--phred64'
            ;;
        *)
            return 0
            ;;
    esac
    _koopa_print "${dict['flag']}"
    return 0
}

_koopa_hisat2_index() {
    local -A app bool dict
    local -a index_args
    app['hisat2_build']="$(_koopa_locate_hisat2_build)"
    app['hisat2_extract_exons']="$(_koopa_locate_hisat2_extract_exons)"
    app['hisat2_extract_splice_sites']="$( \
        _koopa_locate_hisat2_extract_splice_sites \
    )"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_genome_fasta_file']=0
    bool['tmp_gtf_file']=0
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=160
    dict['output_dir']=''
    dict['seed']=42
    dict['threads']="$(_koopa_cpu_count)"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "'hisat2-build' requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['ht2_base']="${dict['output_dir']}/index"
    _koopa_alert "Generating HISAT2 index at '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['genome_fasta_file']}"
    then
        bool['tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['tmp_genome_fasta_file']}"
        dict['genome_fasta_file']="${dict['tmp_genome_fasta_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    dict['exons_file']="${dict['output_dir']}/exons.tsv"
    dict['splice_sites_file']="${dict['output_dir']}/splicesites.tsv"
    "${app['hisat2_extract_exons']}" \
        "${dict['gtf_file']}" \
        > "${dict['exons_file']}"
    "${app['hisat2_extract_splice_sites']}" \
        "${dict['gtf_file']}" \
        > "${dict['splice_sites_file']}"
    index_args+=(
        '-p' "${dict['threads']}"
        '--exon' "${dict['exons_file']}"
        '--seed' "${dict['seed']}"
        '--ss' "${dict['splice_sites_file']}"
        "${dict['genome_fasta_file']}"
        "${dict['ht2_base']}"
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['hisat2_build']}" "${index_args[@]}"
    if [[ "${bool['tmp_genome_fasta_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['genome_fasta_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_alert_success "HISAT2 index created at '${dict['output_dir']}'."
    return 0
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

_koopa_jekyll_deploy_to_aws() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    app['bundle']="$(_koopa_locate_bundle)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bucket_prefix']=''
    dict['bundle_prefix']="$(_koopa_xdg_data_home)/gem"
    dict['distribution_id']=''
    dict['local_prefix']="${PWD:?}"
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket_prefix']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket_prefix']="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                dict['distribution_id']="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                dict['distribution_id']="${2:?}"
                shift 2
                ;;
            '--local-prefix='*)
                dict['local_prefix']="${1#*=}"
                shift 1
                ;;
            '--local-prefix')
                dict['local_prefix']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket_prefix']:-}" \
        '--distribution-id' "${dict['distribution_id']:-}" \
        '--profile' "${dict['profile']:-}"
    _koopa_assert_is_dir "${dict['local_prefix']}"
    dict['local_prefix']="$( \
        _koopa_realpath "${dict['local_prefix']}" \
    )"
    dict['bucket_prefix']="$( \
        _koopa_strip_trailing_slash "${dict['bucket_prefix']}" \
    )"
    _koopa_alert "Deploying '${dict['local_prefix']}' \
to '${dict['bucket_prefix']}'."
    (
        _koopa_cd "${dict['local_prefix']}"
        _koopa_assert_is_file 'Gemfile'
        _koopa_dl 'Bundle prefix' "${dict['bundle_prefix']}"
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && _koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll build
        _koopa_rm 'Gemfile.lock'
    )
    _koopa_aws_s3_sync --profile="${dict['profile']}" \
        "${dict['local_prefix']}/_site/" \
        "${dict['bucket_prefix']}/"
    _koopa_alert "Invalidating CloudFront cache at '${dict['distribution_id']}'."
    "${app['aws']}" cloudfront create-invalidation \
        --distribution-id "${dict['distribution_id']}" \
        --no-cli-pager \
        --output 'text' \
        --paths '/*' \
        --profile "${dict['profile']}"
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

_koopa_kallisto_index() {
    local -A app dict
    local -a index_args
    _koopa_assert_has_args "$#"
    app['kallisto']="$(_koopa_locate_kallisto)"
    _koopa_assert_is_executable "${app[@]}"
    dict['fasta_pattern']="$(_koopa_fasta_pattern)"
    dict['kmer_size']=31
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    dict['version']="$(_koopa_app_version 'kallisto')"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "kallisto index requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    _koopa_assert_is_matching_regex \
        --pattern="${dict['fasta_pattern']}" \
        --string="${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['index_file']="${dict['output_dir']}/kallisto.idx"
    _koopa_alert "Generating kallisto index at '${dict['output_dir']}'."
    index_args+=(
        "--index=${dict['index_file']}"
        "--kmer-size=${dict['kmer_size']}"
        '--make-unique'
    )
    case "${dict['version']}" in
        '0.50.'*)
            index_args+=("--threads=${dict['threads']}")
            ;;
    esac
    index_args+=("${dict['transcriptome_fasta_file']}")
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['kallisto']}" index "${index_args[@]}"
    _koopa_alert_success "kallisto index created at '${dict['output_dir']}'."
    return 0
}

_koopa_kallisto_quant_paired_end_per_sample() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['kallisto']="$(_koopa_locate_kallisto)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['salmon_index_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--salmon-index-dir='*)
                dict['salmon_index_dir']="${1#*=}"
                shift 1
                ;;
            '--salmon-index-dir')
                dict['salmon_index_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_assert_is_set '--salmon-index-dir' "${dict['salmon_index_dir']}"
        _koopa_assert_is_dir "${dict['salmon_index_dir']}"
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    _koopa_assert_is_file \
        "${dict['fastq_r1_file']}" \
        "${dict['fastq_r2_file']}" \
        "${dict['index_file']}"
    dict['fastq_r1_file']="$(_koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(_koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(_koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(_koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' into '${dict['output_dir']}'."
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_alert 'Detecting FASTQ library type with salmon.'
        dict['lib_type']="$( \
            _koopa_salmon_detect_fastq_library_type \
                --fastq-r1-file="${dict['fastq_r1_file']}" \
                --fastq-r2-file="${dict['fastq_r2_file']}" \
                --index-dir="${dict['salmon_index_dir']}" \
        )"
    fi
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_kallisto "${dict['lib_type']}" \
    )"
    if [[ -n "${dict['lib_type']}" ]]
    then
        quant_args+=("${dict['lib_type']}")
    fi
    quant_args+=(
        '--bias'
        "--bootstrap-samples=${dict['bootstraps']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--threads=${dict['threads']}"
        '--verbose'
    )
    quant_args+=("${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}")
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}

_koopa_kallisto_quant_paired_end() {
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    dict['salmon_index_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--salmon-index-dir='*)
                dict['salmon_index_dir']="${1#*=}"
                shift 1
                ;;
            '--salmon-index-dir')
                dict['salmon_index_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_assert_is_set '--salmon-index-dir' "${dict['salmon_index_dir']}"
        _koopa_assert_is_dir "${dict['salmon_index_dir']}"
        dict['salmon_index_dir']="$( \
            _koopa_realpath "${dict['salmon_index_dir']}" \
        )"
    fi
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running kallisto quant.'
    _koopa_dl \
        'Mode' 'paired-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    _koopa_assert_is_file "${fastq_r1_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement="${dict['fastq_r2_tail']}" \
                "${dict2['fastq_r1_file']}" \
        )"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_r1_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_kallisto_quant_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}" \
            --salmon-index-dir="${dict['salmon_index_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'kallisto quant was successful.'
    return 0
}

_koopa_kallisto_quant_single_end_per_sample() {
    local -A app dict
    local -a quant_args
    app['kallisto']="$(_koopa_locate_kallisto)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_file']=''
    dict['fragment_length']=200
    dict['index_dir']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['sd']=25
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict['fragment_length']="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict['fragment_length']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fragment-length' "${dict['fragment_length']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    _koopa_assert_is_file "${dict['fastq_file']}" "${dict['index_file']}"
    dict['fastq_file']="$(_koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(_koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['fastq_bn']}' into \
'${dict['output_dir']}'."
    quant_args+=(
        "--bootstrap-samples=${dict['bootstraps']}"
        "--fragment-length=${dict['fragment_length']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--sd=${dict['sd']}"
        '--single'
        "--threads=${dict['threads']}"
        '--verbose'
    )
    quant_args+=("$fastq_file")
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}

_koopa_kallisto_quant_single_end() {
    local -A app bool dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq-tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running kallisto quant.'
    _koopa_dl \
        'Mode' 'single-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${fastq_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    _koopa_assert_is_file "${fastq_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        local -A dict2
        dict2['fastq_file']="$fastq_file"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_kallisto_quant_single_end_per_sample \
            --fastq-file="${dict2['fastq_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'kallisto quant was successful.'
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
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['version_file']="${dict['_koopa_prefix']}/VERSION"
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

_koopa_list_dotfiles() {
    _koopa_assert_has_no_args "$#"
    _koopa_h1 "Listing dotfiles in '${HOME:?}'."
    _koopa_find_dotfiles 'd' 'Directories'
    _koopa_find_dotfiles 'f' 'Files'
    _koopa_find_dotfiles 'l' 'Symlinks'
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
    _koopa_is_alias 'cut' && unalias 'cut'
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
    _koopa_is_alias 'cut' && unalias 'cut'
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
    _koopa_is_alias 'cut' && unalias 'cut'
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

_koopa_make_build() {
    local -A app dict
    local -a conf_args pos targets
    local target
    _koopa_assert_has_args "$#"
    case "${KOOPA_INSTALL_NAME:?}" in
        'aws-cli')
            app['make']="$(_koopa_locate_make --allow-system)"
            ;;
        'make')
            app['make']="$(_koopa_locate_make --only-system)"
            ;;
        *)
            app['make']="$(_koopa_locate_make)"
            ;;
    esac
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--target='*)
                targets+=("${1#*=}")
                shift 1
                ;;
            '--target')
                targets+=("${2:?}")
                shift 2
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if _koopa_is_array_empty "${targets[@]:-}"
    then
        targets+=('install')
    fi
    conf_args+=("$@")
    _koopa_print_env
    _koopa_dl 'configure args' "${conf_args[*]}"
    _koopa_assert_is_executable './configure'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    for target in "${targets[@]}"
    do
        "${app['make']}" "$target"
    done
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

_koopa_miso_index() {
    local -A app bool dict
    _koopa_activate_app_conda_env 'misopy'
    app['exon_utils']="$(_koopa_locate_miso_exon_utils --realpath)"
    app['index_gff']="$(_koopa_locate_miso_index_gff --realpath)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_gff_file']=0
    dict['gff_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=30
    dict['min_exon_size']=1000
    dict['output_dir']=''
    dict['tmp_exons_dir']="$(_koopa_tmp_dir_in_wd)"
    while (("$#"))
    do
        case "$1" in
            '--gff-file='*)
                dict['gff_file']="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict['gff_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--gff-file' "${dict['gff_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "MISO requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file "${dict['gff_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['gff_file']="$(_koopa_realpath "${dict['gff_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/index.log"
    _koopa_alert "Generating MISO index at '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['gff_file']}"
    then
        bool['tmp_gff_file']=1
        dict['tmp_gff_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gff_file']}" \
            --output-file="${dict['tmp_gff_file']}"
        dict['gff_file']="${dict['tmp_gff_file']}"
    fi
    export PYTHONUNBUFFERED=1
    "${app['exon_utils']}" \
        --get-const-exons "${dict['gff_file']}" \
        --min-exon-size "${dict['min_exon_size']}" \
        --output-dir "${dict['tmp_exons_dir']}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    dict['tmp_exons_gff_file']="$( \
        _koopa_find \
            --hidden \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.min_${dict['min_exon_size']}.const_exons.gff" \
            --prefix="${dict['tmp_exons_dir']}" \
            --type='f'
    )"
    _koopa_assert_is_file "${dict['tmp_exons_gff_file']}"
    _koopa_mv \
        "${dict['tmp_exons_gff_file']}" \
        "${dict['output_dir']}/min_${dict['min_exon_size']}.const_exons.gff"
    _koopa_rm "${dict['tmp_exons_dir']}"
    "${app['index_gff']}" \
        --index \
        "${dict['gff_file']}" \
        "${dict['output_dir']}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    unset -v PYTHONUNBUFFERED
    if [[ "${bool['tmp_gff_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gff_file']}"
    fi
    _koopa_alert_success "MISO index created at '${dict['output_dir']}'."
    return 0
}

_koopa_miso_run() {
    local -A app bool dict
    local -a miso_args
    _koopa_activate_app_conda_env 'misopy'
    _koopa_activate_app 'bedtools' 'samtools'
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['miso']="$(_koopa_locate_miso --realpath)"
    app['pe_utils']="$(_koopa_locate_miso_pe_utils --realpath)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['paired']=0
    dict['bam_file']=''
    dict['genome_fasta_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['num_proc']="$(_koopa_cpu_count)"
    dict['read_length']=''
    dict['output_dir']=''
    dict['read_type']=''
    while (("$#"))
    do
        case "$1" in
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--read-length='*)
                dict['read_length']="${1#*=}"
                shift 1
                ;;
            '--read-length')
                dict['read_length']="${2:?}"
                shift 2
                ;;
            '--read-type='*)
                dict['read_type']="${1#*=}"
                shift 1
                ;;
            '--read-type')
                dict['read_type']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "MISO requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    _koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['bam_file']}.bai" \
        "${dict['genome_fasta_file']}"
    _koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['bam_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/miso.log"
    dict['settings_file']="${dict['output_dir']}/settings.txt"
    _koopa_alert "Running MISO analysis in '${dict['output_dir']}'."
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            _koopa_salmon_detect_bam_library_type \
                --bam-file="${dict['bam_file']}" \
                --fasta-file="${dict['genome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_miso "${dict['lib_type']}" \
    )"
    if [[ -z "${dict['read_length']}" ]]
    then
        _koopa_alert 'Detecting BAM read length.'
        dict['read_length']="$(_koopa_bam_read_length "${dict['bam_file']}")"
    fi
    if [[ -z "${dict['read_type']}" ]]
    then
        _koopa_alert 'Detecting BAM read type.'
        dict['read_type']="$(_koopa_bam_read_type "${dict['bam_file']}")"
    fi
    case "${dict['read_type']}" in
        'paired')
            bool['paired']=1
            ;;
        'single')
            ;;
        *)
            _koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    read -r -d '' "dict[settings_string]" << END || true
[data]
filter_results = True
min_event_reads = 20
strand = ${dict['lib_type']}

[cluster]
cluster_command = qsub

[sampler]
burn_in = 500
lag = 10
num_iters = 5000
num_chains = 6
num_processors = ${dict['num_proc']}
END
    _koopa_write_string \
        --file="${dict['settings_file']}" \
        --string="${dict['settings_string']}"
    miso_args+=(
        '--run' "${dict['index_dir']}" "${dict['bam_file']}"
        '-p' "${dict['num_proc']}"
        '--output-dir' "${dict['output_dir']}"
        '--read-len' "${dict['read_length']}"
        '--settings-filename' "${dict['settings_file']}"
    )
    if [[ "${bool['paired']}" -eq 1 ]]
    then
        dict['exons_gff_file']="$( \
            _koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --pattern='*.const_exons.gff' \
                --prefix="${dict['index_dir']}" \
                --type='f' \
        )"
        _koopa_assert_is_file "${dict['exons_gff_file']}"
        dict['min_exon_size']=500
        dict['tmp_insert_dist_dir']="$(_koopa_tmp_dir_in_wd)"
        "${app['pe_utils']}" \
            --compute-insert-len \
                "${dict['bam_file']}" \
                "${dict['exons_gff_file']}" \
            --min-exon-size="${dict['min_exon_size']}" \
            --output-dir "${dict['tmp_insert_dist_dir']}"
        dict['insert_length_file']="$( \
            _koopa_find \
                --hidden \
                --max-depth=1 \
                --min-depth=1 \
                --pattern='*.insert_len' \
                --prefix="${dict['tmp_insert_dist_dir']}" \
                --type='f' \
        )"
        _koopa_assert_is_file "${dict['insert_length_file']}"
        dict['insert_length_mean']="$( \
            "${app['head']}" -n 1 "${dict['insert_length_file']}" \
                | "${app['cut']}" -d ',' -f 1 \
                | "${app['cut']}" -d '=' -f 2 \
        )"
        dict['insert_length_sdev']="$( \
            "${app['head']}" -n 1 "${dict['insert_length_file']}" \
                | "${app['cut']}" -d ',' -f 2 \
                | "${app['cut']}" -d '=' -f 2 \
        )"
        miso_args+=(
            '--paired-end'
                "${dict['insert_length_mean']}"
                "${dict['insert_length_sdev']}"
        )
        _koopa_rm "${dict['tmp_insert_dist_dir']}"
    fi
    _koopa_dl 'miso' "${miso_args[*]}"
    _koopa_print "${app['miso']} ${miso_args[*]}" >> "${dict['log_file']}"
    "${app['miso']}" "${miso_args[@]}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
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

_koopa_prune_app_binaries() {
    _koopa_assert_has_no_args "$#"
    _koopa_assert_can_push_binary
    _koopa_python_script 'prune-app-binaries.py'
    return 0
}

_koopa_prune_apps() {
    _koopa_python_script 'prune-apps.py'
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

_koopa_reload_shell() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['shell']="$(_koopa_shell_name)"
    _koopa_assert_is_executable "${app[@]}"
    exec "${app['shell']}" -il
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

_koopa_rename_camel_case() {
    _koopa_assert_has_args "$#"
    _koopa_r_script --system 'rename-camel-case.R' "$@"
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

_koopa_rename_kebab_case() {
    _koopa_assert_has_args "$#"
    _koopa_r_script --system 'rename-kebab-case.R' "$@"
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

_koopa_rename_snake_case() {
    _koopa_assert_has_args "$#"
    _koopa_r_script --system 'rename-snake-case.R' "$@"
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

_koopa_rmats() {
    local -A app bool dict
    local -a b1_files b2_files rmats_args
    app['rmats']="$(_koopa_locate_rmats --realpath)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_gtf_file']=0
    bool['verbose']=0
    dict['b1_file']=''
    dict['b2_file']=''
    dict['cstat']=0.0001
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['lib_type']='A'
    dict['nthread']="$(_koopa_cpu_count)"
    dict['output_dir']=''
    dict['read_length']=''
    dict['read_type']=''
    dict['tmp_dir']="$(_koopa_tmp_dir_in_wd)"
    while (("$#"))
    do
        case "$1" in
            '--b1-file='*)
                dict['b1_file']="${1#*=}"
                shift 1
                ;;
            '--b1-file')
                dict['b1_file']="${2:?}"
                shift 2
                ;;
            '--b2-file='*)
                dict['b2_file']="${1#*=}"
                shift 1
                ;;
            '--b2-file')
                dict['b2_file']="${2:?}"
                shift 2
                ;;
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--alpha-threshold='*)
                dict['cstat']="${1#*=}"
                shift 1
                ;;
            '--alpha-threshold')
                dict['cstat']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--read-length='*)
                dict['read_length']="${1#*=}"
                shift 1
                ;;
            '--read-length')
                dict['read_length']="${2:?}"
                shift 2
                ;;
            '--read-type='*)
                dict['read_type']="${1#*=}"
                shift 1
                ;;
            '--read-type')
                dict['read_type']="${2:?}"
                shift 2
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
    [[ "${bool['verbose']}" -eq 1 ]] && set -x
    _koopa_assert_is_set \
        '--alpha-threshold' "${dict['cstat']}" \
        '--b1-file' "${dict['b1_file']}" \
        '--b2-file' "${dict['b2_file']}" \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_file \
        "${dict['b1_file']}" \
        "${dict['b2_file']}" \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['b1_file']="$(_koopa_realpath "${dict['b1_file']}")"
    dict['b2_file']="$(_koopa_realpath "${dict['b2_file']}")"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/rmats.log"
    _koopa_alert "Running rMATS analysis in '${dict['output_dir']}'."
    readarray -t b1_files <<< "$( \
        "${app['tr']}" ',' '\n' < "${dict['b1_file']}" \
    )"
    readarray -t b2_files <<< "$( \
        "${app['tr']}" ',' '\n' < "${dict['b2_file']}" \
    )"
    _koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b1_files[0]}"
    _koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b2_files[0]}"
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            _koopa_salmon_detect_bam_library_type \
                --bam-file="${b1_files[0]}" \
                --fasta-file="${dict['genome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_rmats "${dict['lib_type']}" \
    )"
    if [[ -z "${dict['read_length']}" ]]
    then
        _koopa_alert 'Detecting BAM read length.'
        dict['read_length']="$(_koopa_bam_read_length "${b1_files[0]}")"
    fi
    if [[ -z "${dict['read_type']}" ]]
    then
        _koopa_alert 'Detecting BAM read type.'
        dict['read_type']="$(_koopa_bam_read_type "${b1_files[0]}")"
    fi
    case "${dict['read_type']}" in
        'paired' | 'single')
            ;;
        *)
            _koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd --ext='gtf')"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    _koopa_cp "${dict['b1_file']}" "${dict['output_dir']}/b1.txt"
    _koopa_cp "${dict['b2_file']}" "${dict['output_dir']}/b2.txt"
    rmats_args+=(
        '-t' "${dict['read_type']}"
        '--b1' "${dict['b1_file']}"
        '--b2' "${dict['b2_file']}"
        '--cstat' "${dict['cstat']}"
        '--gtf' "${dict['gtf_file']}"
        '--libType' "${dict['lib_type']}"
        '--nthread' "${dict['nthread']}"
        '--od' "${dict['output_dir']}"
        '--readLength' "${dict['read_length']}"
        '--tmp' "${dict['tmp_dir']}"
        '--tstat' "${dict['nthread']}"
    )
    _koopa_dl 'rmats' "${rmats_args[*]}"
    _koopa_print "${app['rmats']} ${rmats_args[*]}" \
        >> "${dict['log_file']}"
    export PYTHONUNBUFFERED=1
    "${app['rmats']}" "${rmats_args[@]}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    unset -v PYTHONUNBUFFERED
    _koopa_rm "${dict['tmp_dir']}"
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    return 0
}

_koopa_rnaeditingindexer() {
    local -A app dict
    local -a run_args
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bam_suffix']='.Aligned.sortedByCoord.out.bam'
    dict['docker_image']='public.ecr.aws/acidgenomics/rnaeditingindexer'
    dict['example']=0
    dict['genome']='hg38'
    dict['local_bam_dir']='bam'
    dict['local_output_dir']='rnaedit'
    dict['mnt_bam_dir']='/mnt/bam'
    dict['mnt_output_dir']='/mnt/output'
    while (("$#"))
    do
        case "$1" in
            '--bam-dir='*)
                dict['local_bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['local_bam_dir']="${2:?}"
                shift 2
                ;;
            '--genome='*)
                dict['genome']="${1#*=}"
                shift 1
                ;;
            '--genome')
                dict['genome']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['local_output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['local_output_dir']="${2:?}"
                shift 2
                ;;
            '--example')
                dict['example']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    run_args=()
    if [[ "${dict['example']}" -eq 1 ]]
    then
        dict['bam_suffix']="_sampled_with_0.1.Aligned.sortedByCoord.out.\
bam.AluChr1Only.bam"
        dict['local_bam_dir']=''
        dict['mnt_bam_dir']='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
    else
        _koopa_assert_is_dir "${dict['local_bam_dir']}"
        dict['local_bam_dir']="$(_koopa_realpath "${dict['local_bam_dir']}")"
        _koopa_rm "${dict['local_output_dir']}"
        dict['local_output_dir']="$( \
            _koopa_init_dir "${dict['local_output_dir']}" \
        )"
        run_args+=(
            -v "${dict['local_bam_dir']}:${dict['mnt_bam_dir']}:ro"
            -v "${dict['local_output_dir']}:${dict['mnt_output_dir']}:rw"
        )
    fi
    run_args+=("${dict['docker_image']}")
    "${app['docker']}" run "${run_args[@]}" \
        RNAEditingIndex \
            --genome "${dict['genome']}" \
            --keep_cmpileup \
            --verbose \
            -d "${dict['mnt_bam_dir']}" \
            -f "${dict['bam_suffix']}" \
            -l "${dict['mnt_output_dir']}/logs" \
            -o "${dict['mnt_output_dir']}/cmpileups" \
            -os "${dict['mnt_output_dir']}/summary"
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

_koopa_rsem_index() {
    local -A app bool dict
    local -a index_args
    app['rsem_prepare_reference']="$(_koopa_locate_rsem_prepare_reference)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_genome_fasta_file']=0
    bool['tmp_gtf_file']=0
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=10
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "RSEM requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['genome_fasta_file']}"
    then
        bool['tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['tmp_genome_fasta_file']}"
        dict['genome_fasta_file']="${dict['tmp_genome_fasta_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    index_args+=(
        '--gtf' "${dict['gtf_file']}"
        '--num-threads' "${dict['threads']}"
        "${dict['genome_fasta_file']}"
        'rsem'
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    (
        _koopa_cd "${dict['output_dir']}"
        "${app['rsem_prepare_reference']}" "${index_args[@]}"
    )
    if [[ "${bool['tmp_genome_fasta_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['genome_fasta_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}

_koopa_rsem_quant_paired_end_per_sample() {
    local -A app dict
    local -a quant_args
    app['rsem_calculate_expression']="$(_koopa_locate_rsem_calculate_expression)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['threads']="$(_koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "RSEM quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file "${dict['bam_file']}"
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['bam_file']="$(_koopa_realpath "${dict['bam_file']}")"
    _koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['bam_file']}"
    dict['bam_bn']="$(_koopa_basename "${dict['bam_file']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['bam_bn']}' in '${dict['output_dir']}'."
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        _koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            _koopa_salmon_detect_bam_library_type \
                --bam-file="${dict['bam_file']}" \
                --fasta-file="${dict['transcriptome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        _koopa_salmon_library_type_to_rsem "${dict['lib_type']}" \
    )"
    _koopa_alert 'Detecting BAM read type.'
    dict['read_type']="$(_koopa_bam_read_type "${dict['bam_file']}")"
    case "${dict['read_type']}" in
        'paired')
            quant_args+=('--paired-end')
            ;;
        'single')
            ;;
        *)
            _koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    quant_args+=(
        '--bam'
        '--estimate-rspd'
        '--no-bam-output'
        '--num-threads' "${dict['threads']}"
        '--strandedness' "${dict['lib_type']}"
        "${dict['index_dir']}"
        "${dict['bam_file']}"
    )
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['rsem_calculate_expression']}" "${quant_args[@]}"
    return 0
}

_koopa_rsem_quant_bam() {
    local -A app bool dict
    local -a bam_files
    local bam_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['bam_dir']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--bam-dir='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['bam_dir']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-dir' "${dict['bam_dir']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_dir "${dict['bam_dir']}" "${dict['index_dir']}"
    dict['bam_dir']="$(_koopa_realpath "${dict['bam_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running RSEM quant.'
    _koopa_dl \
        'BAM dir' "${dict['bam_dir']}" \
        'Index dir' "${dict['index_dir']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t bam_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.bam" \
            --prefix="${dict['bam_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${bam_files[@]:-}"
    then
        _koopa_stop "No BAM files detected in '${dict['bam_dir']}'."
    fi
    _koopa_assert_is_file "${bam_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#bam_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for bam_file in "${bam_files[@]}"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['sample_id']="$(_koopa_basename_sans_ext "${dict2['bam_file']}")"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_rsem_quant_bam_per_sample \
            --bam-file="${dict2['bam_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'RSEM quant was successful.'
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

_koopa_sambamba_filter_per_sample() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['sambamba']="$(_koopa_locate_sambamba)"
    _koopa_assert_is_executable "${app[@]}"
    dict['filter']=''
    dict['input']=''
    dict['output']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--filter='*)
                dict['filter']="${1#*=}"
                shift 1
                ;;
            '--filter')
                dict['filter']="${2:?}"
                shift 2
                ;;
            '--input-bam='*)
                dict['input']="${1#*=}"
                shift 1
                ;;
            '--input-bam')
                dict['input']="${2:?}"
                shift 2
                ;;
            '--output-bam='*)
                dict['output']="${1#*=}"
                shift 1
                ;;
            '--output-bam')
                dict['output']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--filter' "${dict['filter']}" \
        '--intput-bam' "${dict['input']}" \
        '--output-bam' "${dict['output']}"
    _koopa_assert_is_file "${dict['input']}"
    _koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['input']}"
    _koopa_assert_are_not_identical "${dict['input']}" "${dict['output']}"
    dict['input_bn']="$(_koopa_basename "${dict['input']}")"
    dict['output_bn']="$(_koopa_basename "${dict['output']}")"
    if [[ -f "${dict['output']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_bn']}'."
        return 0
    fi
    _koopa_alert "Filtering '${dict['input_bn']}' to '${dict['output_bn']}'."
    _koopa_dl 'Filter' "${dict['filter']}"
    "${app['sambamba']}" view \
        --filter="${dict['filter']}" \
        --format='bam' \
        --nthreads="${dict['threads']}" \
        --output-filename="${dict['output']}" \
        --show-progress \
        --with-header \
        "${dict['input']}"
    return 0
}

_koopa_sambamba_filter() {
    local -A dict
    local -a bam_files
    local bam_file
    _koopa_assert_has_args_eq "$#" 1
    dict['pattern']='*.sorted.bam'
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    readarray -t bam_files <<< "$( \
        _koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern="${dict['pattern']}" \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! _koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        _koopa_stop "No BAM files detected in '${dict['prefix']}' matching \
pattern '${dict['pattern']}'."
    fi
    _koopa_alert "Filtering BAM files in '${dict['prefix']}'."
    for bam_file in "${bam_files[@]}"
    do
        local -A dict2
        dict2['input']="$bam_file"
        dict2['bn']="$(_koopa_basename_sans_ext "${dict2['input']}")"
        dict2['prefix']="$(_koopa_parent_dir "${dict['input']}")"
        dict2['stem']="${dict2['prefix']}/${dict2['bn']}"
        dict2['output']="${dict2['stem']}.filtered.bam"
        if [[ -f "${dict2['output']}" ]]
        then
            _koopa_alert_note "Skipping '${dict2['output']}'."
            continue
        fi
        dict2['file_1']="${dict2['stem']}.filtered-1-no-duplicates.bam"
        dict2['file_2']="${dict2['stem']}.filtered-2-no-unmapped.bam"
        dict2['file_3']="${dict2['stem']}.filtered-3-no-multimappers.bam"
        _koopa_sambamba_filter_per_sample \
            --filter='not duplicate' \
            --input-bam="${dict2['input']}" \
            --output-bam="${dict2['file_1']}"
        _koopa_sambamba_filter_per_sample \
            --filter='not unmapped' \
            --input-bam="${dict2['file_1']}" \
            --output-bam="${dict2['file_2']}"
        _koopa_sambamba_filter_per_sample \
            --filter='[XS] == null' \
            --input-bam="${dict2['file_2']}" \
            --output-bam="${dict2['file_3']}"
        _koopa_cp "${dict2['file_3']}" "${dict2['output']}"
        _koopa_samtools_index_bam "${dict2['output']}"
    done
    return 0
}

_koopa_samtools_convert_sam_to_bam() {
    local -A app bool dict
    local -a pos
    local file
    _koopa_assert_has_args "$#"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    bool['keep']=0
    dict['threads']="$(_koopa_cpu_count)"
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
        dict2['sam_file']="$file"
        _koopa_assert_is_matching_regex \
            --pattern='\.sam$' \
            --string="${dict2['sam_file']}"
        dict2['bam_file']="$( \
            _koopa_sub \
                --pattern='\.sam$' \
                --regex \
                --replacement='.bam' \
                "${dict2['sam_file']}" \
        )"
        if [[ -f "${dict2['bam_file']}" ]]
        then
            _koopa_alert_note "Skipping '${dict2['bam_file']}'."
            return 0
        fi
        _koopa_alert "Converting '${dict2['sam_file']}' to \
'${dict2['bam_file']}'."
        "${app['samtools']}" view \
            -@ "${dict['threads']}" \
            -b \
            -h \
            -o "${dict2['bam_file']}" \
            "${dict2['sam_file']}"
        _koopa_assert_is_file \
            "${dict2['bam_file']}" \
            "${dict2['sam_file']}"
        if [[ "${bool['keep']}" -eq 0 ]]
        then
            _koopa_rm "${dict2['sam_file']}"
        fi
    done
    return 0
}

_koopa_samtools_index_bam() {
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app['samtools']}"
    dict['threads']="$(_koopa_cpu_count)"
    "${app['samtools']}" index \
        -@ "${dict['threads']}" \
        -M \
        -b \
        "$@"
    return 0
}

_koopa_samtools_sort_bam() {
    local -A app dict
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    dict['format']='bam'
    dict['threads']="$(_koopa_cpu_count)"
    for file in "$@"
    do
        local -A dict2
        dict2['in_file']="$file"
        dict2['out_file']="${dict2['in_file']}.tmp"
        _koopa_assert_is_matching_regex \
            --pattern="\.${dict['format']}\$" \
            --string="${dict2['in_file']}"
        _koopa_alert "Sorting '${dict2['in_file']}'."
        "${app['samtools']}" sort \
            -@ "${dict['threads']}" \
            -O "${dict['format']}" \
            -o "${dict2['out_file']}" \
            "${dict2['in_file']}"
        _koopa_assert_is_file "${dict2['out_file']}"
        _koopa_rm "${dict2['in_file']}"
        _koopa_mv "${dict2['out_file']}" "${dict2['in_file']}"
    done
    return 0
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

_koopa_shared_apps() {
    _koopa_python_script 'shared-apps.py' "$@"
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
    _koopa_is_alias 'vim' && unalias 'vim'
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

_koopa_sra_bam_dump() {
    local -A app dict
    local -a sra_files
    local sra_file
    app['sam_dump']="$(_koopa_locate_sam_dump)"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bam_dir']=''
    dict['prefetch_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--bam-directory='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-directory')
                dict['bam_dir']="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict['prefetch_dir']="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict['prefetch_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-directory' "${dict['bam_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    _koopa_assert_is_ncbi_sra_toolkit_configured
    _koopa_assert_is_dir "${dict['prefetch_dir']}"
    dict['prefetch_dir']="$(_koopa_realpath "${dict['prefetch_dir']}")"
    dict['bam_dir']="$(_koopa_init_dir "${dict['bam_dir']}")"
    _koopa_alert "Dumping BAM files from '${dict['prefetch_dir']}' \
in '${dict['bam_dir']}'."
    readarray -t sra_files <<< "$(
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local -A dict2
        dict2['sra_file']="$sra_file"
        dict2['id']="$(_koopa_basename_sans_ext "${dict2['sra_file']}")"
        dict2['sam_file']="${dict['bam_dir']}/${dict2['id']}.sam"
        dict2['bam_file']="${dict['bam_dir']}/${dict2['id']}.bam"
        [[ -f "${dict2['bam_file']}" ]] && continue
        _koopa_alert "Dumping SAM in '${dict2['sra_file']}' \
to '${dict2['sam_file']}."
        "${app['sam_dump']}" \
            --output-file "${dict2['sam_file']}" \
            --verbose \
            "${dict2['sra_file']}"
        _koopa_assert_is_file "${dict2['sam_file']}"
        _koopa_samtools_convert_sam_to_bam "${dict2['sam_file']}"
        _koopa_assert_is_file "${dict2['bam_file']}"
    done
    return 0
}

_koopa_sra_download_accession_list() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['efetch']="$(_koopa_locate_efetch)"
    app['esearch']="$(_koopa_locate_esearch)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['srp_id']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['acc_file']+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict['acc_file']+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict['srp_id']="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict['srp_id']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set '--srp-id' "${dict['srp_id']}"
    if [[ -z "${dict['acc_file']}" ]]
    then
        dict['acc_file']="$(_koopa_lowercase "${dict['srp_id']}")-\
accession-list.txt"
    fi
    _koopa_alert "Downloading SRA accession list for '${dict['srp_id']}' \
to '${dict['acc_file']}'."
    "${app['esearch']}" -db 'sra' -query "${dict['srp_id']}" \
        | "${app['efetch']}" -format 'runinfo' \
        | "${app['sed']}" '1d' \
        | "${app['cut']}" -d ',' -f '1' \
        > "${dict['acc_file']}"
    return 0
}

_koopa_sra_download_run_info_table() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['efetch']="$(_koopa_locate_efetch --realpath)"
    app['esearch']="$(_koopa_locate_esearch --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['run_info_file']=''
    dict['srp_id']=''
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['run_info_file']+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict['run_info_file']+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict['srp_id']="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict['srp_id']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set '--srp-id' "${dict['srp_id']}"
    if [[ -z "${dict['run_info_file']}" ]]
    then
        dict['run_info_file']="$(_koopa_lowercase "${dict['srp_id']}")-\
run-info-table.csv"
    fi
    _koopa_alert "Downloading SRA run info table for '${dict['srp_id']}' \
to '${dict['run_info_file']}'."
    "${app['esearch']}" -db 'sra' -query "${dict['srp_id']}" \
        | "${app['efetch']}" -format 'runinfo' \
        > "${dict['run_info_file']}"
    return 0
}

_koopa_sra_fastq_dump() {
    local -A app bool dict
    local -a fastq_files sra_files
    local sra_file
    app['fasterq_dump']="$(_koopa_locate_fasterq_dump)"
    _koopa_assert_is_executable "${app[@]}"
    bool['compress']=1
    dict['fastq_dir']=''
    dict['prefetch_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-directory='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-directory')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict['prefetch_dir']="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict['prefetch_dir']="${2:?}"
                shift 2
                ;;
            '--compress')
                bool['compress']=1
                shift 1
                ;;
            '--no-compress')
                bool['compress']=0
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-directory' "${dict['fastq_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    _koopa_assert_is_ncbi_sra_toolkit_configured
    _koopa_assert_is_dir "${dict['prefetch_dir']}"
    dict['prefetch_dir']="$(_koopa_realpath "${dict['prefetch_dir']}")"
    dict['fastq_dir']="$(_koopa_init_dir "${dict['fastq_dir']}")"
    _koopa_alert "Dumping FASTQ files from '${dict['prefetch_dir']}' \
in '${dict['fastq_dir']}'."
    readarray -t sra_files <<< "$(
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local -A dict2
        dict2['sra_file']="$sra_file"
        dict2['id']="$(_koopa_basename_sans_ext "${dict2['sra_file']}")"
        if [[ -f "${dict['fastq_dir']}/${dict2['id']}.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict['id']}_1.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict2['id']}.fastq.gz" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict2['id']}_1.fastq.gz" ]]
        then
            _koopa_alert_info "Skipping '${dict2['sra_file']}'."
            continue
        fi
        _koopa_alert "Dumping '${dict2['sra_file']}' FASTQ \
into '${dict['fastq_dir']}'."
        "${app['fasterq_dump']}" \
            --details \
            --force \
            --outdir "${dict['fastq_dir']}" \
            --progress \
            --skip-technical \
            --split-3 \
            --threads "${dict['threads']}" \
            --verbose \
            "${dict2['sra_file']}"
        if [[ "${bool['compress']}" -eq 1 ]]
        then
            _koopa_alert "Compressing '${dict['id']}' FASTQ \
in '${dict['fastq_dir']}'."
            readarray -t fastq_files <<< "$( \
                _koopa_find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --pattern="${dict2['id']}*.fastq" \
                    --prefix="${dict['fastq_dir']}" \
                    --sort \
                    --type='f' \
            )"
            _koopa_assert_is_array_non_empty "${fastq_files[@]:-}"
            _koopa_compress --format='gzip' --remove "${fastq_files[@]}"
            _koopa_assert_is_not_file "${fastq_files[@]}"
        fi
    done
    return 0
}

_koopa_sra_prefetch_from_aws() {
    s3_uri="s3://sra-pub-run-odp.s3.amazonaws.com/sra/<SRR_ID>/<SRR_ID>"
    return 0
}

_koopa_sra_prefetch() {
    local -A app dict
    local -a parallel_cmd
    app['prefetch']="$(_koopa_locate_sra_prefetch)"
    _koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['jobs']="$(_koopa_cpu_count)"
    [[ "${dict['jobs']}" -gt 4 ]] &&  dict['jobs']=4
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--accession-file='*)
                dict['acc_file']="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict['acc_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='* | \
            '--output-directory='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir' | \
            '--output-directory')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--accession-file' "${dict['acc_file']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_file "${dict['acc_file']}"
    _koopa_assert_is_ncbi_sra_toolkit_configured
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Prefetching SRA samples defined in '${dict['acc_file']}' \
to '${dict['output_dir']}'."
    parallel_cmd=(
        "${app['prefetch']}"
        '--force' 'no'
        '--max-size' '500G'
        '--output-directory' "${dict['output_dir']}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    _koopa_parallel \
        --arg-file="${dict['acc_file']}" \
        --command="${parallel_cmd[*]}" \
        --jobs="${dict['jobs']}"
    return 0
}

_koopa_ssh_generate_key() {
    local -A app dict
    local -a pos
    local key_name
    app['ssh_keygen']="$(_koopa_locate_ssh_keygen --allow-system --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['hostname']="$(_koopa_hostname)"
    dict['prefix']="${HOME:?}/.ssh"
    dict['user']="$(_koopa_user_name)"
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
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        pos=('id_rsa')
    fi
    set -- "${pos[@]}"
    dict['prefix']="$(_koopa_init_dir "${dict['prefix']}")"
    _koopa_chmod 0700 "${dict['prefix']}"
    for key_name in "$@"
    do
        local -A dict2
        local -a ssh_args
        dict2['key_name']="$key_name"
        dict2['file']="${dict['prefix']}/${dict2['key_name']}"
        if [[ -f "${dict2['file']}" ]]
        then
            _koopa_alert_note "SSH key exists at '${dict2['file']}'."
            return 0
        fi
        _koopa_alert "Generating SSH key at '${dict2['file']}'."
        ssh_args+=(
            '-C' "${dict['user']}@${dict['hostname']}"
            '-N' ''
            '-f' "${dict2['file']}"
            '-q'
        )
        case "${dict2['key_name']}" in
            *'-ed25519' | *'_ed25519')
                ssh_args+=(
                    '-a' 100
                    '-o'
                    '-t' 'ed25519'
                )
                ;;
            *'-rsa' | *'_rsa')
                ssh_args+=(
                    '-b' 4096
                    '-t' 'rsa'
                )
                ;;
            *)
                _koopa_stop "Unsupported key: '${dict2['key_name']}'."
                ;;
        esac
        _koopa_dl \
            'ssh-keygen' "${app['ssh_keygen']}" \
            'args' "${ssh_args[*]}"
        "${app['ssh_keygen']}" "${ssh_args[@]}"
        _koopa_alert_success "Generated SSH key at '${dict2['file']}'."
    done
    return 0
}

_koopa_ssh_key_info() {
    local -A app dict
    local keyfile
    app['ssh_keygen']="$(_koopa_locate_ssh_keygen --allow-system)"
    app['uniq']="$(_koopa_locate_uniq)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${HOME:?}/.ssh"
    dict['stem']='id_'
    for keyfile in "${dict['prefix']}/${dict['stem']}"*
    do
        "${app['ssh_keygen']}" -l -f "$keyfile"
    done | "${app['uniq']}"
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

_koopa_star_align_paired_end_per_sample() {
    local -A app bool dict
    local -a align_args
    app['star']="$(_koopa_locate_star --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    bool['tmp_gtf_file']=0
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['gtf_file']=''
    dict['index_dir']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=40
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "STAR requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    _koopa_assert_is_dir "${dict['index_dir']}"
    _koopa_assert_is_file \
        "${dict['fastq_r1_file']}" \
        "${dict['fastq_r2_file']}" \
        "${dict['gtf_file']}"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['fastq_r1_file']="$(_koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(_koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(_koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(_koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['fastq_r1_file']}"
    then
        bool['tmp_fastq_r1_file']=1
        dict['tmp_fastq_r1_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['fastq_r1_file']}" \
            --output-file="${dict['tmp_fastq_r1_file']}"
        dict['fastq_r1_file']="${dict['tmp_fastq_r1_file']}"
    fi
    if _koopa_is_compressed_file "${dict['fastq_r2_file']}"
    then
        bool['tmp_fastq_r2_file']=1
        dict['tmp_fastq_r2_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['fastq_r2_file']}" \
            --output-file="${dict['tmp_fastq_r2_file']}"
        dict['fastq_r2_file']="${dict['tmp_fastq_r2_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    _koopa_alert "Detecting read length in '${dict['fastq_r1_file']}'."
    dict['read_length']="$(_koopa_fastq_read_length "${dict['fastq_r1_file']}")"
    _koopa_dl 'Read length' "${dict['read_length']}"
    dict['sjdb_overhang']="$((dict['read_length'] - 1))"
    align_args+=(
        '--alignIntronMax' 1000000
        '--alignIntronMin' 20
        '--alignMatesGapMax' 1000000
        '--alignSJDBoverhangMin' 1
        '--alignSJoverhangMin' 8
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--limitOutSJcollapsed' 2000000
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outFilterMismatchNmax' 999
        '--outFilterMismatchNoverReadLmax' 0.04
        '--outFilterMultimapNmax' 20
        '--outFilterType' 'BySJout'
        '--outReadsUnmapped' 'Fastx'
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' 0
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['gtf_file']}"
        '--sjdbOverhang' "${dict['sjdb_overhang']}"
        '--twopassMode' 'Basic'
    )
    _koopa_dl 'Align args' "${align_args[*]}"
    _koopa_write_string \
        --file="${dict['output_dir']}/star-align-cmd.log" \
        --string="${app['star']} ${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_r2_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_rm "${dict['output_dir']}/_STAR"*
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    _koopa_assert_is_file "${dict['bam_file']}"
    _koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    _koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}

_koopa_star_align_paired_end() {
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_gtf_file']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['gtf_file']=''
    dict['index_dir']=''
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    _koopa_assert_is_file "${dict['gtf_file']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running STAR aligner.'
    _koopa_dl \
        'Mode' 'paired-end' \
        'Index dir' "${dict['index_dir']}" \
        'GTF file' "${dict['gtf_file']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement="${dict['fastq_r2_tail']}" \
                "${dict2['fastq_r1_file']}" \
        )"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_r1_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_star_align_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --gtf-file="${dict['gtf_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'STAR alignment was successful.'
    return 0
}

_koopa_star_align_single_end_per_sample() {
    local -A app bool dict
    local -a align_args
    _koopa_assert_has_args "$#"
    app['star']="$(_koopa_locate_star --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_file']=0
    bool['tmp_gtf_file']=0
    dict['fastq_file']=''
    dict['gtf_file']=''
    dict['index_dir']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=40
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    _koopa_assert_is_dir "${dict['index_dir']}"
    _koopa_assert_is_file "${dict['fastq_file']}" "${dict['gtf_file']}"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    dict['fastq_file']="$(_koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(_koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['fastq_bn']}' in '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['fastq_file']}"
    then
        bool['tmp_fastq_file']=1
        dict['tmp_fastq_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['fastq_file']}" \
            --output-file="${dict['tmp_fastq_file']}"
        dict['fastq_file']="${dict['tmp_fastq_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    _koopa_alert "Detecting read length in '${dict['fastq_r1_file']}'."
    dict['read_length']="$(_koopa_fastq_read_length "${dict['fastq_file']}")"
    _koopa_dl 'Read length' "${dict['read_length']}"
    dict['sjdb_overhang']="$((dict['read_length'] - 1))"
    align_args+=(
        '--alignIntronMax' 1000000
        '--alignIntronMin' 20
        '--alignMatesGapMax' 1000000
        '--alignSJDBoverhangMin' 1
        '--alignSJoverhangMin' 8
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--limitOutSJcollapsed' 2000000
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outFilterMismatchNmax' 999
        '--outFilterMismatchNoverReadLmax' 0.04
        '--outFilterMultimapNmax' 20
        '--outFilterType' 'BySJout'
        '--outReadsUnmapped' 'Fastx'
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' 0
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['gtf_file']}"
        '--sjdbOverhang' "${dict['sjdb_overhang']}"
        '--twopassMode' 'Basic'
    )
    _koopa_dl 'Align args' "${align_args[*]}"
    _koopa_write_string \
        --file="${dict['output_dir']}/star-align-cmd.log" \
        --string="${app['star']} ${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['fastq_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_rm "${dict['output_dir']}/_STAR"*
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    _koopa_assert_is_file "${dict['bam_file']}"
    _koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    _koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}

_koopa_star_align_single_end() {
    local -A app bool dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['gtf_file']=''
    dict['index_dir']=''
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    _koopa_assert_is_file "${dict['gtf_file']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running STAR aligner.'
    _koopa_dl \
        'Mode' 'single-end' \
        'Index dir' "${dict['index_dir']}" \
        'GTF file' "${dict['gtf_file']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${fastq_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    for fastq_file in "${fastq_files[@]}"
    do
        local -A dict2
        dict2['fastq_file']="$fastq_file"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_star_align_single_end_per_sample \
            --fastq-file="${dict2['fastq_file']}" \
            --gtf-file="${dict['gtf_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'STAR alignment was successful.'
    return 0
}

_koopa_star_index() {
    local -A app bool dict
    local -a index_args
    app['star']="$(_koopa_locate_star --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_genome_fasta_file']=0
    bool['tmp_gtf_file']=0
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=40
    dict['output_dir']=''
    dict['read_length']=150
    dict['threads']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "STAR requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating STAR index at '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['genome_fasta_file']}"
    then
        bool['tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['tmp_genome_fasta_file']}"
        dict['genome_fasta_file']="${dict['tmp_genome_fasta_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    if _koopa_fasta_has_alt_contigs "${dict['genome_fasta_file']}"
    then
        _koopa_warn 'ALT contigs detected in genome FASTA file.'
    fi
    dict['genome_dir_bn']="$(_koopa_basename "${dict['output_dir']}")"
    dict['sjdb_overhang']="$((dict['read_length'] - 1))"
    index_args+=(
        '--genomeDir' "${dict['genome_dir_bn']}"
        '--genomeFastaFiles' "${dict['genome_fasta_file']}"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['gtf_file']}"
        '--sjdbOverhang' "${dict['sjdb_overhang']}"
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    (
        _koopa_cd "$(_koopa_dirname "${dict['output_dir']}")"
        _koopa_rm "${dict['output_dir']}"
        "${app['star']}" "${index_args[@]}"
        _koopa_rm '_STARtmp'
    )
    _koopa_write_string \
        --file="${dict['output_dir']}/star-index-cmd.log" \
        --string="${app['star']} ${index_args[*]}"
    if [[ "${bool['tmp_genome_fasta_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['genome_fasta_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_alert_success "STAR index created at '${dict['output_dir']}'."
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

_koopa_switch_to_develop() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_owner
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['branch']='develop'
    dict['origin']='origin'
    dict['prefix']="$(_koopa_koopa_prefix)"
    dict['ssh_url']='git@github.com:acidgenomics/koopa.git'
    dict['user']="$(_koopa_user_name)"
    _koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    (
        _koopa_cd "${dict['prefix']}"
        if [[ "$(_koopa_git_branch "${PWD:?}")" == 'develop' ]]
        then
            _koopa_alert_note "Already on 'develop' branch."
            return 0
        fi
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    _koopa_zsh_compaudit_set_permissions
    return 0
}

_koopa_system_info() {
    local -A app dict
    local -a info nf_info
    _koopa_assert_has_no_args "$#"
    app['bash']="$(_koopa_locate_bash --allow-bootstrap --realpath)"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['python']="$(_koopa_locate_python --allow-bootstrap --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch)"
    dict['arch2']="$(_koopa_arch2)"
    dict['bash_version']="$(_koopa_get_version "${app['bash']}")"
    dict['config_prefix']="$(_koopa_config_prefix)"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['_koopa_url']="$(_koopa_koopa_url)"
    dict['_koopa_version']="$(_koopa_koopa_version)"
    dict['python_version']="$(_koopa_get_version "${app['python']}")"
    dict['ascii_turtle_file']="${dict['_koopa_prefix']}/etc/\
koopa/ascii-turtle.txt"
    _koopa_assert_is_file "${dict['ascii_turtle_file']}"
    info=(
        "koopa ${dict['_koopa_version']}"
        "URL: ${dict['_koopa_url']}"
    )
    if _koopa_is_git_repo_top_level "${dict['_koopa_prefix']}"
    then
        dict['git_remote']="$(_koopa_git_remote_url "${dict['_koopa_prefix']}")"
        dict['git_commit']="$( \
            _koopa_git_last_commit_local "${dict['_koopa_prefix']}" \
        )"
        dict['git_date']="$(_koopa_git_commit_date "${dict['_koopa_prefix']}")"
        info+=(
            ''
            'Git repo'
            '--------'
            "Remote: ${dict['git_remote']}"
            "Commit: ${dict['git_commit']}"
            "Date: ${dict['git_date']}"
        )
    fi
    info+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${dict['_koopa_prefix']}"
        "Config Prefix: ${dict['config_prefix']}"
    )
    if _koopa_is_macos
    then
        app['sw_vers']="$(_koopa_macos_locate_sw_vers)"
        _koopa_assert_is_executable "${app['sw_vers']}"
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(_koopa_locate_uname --allow-system)"
        _koopa_assert_is_executable "${app['uname']}"
        dict['os']="$("${app['uname']}" --all)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict['os']}"
        "Architecture: ${dict['arch']} / ${dict['arch2']}"
        "Bash: ${app['bash']}"
        "Bash Version: ${dict['bash_version']}"
        "Python: ${app['python']}"
        "Python Version: ${dict['python_version']}"
    )
    app['neofetch']="$(_koopa_locate_neofetch --allow-missing)"
    if [[ -x "${app['neofetch']}" ]]
    then
        readarray -t nf_info <<< "$("${app['neofetch']}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app['cat']}" "${dict['ascii_turtle_file']}"
    _koopa_info_box "${info[@]}"
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

_koopa_update_koopa() {
    local -A dict
    local prefix
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_owner
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    if ! _koopa_is_git_repo_top_level "${dict['_koopa_prefix']}"
    then
        _koopa_alert_note "Pinned release detected at '${dict['_koopa_prefix']}'."
        return 1
    fi
    _koopa_git_pull "${dict['_koopa_prefix']}"
    _koopa_zsh_compaudit_set_permissions
    return 0
}

_koopa_update_private_ont_guppy_installers() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_has_private_access
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['base_url']='https://cdn.oxfordnanoportal.com/software/analysis'
    dict['name']='ont-guppy'
    dict['prefix']="$(_koopa_tmp_dir)"
    dict['s3_profile']='acidgenomics'
    dict['s3_target']="$(_koopa_private_installers_s3_uri)/${dict['name']}"
    dict['version']="$(_koopa_app_json_version "${dict['name']}")"
    _koopa_mkdir \
        "${dict['prefix']}/linux/amd64" \
        "${dict['prefix']}/linux/arm64" \
        "${dict['prefix']}/macos/amd64"
    _koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-cpu.tar.gz"
    _koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-gpu.tar.gz"
    _koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linuxaarch64_\
cuda10.tar.gz" \
        "${dict['prefix']}/linux/arm64/${dict['version']}-gpu.tar.gz"
    _koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_osx64.zip" \
        "${dict['prefix']}/macos/amd64/${dict['version']}-cpu.zip"
    "${app['aws']}" s3 sync \
        --profile "${dict['s3_profile']}" \
        "${dict['prefix']}/" \
        "${dict['s3_target']}/"
    _koopa_rm "${dict['prefix']}"
    return 0
}

_koopa_update_system_homebrew() {
    local -A app dict
    local -a taps
    local tap
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    _koopa_assert_is_owner
    if _koopa_is_macos
    then
        _koopa_macos_assert_is_xcode_clt_installed
    fi
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(_koopa_homebrew_prefix)"
    dict['user_id']="$(_koopa_user_id)"
    _koopa_assert_is_dir \
        "${dict['prefix']}" \
        "${dict['prefix']}/bin"
    _koopa_alert_update_start 'Homebrew' "${dict['prefix']}"
    _koopa_brew_reset_permissions
    _koopa_alert 'Updating Homebrew.'
    _koopa_add_to_path_start "${dict['prefix']}/bin"
    "${app['brew']}" analytics off
    "${app['brew']}" update
    if _koopa_is_macos
    then
        _koopa_macos_brew_upgrade_casks
    fi
    _koopa_brew_upgrade_brews
    _koopa_alert 'Cleaning up.'
    taps=(
        'homebrew/bundle'
        'homebrew/cask'
        'homebrew/cask-drivers'
        'homebrew/cask-fonts'
        'homebrew/cask-versions'
        'homebrew/core'
    )
    for tap in "${taps[@]}"
    do
        local tap_prefix
        tap_prefix="$("${app['brew']}" --repo "$tap")"
        if [[ -d "$tap_prefix" ]]
        then
            _koopa_alert "Untapping '${tap}'."
            "${app['brew']}" untap "$tap"
        fi
    done
    "${app['brew']}" cleanup -s
    _koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove
    _koopa_brew_doctor
    _koopa_alert_update_success 'Homebrew' "${dict['prefix']}"
    return 0
}

_koopa_update_system_tex_packages() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['tlmgr']="$(_koopa_locate_tlmgr)"
    _koopa_assert_is_executable "${app[@]}"
    (
        _koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
        _koopa_sudo "${app['tlmgr']}" update --self
        _koopa_sudo "${app['tlmgr']}" update --list
        _koopa_sudo "${app['tlmgr']}" update --all
    )
    return 0
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
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['user_id']="$(_koopa_user_id)"
    prefixes=(
        "${dict['_koopa_prefix']}/lang/zsh"
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

_koopa_current_aws_cli_version() {
    _koopa_current_github_tag_version 'aws/aws-cli'
    return 0
}

_koopa_current_bioconductor_version() {
    local str
    _koopa_assert_has_no_args "$#"
    str="$(_koopa_parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_current_conda_package_version() {
    local -A app
    local name
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['conda']="$(_koopa_locate_conda)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local -A dict
        dict['name']="$name"
        dict['version']="$( \
            "${app['conda']}" search "${dict['name']}" \
                | "${app['tail']}" -n 1 \
                | "${app['awk']}" '{print $2}' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        _koopa_print "${dict['version']}"
    done
    return 0
}

_koopa_current_ensembl_version() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_parse_url 'ftp://ftp.ensembl.org/pub/README' \
        | "${app['sed']}" -n '3p' \
        | "${app['cut']}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_current_flybase_version() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['tail']="$(_koopa_locate_tail --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | _koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app['tail']}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_current_gencode_version() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['curl']="$(_koopa_locate_curl --allow-system)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['organism']="${1:-}"
    [[ -z "${dict['organism']}" ]] && dict['organism']='Homo sapiens'
    case "${dict['organism']}" in
        'Homo sapiens' | \
        'human')
            dict['short_name']='human'
            dict['pattern']='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
            dict['short_name']='mouse'
            dict['pattern']='Release M[0-9]+'
            ;;
        *)
            _koopa_stop "Unsupported organism: '${dict['organism']}'."
            ;;
    esac
    dict['base_url']='https://www.gencodegenes.org'
    dict['url']="${dict['base_url']}/${dict['short_name']}/"
    dict['str']="$( \
        _koopa_parse_url "${dict['url']}" \
        | _koopa_grep \
            --only-matching \
            --pattern="${dict['pattern']}" \
            --regex \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_current_git_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['rev']="$(_koopa_locate_rev)"
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']='https://mirrors.edge.kernel.org/pub/software/scm/git/'
    dict['grep_string']='git-[.0-9]+\.tar\.xz'
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['sort']}" -u \
            | "${app['tail']}" -n 1 \
            | "${app['cut']}" -d '-' -f '2' \
            | "${app['rev']}" \
            | "${app['cut']}" -d '.' -f '3-' \
            | "${app['rev']}" \
    )"
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_current_github_release_version() {
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut)"
    app['sed']="$(_koopa_locate_sed)"
    _koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/\
releases/latest"
        dict['version']="$( \
            _koopa_parse_url "${dict['url']}" \
                | _koopa_grep --pattern='"tag_name":' \
                | "${app['cut']}" -d '"' -f '4' \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        _koopa_print "${dict['version']}"
    done
    return 0
}

_koopa_current_github_tag_version() {
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head)"
    app['jq']="$(_koopa_locate_jq)"
    app['sed']="$(_koopa_locate_sed)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/tags"
        dict['version']="$( \
            _koopa_parse_url "${dict['url']}" \
                | "${app['jq']}" --raw-output '.[].name' \
                | "${app['sort']}" --reverse --version-sort \
                | "${app['head']}" --lines=1 \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        _koopa_print "${dict['version']}"
    done
    return 0
}

_koopa_current_gnu_ftp_version() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['head']="$(_koopa_locate_head)"
    app['rev']="$(_koopa_locate_rev)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['url']="https://ftp.gnu.org/gnu/${dict['name']}/?C=M;O=D"
    dict['grep_string']="${dict['name']}-[.0-9a-z]+.tar"
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '-' -f '2' \
            | "${app['rev']}" \
            | "${app['cut']}" -d '.' -f '2-' \
            | "${app['rev']}" \
    )"
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_current_google_cloud_sdk_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['pup']="$(_koopa_locate_pup)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']='https://cloud.google.com/sdk/docs/release-notes'
    dict['version']="$( \
        _koopa_parse_url "${dict['url']}" \
            | "${app['pup']}" 'h2 text{}' \
            | "${app['awk']}" 'NR==1 {print $1}' \
    )"
    [[ -n "${dict['version']}" ]] || return 1
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_current_latch_version() {
    _koopa_current_pypi_package_version 'latch'
    return 0
}

_koopa_current_pypi_package_version() {
    local -A app
    local name
    _koopa_assert_has_args "$#"
    app['curl']="$(_koopa_locate_curl)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local -A dict
        dict['name']="$name"
        dict['url']="https://pypi.org/pypi/${dict['name']}/json"
        dict['version']="$( \
            "${app['curl']}" -s "${dict['url']}" \
                | "${app['jq']}" --raw-output '.info.version' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        _koopa_print "${dict['version']}"
    done
    return 0
}

_koopa_current_python_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['head']="$(_koopa_locate_head)"
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']='https://www.python.org/ftp/python/'
    dict['grep_string']='3\.[0-9]+\.[0-9]+/'
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['cut']}" -d '/' -f 1 \
            | "${app['sort']}" -Vu \
            | "${app['tail']}" -n 2 \
            | "${app['head']}" -n 1 \
    )"
    _koopa_print "${dict['version']}"
    return 0
}

_koopa_current_refseq_version() {
    local str url
    _koopa_assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    str="$(_koopa_parse_url "$url")"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_current_wormbase_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    dict['string']="$( \
        _koopa_parse_url --list-only "${dict['url']}/" \
            | _koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app['cut']}" -d '.' -f '2' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_docker_build_all_tags() {
    _koopa_assert_has_args "$#"
    _koopa_python_script 'docker-build-all-tags.py' "$@"
    return 0
}

_koopa_docker_build() {
    local -A app dict
    local -a build_args image_ids platforms tags
    local tag
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut)"
    app['date']="$(_koopa_locate_date)"
    app['docker']="$(_koopa_locate_docker --realpath)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    dict['default_tag']='latest'
    dict['delete']=1
    dict['local_dir']=''
    dict['memory']=''
    dict['push']=1
    dict['remote_url']=''
    while (("$#"))
    do
        case "$1" in
            '--local='*)
                dict['local_dir']="${1#*=}"
                shift 1
                ;;
            '--local')
                dict['local_dir']="${2:?}"
                shift 2
                ;;
            '--memory='*)
                dict['memory']="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict['memory']="${2:?}"
                shift 2
                ;;
            '--remote='*)
                dict['remote_url']="${1#*=}"
                shift 1
                ;;
            '--remote')
                dict['remote_url']="${2:?}"
                shift 2
                ;;
            '--no-push')
                dict['push']=0
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--local' "${dict['local_dir']}" \
        '--remote' "${dict['remote_url']}"
    _koopa_assert_is_dir "${dict['local_dir']}"
    _koopa_assert_is_file "${dict['local_dir']}/Dockerfile"
    dict['docker_bin']="$(_koopa_parent_dir "${app['docker']}")"
    _koopa_add_to_path_start "${dict['docker_bin']}"
    build_args=()
    platforms=()
    tags=()
    if ! _koopa_str_detect_fixed \
        --string="${dict['remote_url']}" \
        --pattern=':'
    then
        dict['remote_url']="${dict['remote_url']}:${dict['default_tag']}"
    fi
    _koopa_assert_is_matching_regex \
        --pattern='^(.+)/(.+)/(.+):(.+)$' \
        --string="${dict['remote_url']}"
    dict['remote_str']="$( \
        _koopa_sub \
            --fixed \
            --pattern=':' \
            --replacement='/' \
            "${dict['remote_url']}"
    )"
    dict['server']="$( \
        _koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1' \
    )"
    dict['image_name']="$( \
        _koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1-3' \
    )"
    dict['tag']="$( \
        _koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '4' \
    )"
    if [[ "${dict['push']}" -eq 1 ]]
    then
        case "${dict['server']}" in
            *'.dkr.ecr.'*'.amazonaws.com')
                _koopa_aws_ecr_login_private
                ;;
            'public.ecr.aws')
                _koopa_aws_ecr_login_public
                ;;
            *)
                _koopa_alert "Logging into '${dict['server']}'."
                "${app['docker']}" logout "${dict['server']}" \
                    >/dev/null || true
                "${app['docker']}" login "${dict['server']}" \
                    >/dev/null || return 1
                ;;
        esac
    fi
    dict['tags_file']="${dict['local_dir']}/tags.txt"
    if [[ -f "${dict['tags_file']}" ]]
    then
        readarray -t tags < "${dict['tags_file']}"
    fi
    if [[ -L "${dict['local_dir']}" ]]
    then
        tags+=("${dict['tag']}")
        dict['local_dir']="$(_koopa_realpath "${dict['local_dir']}")"
        dict['tag']="$(_koopa_basename "${dict['local_dir']}")"
    fi
    tags+=(
        "${dict['tag']}"
        "${dict['tag']}-$(${app['date']} '+%Y%m%d')"
    )
    readarray -t tags <<< "$( \
        _koopa_print "${tags[@]}" \
        | "${app['sort']}" -u \
    )"
    for tag in "${tags[@]}"
    do
        build_args+=("--tag=${dict['image_name']}:${tag}")
    done
    platforms=('linux/amd64')
    dict['platforms_file']="${dict['local_dir']}/platforms.txt"
    if [[ -f "${dict['platforms_file']}" ]]
    then
        readarray -t platforms < "${dict['platforms_file']}"
    fi
    dict['platforms_string']="$(_koopa_paste --sep=',' "${platforms[@]}")"
    build_args+=("--platform=${dict['platforms_string']}")
    if [[ -n "${dict['memory']}" ]]
    then
        build_args+=(
            "--memory=${dict['memory']}"
            "--memory-swap=${dict['memory']}"
        )
    fi
    build_args+=(
        '--no-cache'
        '--progress=auto'
        '--pull'
    )
    if [[ "${dict['push']}" -eq 1 ]]
    then
        build_args+=('--push')
    fi
    build_args+=("${dict['local_dir']}")
    if [[ "${dict['delete']}" -eq 1 ]]
    then
        _koopa_alert "Pruning images '${dict['remote_url']}'."
        readarray -t image_ids <<< "$( \
            "${app['docker']}" image ls \
                --filter reference="${dict['remote_url']}" \
                --quiet \
        )"
        if _koopa_is_array_non_empty "${image_ids[@]:-}"
        then
            "${app['docker']}" image rm --force "${image_ids[@]}"
        fi
    fi
    _koopa_alert "Building '${dict['remote_url']}' Docker image."
    _koopa_dl 'Build args' "${build_args[*]}"
    dict['build_name']="$(_koopa_basename "${dict['image_name']}")"
    "${app['docker']}" buildx rm \
        "${dict['build_name']}" \
        &>/dev/null \
        || true
    "${app['docker']}" buildx create \
        --name="${dict['build_name']}" \
        --use \
        >/dev/null
    "${app['docker']}" buildx build "${build_args[@]}"
    "${app['docker']}" buildx rm "${dict['build_name']}"
    "${app['docker']}" image ls \
        --filter \
        reference="${dict['remote_url']}"
    if [[ "${dict['push']}" -eq 1 ]]
    then
        "${app['docker']}" logout "${dict['server']}" \
            >/dev/null || true
    fi
    _koopa_alert_success "Build of '${dict['remote_url']}' was successful."
    return 0
}

_koopa_docker_ghcr_login() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pat']="${GHCR_PAT:?}"
    dict['server']='ghcr.io'
    dict['user']="${GHCR_USER:?}"
    _koopa_print "${dict['pat']}" \
        | "${app['docker']}" login \
            "${dict['server']}" \
            -u "${dict['user']}" \
            --password-stdin
    return 0
}

_koopa_docker_ghcr_push() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 3
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['image_name']="${2:?}"
    dict['owner']="${1:?}"
    dict['server']='ghcr.io'
    dict['version']="${3:?}"
    dict['url']="${dict['server']}/${dict['owner']}/\
${dict['image_name']}:${dict['version']}"
    _koopa_docker_ghcr_login
    "${app['docker']}" push "${dict['url']}"
    return 0
}

_koopa_docker_is_build_recent() {
    local -A app dict
    local -a pos
    local image
    _koopa_assert_has_args "$#"
    app['date']="$(_koopa_locate_date)"
    app['docker']="$(_koopa_locate_docker)"
    app['sed']="$(_koopa_locate_sed)"
    _koopa_assert_is_executable "${app[@]}"
    dict['days']=7
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                dict['days']="${1#*=}"
                shift 1
                ;;
            '--days')
                dict['days']="${2:?}"
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
    dict['seconds']="$((dict[days] * 86400))"
    for image in "$@"
    do
        local -A dict2
        dict['current']="$("${app['date']}" -u '+%s')"
        dict['image']="$image"
        "${app['docker']}" pull "${dict2['image']}" >/dev/null
        dict2['json']="$( \
            "${app['docker']}" inspect \
                --format='{{json .Created}}' \
                "${dict2['image']}" \
        )"
        dict2['created']="$( \
            _koopa_grep \
                --only-matching \
                --pattern='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                --regex \
                --string="${dict2['json']}" \
            | "${app['sed']}" 's/T/ /' \
            | "${app['sed']}" 's/\$/ UTC/'
        )"
        dict2['created']="$( \
            "${app['date']}" --utc --date="${dict2['created']}" '+%s' \
        )"
        dict2['diff']=$((dict2['current'] - dict2['created']))
        [[ "${dict2['diff']}" -le "${dict['seconds']}" ]] && continue
        return 1
    done
    return 0
}

_koopa_docker_prune_all_images() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Pruning Docker buildx.'
    "${app['docker']}" buildx prune --all --force --verbose || true
    _koopa_alert 'Pruning Docker images.'
    "${app['docker']}" system prune --all --force || true
    "${app['docker']}" images
    return 0
}

_koopa_docker_prune_old_images() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Pruning Docker images older than 3 months.'
    "${app['docker']}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    "${app['docker']}" image prune --force || true
    return 0
}

_koopa_docker_remove() {
    local -A app
    local pattern
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['docker']="$(_koopa_locate_docker)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    for pattern in "$@"
    do
        "${app['docker']}" images \
            | _koopa_grep --pattern="$pattern" \
            | "${app['awk']}" '{print $3}' \
            | "${app['xargs']}" "${app['docker']}" rmi --force
    done
    return 0
}

_koopa_docker_run() {
    local -A app dict
    local -a pos run_args
    _koopa_assert_has_args "$#"
    app['docker']="$(_koopa_locate_docker --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arm']=0
    dict['bash']=0
    dict['bind']=0
    dict['workdir']='/mnt/work'
    dict['x86']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--arm')
                dict['arm']=1
                shift 1
                ;;
            '--bash')
                dict['bash']=1
                shift 1
                ;;
            '--bind')
                dict['bind']=1
                shift 1
                ;;
            '--x86')
                dict['x86']=1
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
    dict['image']="${1:?}"
    _koopa_add_to_path_start "$(_koopa_parent_dir "${app['docker']}")"
    case "${dict['image']}" in
        *'.dkr.ecr.'*'.amazonaws.com/'*)
            _koopa_aws_ecr_login_private
            ;;
        'public.ecr.aws/'*)
            if [[ -n "${AWS_ECR_PROFILE:-}" ]]
            then
                _koopa_aws_ecr_login_public
            fi
            ;;
    esac
    "${app['docker']}" pull "${dict['image']}"
    run_args+=('--interactive' '--tty')
    [[ -n "${HTTP_PROXY:-}" ]] &&
        run_args+=('--env' "HTTP_PROXY=${HTTP_PROXY:?}")
    [[ -n "${HTTPS_PROXY:-}" ]] &&
        run_args+=('--env' "HTTPS_PROXY=${HTTPS_PROXY:?}")
    [[ -n "${http_proxy:-}" ]] &&
        run_args+=('--env' "http_proxy=${http_proxy:?}")
    [[ -n "${https_proxy:-}" ]] &&
        run_args+=('--env' "https_proxy=${https_proxy:?}")
    if [[ "${dict['bind']}" -eq 1 ]]
    then
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            _koopa_stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict['workdir']}"
            "--workdir=${dict['workdir']}"
        )
    fi
    if [[ "${dict['arm']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict['x86']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict['image']}")
    if [[ "${dict['bash']}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app['docker']}" run "${run_args[@]}"
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

_koopa_find_and_move_in_sequence() {
    _koopa_assert_has_args "$#"
    _koopa_python_script 'find-and-move-in-sequence.py' "$@"
    return 0
}

_koopa_find_and_replace_in_file() {
    local -A app dict
    local -a flags perl_cmd pos
    _koopa_assert_has_args "$#"
    app['perl']="$(_koopa_locate_perl --allow-system)"
    dict['multiline']=0
    dict['pattern']=''
    dict['regex']=0
    dict['replacement']=''
    dict['sudo']=0
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
                dict['replacement']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replacement']="${2:-}"
                shift 2
                ;;
            '--fixed')
                dict['regex']=0
                shift 1
                ;;
            '--multiline')
                dict['multiline']=1
                shift 1
                ;;
            '--regex')
                dict['regex']=1
                shift 1
                ;;
            '--sudo')
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
    _koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    if [[ "${dict['regex']}" -eq 1 ]]
    then
        dict['expr']="s|${dict['pattern']}|${dict['replacement']}|g"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replacement']}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    flags=('-i' '-p')
    [[ "${dict['multiline']}" -eq 1 ]] && flags+=('-0')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        perl_cmd+=('_koopa_sudo' "${app['perl']}")
    else
        perl_cmd=("${app['perl']}")
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${perl_cmd[@]}" "${flags[@]}" -e "${dict['expr']}" "$@"
    return 0
}

_koopa_find_app_version() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['name']="${1:?}"
    dict['prefix']="${dict['app_prefix']}/${dict['name']}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['hit']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}" \
            --type='d' \
        | "${app['sort']}" \
        | "${app['tail']}" -n 1 \
    )"
    [[ -d "${dict['hit']}" ]] || return 1
    dict['hit_bn']="$(_koopa_basename "${dict['hit']}")"
    _koopa_print "${dict['hit_bn']}"
    return 0
}

_koopa_find_broken_symlinks() {
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            _koopa_find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}

_koopa_find_dotfiles() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['awk']="$(_koopa_locate_awk)"
    app['basename']="$(_koopa_locate_basename)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    dict['type']="${1:?}"
    dict['header']="${2:?}"
    dict['str']="$( \
        _koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict['type']}" \
        | "${app['xargs']}" -0 -n 1 "${app['basename']}" \
        | "${app['awk']}" '{print "    -",$0}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_h2 "${dict['header']}:"
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_find_empty_dirs() {
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            _koopa_find \
                --empty \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}

_koopa_find_files_without_line_ending() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    app['pcregrep']="$(_koopa_locate_pcregrep)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -a files
        local str
        readarray -t files <<< "$(
            _koopa_find \
                --min-depth=1 \
                --prefix="$(_koopa_realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        _koopa_is_array_non_empty "${files[@]:-}" || continue
        str="$("${app['pcregrep']}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}

_koopa_find_large_dirs() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    app['du']="$(_koopa_locate_du)"
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local str
        prefix="$(_koopa_realpath "$prefix")"
        str="$( \
            "${app['du']}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app['sort']}" --numeric-sort \
            | "${app['tail']}" -n 50 \
            || true \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}

_koopa_find_large_files() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local str
        str="$( \
            _koopa_find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app['head']}" -n 50 \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}

_koopa_find_symlinks() {
    local -A dict
    local -a hits symlinks
    local symlink
    _koopa_assert_has_args "$#"
    dict['source_prefix']=''
    dict['target_prefix']=''
    dict['verbose']=0
    hits=()
    while (("$#"))
    do
        case "$1" in
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    _koopa_assert_is_dir "${dict['source_prefix']}" "${dict['target_prefix']}"
    dict['source_prefix']="$(_koopa_realpath "${dict['source_prefix']}")"
    dict['target_prefix']="$(_koopa_realpath "${dict['target_prefix']}")"
    readarray -t symlinks <<< "$(
        _koopa_find \
            --prefix="${dict['target_prefix']}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(_koopa_realpath "$symlink")"
        if _koopa_str_detect_regex \
            --pattern="^${dict['source_prefix']}/" \
            --string="$symlink_real"
        then
            if [[ "${dict['verbose']}" -eq 1 ]]
            then
                _koopa_warn "${symlink} -> ${symlink_real}"
            fi
            hits+=("$symlink")
        fi
    done
    _koopa_is_array_empty "${hits[@]}" && return 1
    _koopa_print "${hits[@]}"
    return 0
}

_koopa_find_user_profile() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['shell']="$(_koopa_default_shell_name)"
    case "${dict['shell']}" in
        'bash')
            dict['file']="${HOME}/.bashrc"
            ;;
        'zsh')
            dict['file']="${HOME}/.zshrc"
            ;;
        *)
            dict['file']="${HOME}/.profile"
            ;;
    esac
    [[ -n "${dict['file']}" ]] || return 1
    _koopa_print "${dict['file']}"
    return 0
}

_koopa_git_branch() {
    local -A app
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict2
            _koopa_cd "$repo"
            dict2['branch']="$( \
                "${app['git']}" branch --show-current \
                2>/dev/null \
            )"
            if [[ -z "${dict2['branch']}" ]]
            then
                dict2['branch']="$( \
                    "${app['git']}" branch 2>/dev/null \
                    | "${app['head']}" -n 1 \
                    | "${app['cut']}" -c '3-' \
                )"
            fi
            [[ -n "${dict2['branch']}" ]] || return 0
            _koopa_print "${dict2['branch']}"
        done
    )
    return 0
}

_koopa_git_clone() {
    local -A app dict
    local -a clone_args
    _koopa_assert_has_args "$#"
    if _koopa_is_install_subshell
    then
        app['git']="$(_koopa_locate_git --only-system)"
    else
        app['git']="$(_koopa_locate_git --allow-system)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    dict['branch']=''
    dict['commit']=''
    dict['prefix']=''
    dict['tag']=''
    dict['url']=''
    while (("$#"))
    do
        case "$1" in
            '--branch='*)
                dict['branch']="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict['branch']="${2:?}"
                shift 2
                ;;
            '--commit='*)
                dict['commit']="${1#*=}"
                shift 1
                ;;
            '--commit')
                dict['commit']="${2:?}"
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
            '--tag='*)
                dict['tag']="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict['tag']="${2:?}"
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
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        _koopa_rm "${dict['prefix']}"
    fi
    if _koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@github.com'
    then
        _koopa_assert_is_github_ssh_enabled
    elif _koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@gitlab.com'
    then
        _koopa_assert_is_gitlab_ssh_enabled
    fi
    clone_args=(
        '--quiet'
    )
    if [[ -n "${dict['branch']}" ]]
    then
        clone_args+=(
            '--depth=1'
            '--single-branch'
            "--branch=${dict['branch']}"
        )
    else
        clone_args+=(
            '--filter=blob:none'
        )
    fi
    clone_args+=("${dict['url']}" "${dict['prefix']}")
    "${app['git']}" clone "${clone_args[@]}"
    if [[ -n "${dict['commit']}" ]]
    then
        (
            _koopa_cd "${dict['prefix']}"
            "${app['git']}" checkout --quiet "${dict['commit']}"
        )
    elif [[ -n "${dict['tag']}" ]]
    then
        (
            _koopa_cd "${dict['prefix']}"
            "${app['git']}" fetch --quiet --tags
            "${app['git']}" checkout --quiet "tags/${dict['tag']}"
        )
    fi
    return 0
}

_koopa_git_commit_date() {
    local -A app
    _koopa_assert_has_args "$#"
    app['date']="$(_koopa_locate_date --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            _koopa_cd "$repo"
            string="$( \
                "${app['git']}" log -1 --format='%at' \
                | "${app['xargs']}" -I '{}' \
                "${app['date']}" -d '@{}' '+%Y-%m-%d' \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}

_koopa_git_default_branch() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['remote']='origin'
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            _koopa_cd "$repo"
            string="$( \
                "${app['git']}" remote show "${dict['remote']}" \
                | _koopa_grep --pattern='HEAD branch' \
                | "${app['sed']}" 's/.*: //' \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}

_koopa_git_last_commit_local() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['ref']='HEAD'
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            _koopa_cd "$repo"
            string="$( \
                "${app['git']}" rev-parse "${dict['ref']}" \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}

_koopa_git_last_commit_remote() {
    local -A app dict
    local url
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['ref']='HEAD'
    for url in "$@"
    do
        local string
        string="$( \
            "${app['git']}" ls-remote --quiet "$url" "${dict['ref']}" \
            | "${app['head']}" -n 1 \
            | "${app['awk']}" '{ print $1 }' \
        )"
        [[ -n "$string" ]] || return 1
        _koopa_print "$string"
    done
    return 0
}

_koopa_git_latest_tag() {
    local -A app
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local rev tag
            _koopa_cd "$repo"
            rev="$("${app['git']}" rev-list --tags --max-count=1)"
            tag="$("${app['git']}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            _koopa_print "$tag"
        done
    )
    return 0
}

_koopa_git_pull() {
    local -A app bool
    _koopa_assert_has_args "$#"
    bool['sys_git']=0
    app['git']="$(_koopa_locate_git --allow-missing)"
    if [[ ! -x "${app['git']}" ]]
    then
        bool['sys_git']=1
        app['git']="$(_koopa_locate_git --allow-system)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Pulling Git repo at '${repo}'."
            _koopa_cd "$repo"
            if [[ "${bool['sys_git']}" -eq 1 ]]
            then
                "${app['git']}" fetch --all
                "${app['git']}" pull --all
            else
                "${app['git']}" fetch --all --quiet
                "${app['git']}" pull --all --no-rebase --recurse-submodules
            fi
        done
    )
    return 0
}

_koopa_git_push_submodules() {
    local -A app
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            _koopa_cd "$repo"
            "${app['git']}" submodule update --remote --merge
            "${app['git']}" commit -m 'Update submodules.'
            "${app['git']}" push
        done
    )
    return 0
}

_koopa_git_remote_url() {
    local -A app
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            _koopa_cd "$repo"
            string="$( \
                "${app['git']}" config --get 'remote.origin.url' \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}

_koopa_git_rename_master_to_main() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['old_branch']='master'
    dict['new_branch']='main'
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            _koopa_cd "$repo"
            "${app['git']}" switch "${dict['old_branch']}"
            "${app['git']}" branch --move \
                "${dict['old_branch']}" \
                "${dict['new_branch']}"
            "${app['git']}" switch "${dict['new_branch']}"
            "${app['git']}" fetch --all --prune "${dict['origin']}"
            "${app['git']}" branch --unset-upstream
            "${app['git']}" branch \
                --set-upstream-to="${dict['origin']}/${dict['new_branch']}" \
                "${dict['new_branch']}"
            "${app['git']}" push --set-upstream \
                "${dict['origin']}" \
                "${dict['new_branch']}"
            "${app['git']}" push \
                "${dict['origin']}" \
                --delete "${dict['old_branch']}" \
                || true
            "${app['git']}" remote set-head "${dict['origin']}" --auto
        done
    )
    return 0
}

_koopa_git_repo_has_unstaged_changes() {
    local -A app dict
    app['git']="$(_koopa_locate_git)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['git']}" update-index --refresh &>/dev/null
    dict['string']="$("${app['git']}" diff-index 'HEAD' -- 2>/dev/null)"
    [[ -n "${dict['string']}" ]]
}

_koopa_git_repo_needs_pull_or_push() {
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git)"
    _koopa_assert_is_executable "${app[@]}"
    (
        for prefix in "$@"
        do
            local -A dict
            dict['prefix']="$prefix"
            _koopa_cd "${dict['prefix']}"
            dict['rev1']="$("${app['git']}" rev-parse 'HEAD' 2>/dev/null)"
            dict['rev2']="$("${app['git']}" rev-parse '@{u}' 2>/dev/null)"
            [[ "${dict['rev1']}" != "${dict['rev2']}" ]] && return 0
        done
        return 1
    )
}

_koopa_git_reset_fork_to_upstream() {
    local -A app
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            _koopa_cd "$repo"
            dict['branch']="$(_koopa_git_default_branch "${PWD:?}")"
            dict['origin']='origin'
            dict['upstream']='upstream'
            "${app['git']}" checkout "${dict['branch']}"
            "${app['git']}" fetch "${dict['upstream']}"
            "${app['git']}" reset --hard "${dict['upstream']}/${dict['branch']}"
            "${app['git']}" push "${dict['origin']}" "${dict['branch']}" --force
        done
    )
    return 0
}

_koopa_git_reset() {
    local -A app
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Resetting Git repo at '${repo}'."
            _koopa_cd "$repo"
            "${app['git']}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                _koopa_git_submodule_init "$repo"
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" clean -dffx
                "${app['git']}" reset --hard --quiet
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" reset --hard --quiet
            fi
        done
    )
    return 0
}

_koopa_git_rm_submodule() {
    local -A app
    local module
    _koopa_assert_has_args "$#"
    _koopa_assert_is_git_repo
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for module in "$@"
    do
        "${app['git']}" submodule deinit -f "$module"
        _koopa_rm ".git/modules/${module}"
        "${app['git']}" rm -f "$module"
        "${app['git']}" add '.gitmodules'
        "${app['git']}" commit -m "Removed submodule '${module}'."
    done
    return 0
}

_koopa_git_rm_untracked() {
    local -A app
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Removing untracked files in '${repo}'."
            _koopa_cd "$repo"
            _koopa_assert_is_git_repo
            "${app['git']}" clean -dfx
        done
    )
    return 0
}

_koopa_git_set_remote_url() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['prefix']="${1:?}"
    dict['url']="${2:?}"
    _koopa_assert_is_git_repo "${dict['prefix']}"
    (
        _koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    )
    return 0
}

_koopa_git_submodule_init() {
    local -A app
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            local -a lines
            local string
            dict['module_file']='.gitmodules'
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Initializing submodules in '${repo}'."
            _koopa_cd "$repo"
            _koopa_assert_is_git_repo
            _koopa_assert_is_nonzero_file "${dict['module_file']}"
            "${app['git']}" submodule init
            readarray -t lines <<< "$(
                "${app['git']}" config \
                    --file "${dict['module_file']}" \
                    --get-regexp '^submodule\..*\.path$' \
            )"
            if _koopa_is_array_empty "${lines[@]:-}"
            then
                _koopa_stop "Failed to detect submodules in '${repo}'."
            fi
            for string in "${lines[@]}"
            do
                local -A dict2
                dict2['target_key']="$( \
                    _koopa_print "$string" \
                    | "${app['awk']}" '{ print $1 }' \
                )"
                dict2['target']="$( \
                    _koopa_print "$string" \
                    | "${app['awk']}" '{ print $2 }' \
                )"
                dict2['url_key']="${dict2['target_key']//\.path/.url}"
                dict2['url']="$( \
                    "${app['git']}" config \
                        --file "${dict['module_file']}" \
                        --get "${dict2['url_key']}" \
                )"
                _koopa_dl "${dict2['target']}" "${dict2['url']}"
                if [[ ! -d "${dict2['target']}" ]]
                then
                    "${app['git']}" submodule add --force \
                        "${dict2['url']}" "${dict2['target']}" > /dev/null
                fi
            done
        done
    )
    return 0
}

_koopa_install_ack() {
    _koopa_install_app \
        --name='ack' \
        "$@"
}

_koopa_install_agat() {
    _koopa_install_app \
        --name='agat' \
        "$@"
}

_koopa_install_air() {
    _koopa_install_app \
        --name='air' \
        "$@"
}

_koopa_install_all_apps() {
    _koopa_assert_has_no_args "$#"
    _koopa_install_shared_apps --all "$@"
    return 0
}

_koopa_install_anaconda() {
    _koopa_alert_note "Usage of full Anaconda distribution at an organization \
of more than 200 employees requires a Business or Enterprise license. Refer \
to 'https://www.anaconda.com/pricing' for details."
    _koopa_install_app \
        --name='anaconda' \
        "$@"
}

_koopa_install_apache_airflow() {
    _koopa_install_app \
        --installer='python-package' \
        --name='apache-airflow' \
        -D --egg-name='apache_airflow_core' \
        -D --python-version='3.13' \
        "$@"
}

_koopa_install_apache_arrow() {
    _koopa_install_app \
        --name='apache-arrow' \
        "$@"
}

_koopa_install_apache_spark() {
    _koopa_install_app \
        --name='apache-spark' \
        "$@"
}

_koopa_install_app_from_binary_package() {
    local -A app dict
    local prefix
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws --allow-system)"
    app['tar']="$(_koopa_locate_tar --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch2)" # e.g. 'amd64'.
    dict['aws_profile']='acidgenomics'
    dict['binary_prefix']='/opt/koopa'
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['os_string']="$(_koopa_os_string)"
    dict['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    if [[ "${dict['_koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        _koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['_koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -A dict2
        dict2['prefix']="$(_koopa_realpath "$prefix")"
        dict2['name']="$( \
            _koopa_print "${dict2['prefix']}" \
                | _koopa_dirname \
                | _koopa_basename \
        )"
        dict2['version']="$(_koopa_basename "$prefix")"
        dict2['tar_file']="${dict['tmp_dir']}/${dict2['name']}-\
${dict2['version']}.tar.gz"
        dict2['tar_url']="${dict['s3_bucket']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
        "${app['aws']}" s3 cp \
            --profile "${dict['aws_profile']}" \
            "${dict2['tar_url']}" \
            "${dict2['tar_file']}"
        _koopa_assert_is_file "${dict2['tar_file']}"
        "${app['tar']}" -Pxz -f "${dict2['tar_file']}"
        _koopa_touch "${prefix}/.koopa-binary"
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_install_app_subshell() {
    local -A dict
    local -a pos
    _koopa_assert_is_install_subshell
    dict['installer_bn']=''
    dict['installer_fun']='main'
    dict['mode']='shared'
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['platform']='common'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--installer='*)
                dict['installer_bn']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer_bn']="${2:?}"
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
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '-D')
                pos+=("${2:?}")
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict['installer_bn']}" ]] && dict['installer_bn']="${dict['name']}"
    dict['installer_file']="$(_koopa_bash_prefix)/include/install/\
${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
    _koopa_assert_is_file "${dict['installer_file']}"
    (
        _koopa_cd "${dict['tmp_dir']}"
        export KOOPA_INSTALL_NAME="${dict['name']}"
        export KOOPA_INSTALL_PREFIX="${dict['prefix']}"
        export KOOPA_INSTALL_VERSION="${dict['version']}"
        source "${dict['installer_file']}"
        _koopa_assert_is_function "${dict['installer_fun']}"
        "${dict['installer_fun']}" "$@"
        return 0
    )
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_install_app() {
    local -A app bool dict
    local -a bash_vars bin_arr env_vars man1_arr path_arr pos
    local i
    _koopa_assert_has_args "$#"
    _koopa_check_build_system
    bool['auto_prefix']=0
    bool['binary']=0
    _koopa_can_install_binary && bool['binary']=1
    bool['bootstrap']=0
    bool['copy_log_files']=0
    bool['deps']=1
    bool['inherit_env']=0
    _koopa_is_lmod_active && bool['inherit_env']=1
    bool['isolate']=1
    bool['link_in_bin']=0
    bool['link_in_man1']=0
    bool['link_in_opt']=0
    bool['prefix_check']=1
    bool['private']=0
    bool['push']=0
    _koopa_can_push_binary && bool['push']=1
    bool['quiet']=0
    bool['reinstall']=0
    bool['update_ldconfig']=0
    bool['verbose']=0
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['cpu_count']="$(_koopa_cpu_count)"
    dict['installer']=''
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
    dict['prefix']=''
    dict['version']=''
    dict['version_key']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--installer='*)
                dict['installer']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer']="${2:?}"
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--version-key='*)
                dict['version_key']="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict['version_key']="${2:?}"
                shift 2
                ;;
            '--bootstrap')
                bool['bootstrap']=1
                shift 1
                ;;
            '--reinstall')
                bool['reinstall']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            '--no-dependencies')
                bool['deps']=0
                shift 1
                ;;
            '--private')
                bool['private']=1
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '-D')
                pos+=("${1:?}" "${2:?}")
                shift 2
                ;;
            '')
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    [[ "${dict['mode']}" != 'shared' ]] && bool['deps']=0
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        _koopa_app_json_version "${dict['version_key']}" 2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            _koopa_assert_is_owner
            if [[ -z "${dict['prefix']}" ]]
            then
                bool['auto_prefix']=1
                dict['version2']="${dict['version']}"
                [[ "${#dict['version']}" == 40 ]] && \
                    dict['version2']="${dict['version2']:0:7}"
                dict['prefix']="${dict['app_prefix']}/${dict['name']}/\
${dict['version2']}"
            fi
            if [[ "${dict['version']}" == "${dict['current_version']}" ]]
            then
                bool['link_in_bin']=1
                bool['link_in_man1']=1
                bool['link_in_opt']=1
            fi
            ;;
        'system')
            _koopa_assert_is_owner
            _koopa_assert_is_admin
            bool['isolate']=0
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['prefix_check']=0
            bool['push']=0
            _koopa_is_linux && bool['update_ldconfig']=1
            ;;
        'user')
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['push']=0
            ;;
    esac
    if [[ "${bool['binary']}" -eq 1 ]] || \
        [[ "${bool['private']}" -eq 1 ]] || \
        [[ "${bool['push']}" -eq 1 ]]
    then
        _koopa_assert_has_private_access
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ "${bool['prefix_check']}" -eq 1 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            if [[ ! -f "${dict['prefix']}/.koopa-install-stdout.log" ]]
            then
                bool['reinstall']=1
            fi
            if [[ "${bool['reinstall']}" -eq 1 ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    _koopa_alert_uninstall_start \
                        "${dict['name']}" "${dict['prefix']}"
                case "${dict['mode']}" in
                    'system')
                        _koopa_rm --sudo "${dict['prefix']}"
                        ;;
                    *)
                        _koopa_rm "${dict['prefix']}"
                        ;;
                esac
            fi
            [[ -d "${dict['prefix']}" ]] && return 0
        fi
    fi
    if [[ "${bool['deps']}" -eq 1 ]]
    then
        local dep deps deps_str
        deps_str="$(_koopa_app_dependencies "${dict['name']}")" || \
            _koopa_stop "Failed to resolve dependencies for '${dict['name']}'."
        readarray -t deps <<< "$deps_str"
        if _koopa_is_array_non_empty "${deps[@]:-}"
        then
            _koopa_dl \
                "${dict['name']} dependencies" \
                "$(_koopa_to_string "${deps[@]}")"
            for dep in "${deps[@]}"
            do
                local -a dep_install_args
                if [[ -d "$(_koopa_app_prefix --allow-missing "$dep")" ]]
                then
                    continue
                fi
                dep_install_args=()
                if [[ "${bool['bootstrap']}" -eq 1 ]]
                then
                    dep_install_args+=('--bootstrap')
                fi
                if [[ "${bool['verbose']}" -eq 1 ]]
                then
                    dep_install_args+=('--verbose')
                fi
                dep_install_args+=("$dep")
                _koopa_cli_install "${dep_install_args[@]}"
            done
        fi
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ ! -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(_koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(_koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        [[ "${dict['mode']}" == 'shared' ]] || return 1
        [[ -n "${dict['prefix']}" ]] || return 1
        _koopa_install_app_from_binary_package "${dict['prefix']}"
    elif [[ "${bool['isolate']}" -eq 0 ]]
    then
        export KOOPA_INSTALL_APP_SUBSHELL=1
        _koopa_install_app_subshell \
            --installer="${dict['installer']}" \
            --mode="${dict['mode']}" \
            --name="${dict['name']}" \
            --platform="${dict['platform']}" \
            --prefix="${dict['prefix']}" \
            --version="${dict['version']}" \
            "$@"
        unset -v KOOPA_INSTALL_APP_SUBSHELL
    else
        if [[ "${bool['bootstrap']}" -eq 1 ]]
        then
            app['bash']="${KOOPA_BOOTSTRAP_PREFIX:?}/bin/bash"
        else
            app['bash']="$(_koopa_locate_bash --allow-missing)"
            if [[ ! -x "${app['bash']}" ]]
            then
                if _koopa_is_macos
                then
                    app['bash']="$(_koopa_locate_bash --allow-bootstrap)"
                else
                    app['bash']="$(_koopa_locate_bash --allow-system)"
                fi
            fi
        fi
        app['env']="$(_koopa_locate_env --allow-system)"
        app['tee']="$(_koopa_locate_tee --allow-system)"
        _koopa_assert_is_executable "${app[@]}"
        if [[ "${bool['inherit_env']}" -eq 1 ]]
        then
            dict['path']="${PATH:?}"
            env_vars+=(
                "CC=${CC:-}"
                "CPATH=${CPATH:-}"
                "CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH:-}"
                "CXX=${CXX:-}"
                "C_INCLUDE_PATH=${C_INCLUDE_PATH:-}"
                "F77=${F77:-}"
                "FC=${FC:-}"
                "INCLUDE=${INCLUDE:-}"
                "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
                "LIBRARY_PATH=${LIBRARY_PATH:-}"
                "PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}"
            )
        else
            path_arr+=('/usr/bin' '/usr/sbin' '/bin' '/sbin')
            dict['path']="$(_koopa_paste --sep=':' "${path_arr[@]}")"
        fi
        env_vars+=(
            "HOME=${HOME:?}"
            'KOOPA_ACTIVATE=0'
            "KOOPA_CPU_COUNT=${dict['cpu_count']}"
            'KOOPA_INSTALL_APP_SUBSHELL=1'
            "KOOPA_VERBOSE=${bool['verbose']}"
            'LANG=C'
            'LC_ALL=C'
            "PATH=${dict['path']}"
            "PWD=${HOME:?}"
            "TMPDIR=${TMPDIR:-/tmp}"
        )
        [[ -n "${KOOPA_CAN_INSTALL_BINARY:-}" ]] && \
            env_vars+=("KOOPA_CAN_INSTALL_BINARY=${KOOPA_CAN_INSTALL_BINARY:?}")
        [[ -n "${AWS_CA_BUNDLE:-}" ]] && \
            env_vars+=("AWS_CA_BUNDLE=${AWS_CA_BUNDLE:-}")
        [[ -n "${DEFAULT_CA_BUNDLE_PATH:-}" ]] && \
            env_vars+=("DEFAULT_CA_BUNDLE_PATH=${DEFAULT_CA_BUNDLE_PATH:-}")
        [[ -n "${NODE_EXTRA_CA_CERTS:-}" ]] && \
            env_vars+=("NODE_EXTRA_CA_CERTS=${NODE_EXTRA_CA_CERTS:-}")
        [[ -n "${REQUESTS_CA_BUNDLE:-}" ]] && \
            env_vars+=("REQUESTS_CA_BUNDLE=${REQUESTS_CA_BUNDLE:-}")
        [[ -n "${SSL_CERT_FILE:-}" ]] && \
            env_vars+=("SSL_CERT_FILE=${SSL_CERT_FILE:-}")
        [[ -n "${HTTP_PROXY:-}" ]] && \
            env_vars+=("HTTP_PROXY=${HTTP_PROXY:?}")
        [[ -n "${HTTPS_PROXY:-}" ]] && \
            env_vars+=("HTTPS_PROXY=${HTTPS_PROXY:?}")
        [[ -n "${http_proxy:-}" ]] && \
            env_vars+=("http_proxy=${http_proxy:?}")
        [[ -n "${https_proxy:-}" ]] && \
            env_vars+=("https_proxy=${https_proxy:?}")
        [[ -n "${GOPROXY:-}" ]] && \
            env_vars+=("GOPROXY=${GOPROXY:-}")
        [[ -n "${PYTHON_BUILD_MIRROR_URL:-}" ]] && \
            env_vars+=("PYTHON_BUILD_MIRROR_URL=${PYTHON_BUILD_MIRROR_URL:-}")
        if [[ "${dict['mode']}" == 'shared' ]] \
            && [[ "${bool['inherit_env']}" -eq 0 ]]
        then
            PKG_CONFIG_PATH=''
            app['pkg_config']="$( \
                _koopa_locate_pkg_config --allow-missing --only-system \
            )"
            if [[ -x "${app['pkg_config']}" ]]
            then
                _koopa_activate_pkg_config "${app['pkg_config']}"
            fi
            env_vars+=("PKG_CONFIG_PATH=${PKG_CONFIG_PATH}")
            unset -v PKG_CONFIG_PATH
        fi
        if [[ "${dict['mode']}" == 'shared' ]] \
            && [[ -d "${dict['prefix']}" ]]
        then
            bool['copy_log_files']=1
        fi
        dict['header_file']="$(_koopa_bash_prefix)/include/header.sh"
        dict['stderr_file']="$(_koopa_tmp_log_file)"
        dict['stdout_file']="$(_koopa_tmp_log_file)"
        _koopa_assert_is_file \
            "${dict['header_file']}" \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
        trap "_koopa_rm \
            '${dict['stderr_file']}' \
            '${dict['stdout_file']}'" \
            EXIT
        bash_vars=(
            '--noprofile'
            '--norc'
            '-o' 'errexit'
            '-o' 'errtrace'
            '-o' 'nounset'
            '-o' 'pipefail'
        )
        if [[ "${bool['verbose']}" -eq 1 ]]
        then
            bash_vars+=('-o' 'verbose')
        fi
        local -a subshell_args
        subshell_args=(
            "--installer='${dict['installer']}'"
            "--mode='${dict['mode']}'"
            "--name='${dict['name']}'"
            "--platform='${dict['platform']}'"
            "--prefix='${dict['prefix']}'"
            "--version='${dict['version']}'"
        )
        local arg
        for arg in "$@"
        do
            subshell_args+=("'${arg}'")
        done
        "${app['env']}" -i \
            "${env_vars[@]}" \
            "${app['bash']}" \
                "${bash_vars[@]}" \
                -c "source '${dict['header_file']}'; \
                    _koopa_install_app_subshell \
                        ${subshell_args[*]}" \
            > >("${app['tee']}" "${dict['stdout_file']}") \
            2> >("${app['tee']}" "${dict['stderr_file']}" >&2)
        if [[ "${bool['copy_log_files']}" -eq 1 ]] && \
            [[ -d "${dict['prefix']}" ]]
        then
            _koopa_cp \
                "${dict['stdout_file']}" \
                "${dict['prefix']}/.koopa-install-stdout.log"
            _koopa_cp \
                "${dict['stderr_file']}" \
                "${dict['prefix']}/.koopa-install-stderr.log"
        fi
        _koopa_rm \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
        trap - EXIT
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['link_in_opt']}" -eq 1 ]]
            then
                _koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            fi
            if [[ "${bool['link_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    _koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    for i in "${!bin_arr[@]}"
                    do
                        local -A dict2
                        dict2['name']="${bin_arr[$i]}"
                        dict2['source']="${dict['prefix']}/bin/${dict2['name']}"
                        _koopa_link_in_bin \
                            --name="${dict2['name']}" \
                            --source="${dict2['source']}"
                    done
                fi
            fi
            if [[ "${bool['link_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    _koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    for i in "${!man1_arr[@]}"
                    do
                        local -A dict2
                        dict2['name']="${man1_arr[$i]}"
                        dict2['mf1']="${dict['prefix']}/share/man/\
man1/${dict2['name']}"
                        dict2['mf2']="${dict['prefix']}/man/\
man1/${dict2['name']}"
                        if [[ -f "${dict2['mf1']}" ]]
                        then
                            _koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf1']}"
                        elif [[ -f "${dict2['mf2']}" ]]
                        then
                            _koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf2']}"
                        fi
                    done
                fi
            fi
            if [[ "${bool['push']}" -eq 1 ]]
            then
                _koopa_push_app_build "${dict['name']}"
            fi
            ;;
        'system')
            if [[ "${bool['update_ldconfig']}" -eq 1 ]]
            then
                _koopa_linux_update_ldconfig
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
    fi
    return 0
}

_koopa_install_apr_util() {
    _koopa_install_app \
        --name='apr-util' \
        "$@"
}

_koopa_install_apr() {
    _koopa_install_app \
        --name='apr' \
        "$@"
}

_koopa_install_aria2() {
    _koopa_install_app \
        --name='aria2' \
        "$@"
}

_koopa_install_armadillo() {
    _koopa_install_app \
        --name='armadillo' \
        "$@"
}

_koopa_install_asdf() {
    _koopa_install_app \
        --name='asdf' \
        "$@"
}

_koopa_install_aspell() {
    _koopa_install_app \
        --name='aspell' \
        "$@"
}

_koopa_install_autoconf() {
    _koopa_install_app \
        --name='autoconf' \
        "$@"
}

_koopa_install_autodock_adfr() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='autodock-adfr' \
        "$@"
}

_koopa_install_autodock_vina() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='autodock-vina' \
        "$@"
}

_koopa_install_autodock() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='autodock' \
        "$@"
}

_koopa_install_autoflake() {
    _koopa_install_app \
        --installer='python-package' \
        --name='autoflake' \
        "$@"
}

_koopa_install_automake() {
    _koopa_install_app \
        --name='automake' \
        "$@"
}

_koopa_install_aws_azure_login() {
    _koopa_install_app \
        --installer='node-package' \
        --name='aws-azure-login' \
        "$@"
}

_koopa_install_aws_cli() {
    _koopa_install_app \
        --name='aws-cli' \
        "$@"
}

_koopa_install_axel() {
    _koopa_install_app \
        --name='axel' \
        "$@"
}

_koopa_install_azure_cli() {
    _koopa_install_app \
        --installer='python-package' \
        --name='azure-cli' \
        -D --python-version='3.13' \
        "$@"
}

_koopa_install_bamtools() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bamtools' \
        "$@"
}

_koopa_install_bandit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='bandit' \
        "$@"
}

_koopa_install_bandwhich() {
    _koopa_install_app \
        --installer='rust-package' \
        --name='bandwhich' \
        "$@"
}

_koopa_install_bash_completion() {
    _koopa_install_app \
        --name='bash-completion' \
        "$@"
}

_koopa_install_bash_language_server() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bash-language-server' \
        "$@"
}

_koopa_install_bash() {
    _koopa_install_app \
        --name='bash' \
        "$@"
    return 0
}

_koopa_install_bashcov() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='bashcov' \
        "$@"
}

_koopa_install_bat() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bat' \
        "$@"
}

_koopa_install_bc() {
    _koopa_install_app \
        --name='bc' \
        "$@"
}

_koopa_install_bedtools() {
    if _koopa_is_macos && _koopa_is_arm64
    then
        _koopa_install_app \
            --name='bedtools' \
            "$@"
    else
        _koopa_install_app \
            --installer='conda-package' \
            --name='bedtools' \
            "$@"
    fi
}

_koopa_install_bfg() {
    _koopa_install_app \
        --name='bfg' \
        "$@"
}

_koopa_install_binutils() {
    _koopa_install_app \
        --name='binutils' \
        "$@"
}

_koopa_install_bioawk() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bioawk' \
        "$@"
}

_koopa_install_bioconda_utils() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bioconda-utils' \
        "$@"
}

_koopa_install_bison() {
    _koopa_install_app \
        --name='bison' \
        "$@"
}

_koopa_install_black() {
    _koopa_install_app \
        --installer='python-package' \
        --name='black' \
        -D --pip-name='black[d]' \
        "$@"
}

_koopa_install_blast() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='blast' \
        "$@"
}

_koopa_install_boost() {
    _koopa_install_app \
        --name='boost' \
        "$@"
}

_koopa_install_bottom() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bottom' \
        "$@"
}

_koopa_install_bowtie2() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bowtie2' \
        "$@"
}

_koopa_install_bpytop() {
    _koopa_install_app \
        --installer='python-package' \
        --name='bpytop' \
        "$@"
}

_koopa_install_broot() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='broot' \
        "$@"
}

_koopa_install_brotli() {
    _koopa_install_app \
        --name='brotli' \
        "$@"
}

_koopa_install_btop() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='btop' \
        "$@"
}

_koopa_install_bustools() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='bustools' \
        "$@"
}

_koopa_install_byobu() {
    _koopa_install_app \
        --name='byobu' \
        "$@"
}

_koopa_install_bzip2() {
    _koopa_install_app \
        --name='bzip2' \
        "$@"
}

_koopa_install_c_ares() {
    _koopa_install_app \
        --name='c-ares' \
        "$@"
}

_koopa_install_ca_certificates() {
    _koopa_install_app \
        --name='ca-certificates' \
        "$@"
}

_koopa_install_cairo() {
    _koopa_install_app \
        --name='cairo' \
        "$@"
}

_koopa_install_cereal() {
    _koopa_install_app \
        --name='cereal' \
        "$@"
}

_koopa_install_cheat() {
    _koopa_install_app \
        --name='cheat' \
        "$@"
}

_koopa_install_chezmoi() {
    _koopa_install_app \
        --name='chezmoi' \
        "$@"
}

_koopa_install_claude_code() {
    _koopa_install_app \
        --name='claude-code' \
        "$@"
}

_koopa_install_cli11() {
    _koopa_install_app \
        --name='cli11' \
        "$@"
}

_koopa_install_cmake() {
    _koopa_install_app \
        --name='cmake' \
        "$@"
}

_koopa_install_colorls() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='colorls' \
        "$@"
}

_koopa_install_commitizen() {
    _koopa_install_app \
        --installer='python-package' \
        --name='commitizen' \
        "$@"
}

_koopa_install_conda_package() {
    local -A app dict
    local -a bin_names create_args pos
    local bin_name
    _koopa_assert_is_install_subshell
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['channels']=''
    dict['yaml_file']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
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
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['name']}" \
        '--version' "${dict['name']}"
    create_args=()
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    create_args+=("--prefix=${dict['libexec']}")
    if [[ -n "${dict['yaml_file']}" ]]
    then
        _koopa_assert_is_file "${dict['yaml_file']}"
        create_args+=("--file=${dict['yaml_file']}")
    else
        dict['channels']="$("${app['conda']}" config --show channels)"
        if ! _koopa_str_detect_fixed \
                --pattern='conda-forge' \
                --string="${dict['channels']}"
        then
            create_args+=(
                '--channel=conda-forge'
                '--channel=bioconda'
            )
        fi
        create_args+=("${dict['name']}==${dict['version']}")
    fi
    _koopa_dl 'conda create env args' "${create_args[*]}"
    if _koopa_is_verbose
    then
        "${app['conda']}" config --json --show
        "${app['conda']}" config --json --show-sources
    fi
    _koopa_conda_create_env "${create_args[@]}"
    dict['json_pattern']="${dict['name']}-${dict['version']}-*.json"
    case "${dict['name']}" in
        'snakemake')
            dict['json_pattern']="${dict['name']}-minimal-*.json"
            ;;
    esac
    dict['json_file']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['json_pattern']}" \
            --prefix="${dict['libexec']}/conda-meta" \
            --type='f' \
    )"
    _koopa_assert_is_file "${dict['json_file']}"
    readarray -t bin_names <<< "$( \
        _koopa_conda_bin_names "${dict['json_file']}" \
    )"
    if _koopa_is_array_non_empty "${bin_names[@]:-}"
    then
        for bin_name in "${bin_names[@]}"
        do
            local -A dict2
            dict2['name']="$bin_name"
            dict2['bin_source']="${dict['libexec']}/bin/${dict2['name']}"
            dict2['bin_target']="${dict['prefix']}/bin/${dict2['name']}"
            dict2['man1_source']="${dict['libexec']}/share/man/\
man1/${dict2['name']}.1"
            dict2['man1_target']="${dict['prefix']}/share/man/\
man1/${dict2['name']}.1"
            _koopa_assert_is_file "${dict2['bin_source']}"
            _koopa_ln "${dict2['bin_source']}" "${dict2['bin_target']}"
            if [[ -f "${dict2['man1_source']}" ]]
            then
                _koopa_ln "${dict2['man1_source']}" "${dict2['man1_target']}"
            fi
        done
    fi
    return 0
}

_koopa_install_conda() {
    if _koopa_is_macos && _koopa_is_amd64
    then
        _koopa_stop 'Conda build support for Intel Macs is now deprecated.'
    fi
    _koopa_install_app \
        --name='conda' \
        "$@"
}

_koopa_install_convmv() {
    _koopa_install_app \
        --name='convmv' \
        "$@"
}

_koopa_install_coreutils() {
    _koopa_install_app \
        --name='coreutils' \
        "$@"
}

_koopa_install_cpufetch() {
    _koopa_install_app \
        --name='cpufetch' \
        "$@"
}

_koopa_install_csvkit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='csvkit' \
        "$@"
}

_koopa_install_csvtk() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='csvtk' \
        "$@"
}

_koopa_install_curl() {
    _koopa_install_app \
        --name='curl' \
        "$@"
}

_koopa_install_dash() {
    _koopa_install_app \
        --name='dash' \
        "$@"
    return 0
}

_koopa_install_databricks_cli() {
    _koopa_install_app \
        --name='databricks-cli' \
        "$@"
}

_koopa_install_deeptools() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='deeptools' \
        "$@"
}

_koopa_install_default_apps() {
    _koopa_assert_has_no_args "$#"
    _koopa_install_shared_apps "$@"
    return 0
}

_koopa_install_delta() {
    _koopa_install_app \
        --name='delta' \
        "$@"
}

_koopa_install_diff_so_fancy() {
    _koopa_install_app \
        --name='diff-so-fancy' \
        "$@"
}

_koopa_install_difftastic() {
    if _koopa_is_macos
    then
        _koopa_assert_is_not_amd64
    fi
    _koopa_install_app \
        --installer='conda-package' \
        --name='difftastic' \
        "$@"
}

_koopa_install_direnv() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='direnv' \
        "$@"
}

_koopa_install_docker_credential_helpers() {
    _koopa_install_app \
        --name='docker-credential-helpers' \
        "$@"
}

_koopa_install_dotfiles() {
    _koopa_install_app \
        --name='dotfiles' \
        "$@"
}

_koopa_install_du_dust() {
    _koopa_install_app \
        --name='du-dust' \
        "$@"
}

_koopa_install_duckdb() {
    _koopa_install_app \
        --name='duckdb' \
        "$@"
}

_koopa_install_ed() {
    _koopa_install_app \
        --name='ed' \
        "$@"
}

_koopa_install_editorconfig() {
    _koopa_install_app \
        --name='editorconfig' \
        "$@"
}

_koopa_install_emacs() {
    _koopa_install_app \
        --name='emacs' \
        "$@"
}

_koopa_install_ensembl_perl_api() {
    _koopa_install_app \
        --name='ensembl-perl-api' \
        "$@"
}

_koopa_install_entrez_direct() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='entrez-direct' \
        "$@"
}

_koopa_install_exiftool() {
    _koopa_install_app \
        --name='exiftool' \
        "$@"
}

_koopa_install_expat() {
    _koopa_install_app \
        --name='expat' \
        "$@"
}

_koopa_install_eza() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='eza' \
        "$@"
}

_koopa_install_fastqc() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='fastqc' \
        "$@"
}

_koopa_install_fd_find() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fd-find' \
        "$@"
}

_koopa_install_ffmpeg() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ffmpeg' \
        "$@"
}

_koopa_install_ffq() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='ffq' \
        "$@"
}

_koopa_install_fgbio() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fgbio' \
        "$@"
}

_koopa_install_findutils() {
    _koopa_install_app \
        --name='findutils' \
        "$@"
}

_koopa_install_fish() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fish' \
        "$@"
}

_koopa_install_flac() {
    _koopa_install_app \
        --name='flac' \
        "$@"
}

_koopa_install_flake8() {
    _koopa_install_app \
        --installer='python-package' \
        --name='flake8' \
        "$@"
}

_koopa_install_flex() {
    _koopa_install_app \
        --name='flex' \
        "$@"
}

_koopa_install_fltk() {
    _koopa_install_app \
        --name='fltk' \
        "$@"
}

_koopa_install_fmt() {
    _koopa_install_app \
        --name='fmt' \
        "$@"
}

_koopa_install_fontconfig() {
    _koopa_install_app \
        --name='fontconfig' \
        "$@"
}

_koopa_install_fq() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='fq' \
        "$@"
}

_koopa_install_fqtk() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='fqtk' \
        "$@"
}

_koopa_install_freetype() {
    _koopa_install_app \
        --name='freetype' \
        "$@"
}

_koopa_install_fribidi() {
    _koopa_install_app \
        --name='fribidi' \
        "$@"
}

_koopa_install_fzf() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fzf' \
        "$@"
}

_koopa_install_gatk() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='gatk' \
        "$@"
}

_koopa_install_gawk() {
    _koopa_install_app \
        --name='gawk' \
        "$@"
}

_koopa_install_gdal() {
    _koopa_install_app \
        --name='gdal' \
        "$@"
}

_koopa_install_gdbm() {
    _koopa_install_app \
        --name='gdbm' \
        "$@"
}

_koopa_install_gdc_client() {
    _koopa_install_app \
        --name='gdc-client' \
        "$@"
}

_koopa_install_gemini_cli() {
    _koopa_install_app \
        --name='gemini-cli' \
        "$@"
}

_koopa_install_genomepy() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='genomepy' \
        "$@"
}

_koopa_install_gentropy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='gentropy' \
        -D --python-version='3.10' \
        "$@"
}

_koopa_install_geos() {
    _koopa_install_app \
        --name='geos' \
        "$@"
}

_koopa_install_gettext() {
    _koopa_install_app \
        --name='gettext' \
        "$@"
}

_koopa_install_gffutils() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='gffutils' \
        "$@"
}

_koopa_install_gget() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='gget' \
        "$@"
}

_koopa_install_gh() {
    _koopa_install_app \
        --name='gh' \
        "$@"
}

_koopa_install_ghostscript() {
    _koopa_install_app \
        --name='ghostscript' \
        "$@"
}

_koopa_install_git_filter_repo() {
    _koopa_install_app \
        --installer='python-package' \
        --name='git-filter-repo' \
        "$@"
}

_koopa_install_git_lfs() {
    _koopa_install_app \
        --name='git-lfs' \
        "$@"
}

_koopa_install_git() {
    _koopa_install_app \
        --name='git' \
        "$@"
}

_koopa_install_gitui() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='gitui' \
        "$@"
}

_koopa_install_glances() {
    _koopa_install_app \
        --installer='python-package' \
        --name='glances' \
        -D --egg-name='Glances' \
        "$@"
}

_koopa_install_glib() {
    _koopa_install_app \
        --name='glib' \
        "$@"
}

_koopa_install_gmp() {
    _koopa_install_app \
        --name='gmp' \
        "$@"
}

_koopa_install_gnu_app() {
    local -A dict
    local -a conf_args
    _koopa_assert_is_install_subshell
    dict['compress_ext']='gz'
    dict['jobs']="$(_koopa_cpu_count)"
    dict['mirror']="$(_koopa_gnu_mirror_url)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['parent_name']=''
    dict['pkg_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=()
    while (("$#"))
    do
        case "$1" in
            '--compress-ext='*)
                dict['compress_ext']="${1#*=}"
                shift 1
                ;;
            '--compress-ext')
                dict['compress_ext']="${2:?}"
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
            '--mirror='*)
                dict['mirror']="${1#*=}"
                shift 1
                ;;
            '--mirror')
                dict['mirror']="${2:?}"
                shift 2
                ;;
            '--package-name='*)
                dict['pkg_name']="${1#*=}"
                shift 1
                ;;
            '--package-name')
                dict['pkg_name']="${2:?}"
                shift 2
                ;;
            '--parent-name='*)
                dict['parent_name']="${1#*=}"
                shift 1
                ;;
            '--parent-name')
                dict['parent_name']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--non-gnu-mirror')
                dict['mirror']='https://download.savannah.nongnu.org/releases'
                shift 1
                ;;
            '-D')
                conf_args+=("${2:?}")
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['parent_name']}" ]] && dict['parent_name']="${dict['name']}"
    [[ -z "${dict['pkg_name']}" ]] && dict['pkg_name']="${dict['name']}"
    _koopa_assert_is_set \
        '--mirror' "${dict['mirror']}" \
        '--name' "${dict['name']}" \
        '--package-name' "${dict['pkg_name']}" \
        '--parent-name' "${dict['parent_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    conf_args+=("--prefix=${dict['prefix']}")
    export FORCE_UNSAFE_CONFIGURE=1
    dict['url']="${dict['mirror']}/${dict['parent_name']}/\
${dict['pkg_name']}-${dict['version']}.tar.${dict['compress_ext']}"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}

_koopa_install_gnupg() {
    _koopa_install_app \
        --name='gnupg' \
        "$@"
}

_koopa_install_gnutls() {
    _koopa_install_app \
        --name='gnutls' \
        "$@"
}

_koopa_install_go_package() {
    local -A app dict
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'go'
    app['go']="$(_koopa_locate_go)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']=''
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
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    _koopa_print_env
    "${app['go']}" install "${dict['url']}"
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

_koopa_install_go() {
    _koopa_install_app \
        --name='go' \
        "$@"
}

_koopa_install_google_cloud_sdk() {
    _koopa_install_app \
        --name='google-cloud-sdk' \
        "$@"
}

_koopa_install_googletest() {
    _koopa_install_app \
        --name='googletest' \
        "$@"
}

_koopa_install_gperf() {
    _koopa_install_app \
        --installer='gnu-app' \
        --name='gperf' \
        "$@"
}

_koopa_install_graphviz() {
    _koopa_install_app \
        --name='graphviz' \
        "$@"
}

_koopa_install_grep() {
    _koopa_install_app \
        --name='grep' \
        "$@"
}

_koopa_install_grex() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='grex' \
        "$@"
}

_koopa_install_groff() {
    _koopa_install_app \
        --name='groff' \
        "$@"
}

_koopa_install_gseapy() {
    _koopa_install_app \
        --name='gseapy' \
        "$@"
}

_koopa_install_gsl() {
    _koopa_install_app \
        --name='gsl' \
        "$@"
}

_koopa_install_gtop() {
    _koopa_install_app \
        --installer='node-package' \
        --name='gtop' \
        "$@"
}

_koopa_install_gum() {
    _koopa_install_app \
        --name='gum' \
        "$@"
}

_koopa_install_gzip() {
    _koopa_install_app \
        --name='gzip' \
        "$@"
}

_koopa_install_hadolint() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='hadolint' \
        "$@"
}

_koopa_install_harfbuzz() {
    _koopa_install_app \
        --name='harfbuzz' \
        "$@"
}

_koopa_install_haskell_cabal() {
    _koopa_install_app \
        --name='haskell-cabal' \
        "$@"
}

_koopa_install_haskell_ghcup() {
    _koopa_install_app \
        --name='haskell-ghcup' \
        "$@"
}

_koopa_install_haskell_package() {
    local -A app dict
    local -a build_deps conf_args deps extra_pkgs install_args
    local dep
    _koopa_assert_is_install_subshell
    build_deps=('git' 'pkg-config')
    _koopa_activate_app --build-only "${build_deps[@]}"
    app['cabal']="$(_koopa_locate_cabal)"
    app['ghcup']="$(_koopa_locate_ghcup)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cabal_dir']="$(_koopa_init_dir 'cabal')"
    dict['ghc_version']='9.4.7'
    dict['ghcup_prefix']="$(_koopa_init_dir 'ghcup')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cabal_store_dir']="$(\
        _koopa_init_dir "${dict['prefix']}/libexec/cabal/store" \
    )"
    deps=()
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--ghc-version='*)
                dict['ghc_version']="${1#*=}"
                shift 1
                ;;
            '--ghc-version')
                dict['ghc_version']="${2:?}"
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
        '--ghc-version' "${dict['ghc_version']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['ghc_prefix']="$(_koopa_init_dir "ghc-${dict['ghc_version']}")"
    export CABAL_DIR="${dict['cabal_dir']}"
    export GHCUP_INSTALL_BASE_PREFIX="${dict['ghcup_prefix']}"
    _koopa_print_env
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    _koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    dict['bin_prefix']="$(_koopa_init_dir "${dict['prefix']}/bin")"
    _koopa_add_to_path_start \
        "${dict['ghc_prefix']}/bin" \
        "${dict['bin_prefix']}"
    "${app['cabal']}" update
    dict['cabal_config_file']="${dict['cabal_dir']}/config"
    _koopa_assert_is_file "${dict['cabal_config_file']}"
    conf_args+=("store-dir: ${dict['cabal_store_dir']}")
    if _koopa_is_array_non_empty "${deps[@]:-}"
    then
        for dep in "${deps[@]}"
        do
            local -A dict2
            dict2['prefix']="$(_koopa_app_prefix "$dep")"
            _koopa_assert_is_dir \
                "${dict2['prefix']}" \
                "${dict2['prefix']}/include" \
                "${dict2['prefix']}/lib"
            conf_args+=(
                "extra-include-dirs: ${dict2['prefix']}/include"
                "extra-lib-dirs: ${dict2['prefix']}/lib"
            )
        done
    fi
    dict['cabal_config_string']="$(_koopa_print "${conf_args[@]}")"
    _koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    install_args+=(
        '--install-method=copy'
        "--installdir=${dict['prefix']}/bin"
        "--jobs=${dict['jobs']}"
        '--verbose'
        "${dict['name']}-${dict['version']}"
    )
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    "${app['cabal']}" install "${install_args[@]}"
    return 0
}

_koopa_install_haskell_stack() {
    _koopa_install_app \
        --name='haskell-stack' \
        "$@"
}

_koopa_install_hdf5() {
    _koopa_install_app \
        --name='hdf5' \
        "$@"
}

_koopa_install_hexyl() {
    _koopa_install_app \
        --installer='rust-package' \
        --name='hexyl' \
        "$@"
}

_koopa_install_hisat2() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='hisat2' \
        "$@"
}

_koopa_install_htop() {
    _koopa_install_app \
        --name='htop' \
        "$@"
}

_koopa_install_htseq() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='htseq' \
        "$@"
}

_koopa_install_htslib() {
    _koopa_install_app \
        --name='htslib' \
        "$@"
}

_koopa_install_httpie() {
    _koopa_install_app \
        --installer='python-package' \
        --name='httpie' \
        "$@"
}

_koopa_install_httpx() {
    _koopa_install_app \
        --installer='python-package' \
        --name='httpx' \
        -D --pip-name='httpx[cli]' \
        "$@"
}

_koopa_install_huggingface_hub() {
    _koopa_install_app \
        --installer='python-package' \
        --name='huggingface-hub' \
        -D --egg-name='huggingface_hub' \
        -D --pip-name='huggingface_hub[cli]' \
        "$@"
}

_koopa_install_hugo() {
    _koopa_install_app \
        --name='hugo' \
        "$@"
}

_koopa_install_hyperfine() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='hyperfine' \
        "$@"
}

_koopa_install_icu4c() {
    _koopa_install_app \
        --name='icu4c' \
        "$@"
}

_koopa_install_illumina_ica_cli() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='illumina-ica-cli' \
        "$@"
}

_koopa_install_imagemagick() {
    _koopa_install_app \
        --name='imagemagick' \
        "$@"
}

_koopa_install_ipython() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ipython' \
        "$@"
}

_koopa_install_isl() {
    _koopa_install_app \
        --name='isl' \
        "$@"
}

_koopa_install_isort() {
    _koopa_install_app \
        --installer='python-package' \
        --name='isort' \
        "$@"
}

_koopa_install_jemalloc() {
    _koopa_install_app \
        --name='jemalloc' \
        "$@"
}

_koopa_install_jfrog_cli() {
    _koopa_install_app \
        --name='jfrog-cli' \
        "$@"
}

_koopa_install_jless() {
    _koopa_install_app \
        --name='jless' \
        "$@"
}

_koopa_install_jpeg() {
    _koopa_install_app \
        --name='jpeg' \
        "$@"
}

_koopa_install_jq() {
    _koopa_install_app \
        --name='jq' \
        "$@"
}

_koopa_install_julia() {
    _koopa_install_app \
        --name='julia' \
        "$@"
}

_koopa_install_jupyterlab() {
    _koopa_install_app \
        --installer='python-package' \
        --name='jupyterlab' \
        "$@"
}

_koopa_install_k9s() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='k9s' \
        "$@"
}

_koopa_install_kallisto() {
    _koopa_install_app \
        --name='kallisto' \
        "$@"
}

_koopa_install_koopa() {
    local -A bool dict
    bool['add_to_user_profile']=1
    bool['bootstrap']=0
    bool['interactive']=1
    bool['shared']=0
    bool['verbose']=0
    dict['config_prefix']="$(_koopa_config_prefix)"
    dict['prefix']=''
    dict['source_prefix']="$(_koopa_koopa_prefix)"
    dict['user_profile']="$(_koopa_find_user_profile)"
    dict['xdg_data_home']="$(_koopa_xdg_data_home)"
    dict['_koopa_prefix_system']='/opt/koopa'
    dict['_koopa_prefix_user']="${dict['xdg_data_home']}/koopa"
    _koopa_is_admin && bool['shared']=1
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
            '--add-to-user-profile')
                bool['add_to_user_profile']=1
                shift 1
                ;;
            '--bootstrap')
                bool['bootstrap']=1
                shift 1
                ;;
            '--no-add-to-user-profile')
                bool['add_to_user_profile']=0
                shift 1
                ;;
            '--interactive')
                bool['interactive']=1
                shift 1
                ;;
            '--non-interactive')
                bool['interactive']=0
                shift 1
                ;;
            '--shared')
                bool['shared']=1
                shift 1
                ;;
            '--no-shared')
                bool['shared']=0
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
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        set -x
        _koopa_print_env
    fi
    if [[ -d "${KOOPA_BOOTSTRAP_PREFIX:-}" ]]
    then
        bool['bootstrap']=1
        _koopa_add_to_path_start "${KOOPA_BOOTSTRAP_PREFIX}/bin"
    fi
    _koopa_assert_is_installed \
        'cp' 'curl' 'cut' 'find' 'git' 'grep' 'mkdir' 'mktemp' 'mv' 'perl' \
        'python3' 'readlink' 'rm' 'sed' 'tar' 'tr' 'unzip'
    if [[ "${bool['interactive']}" -eq 1 ]]
    then
        if _koopa_is_admin && [[ -z "${dict['prefix']}" ]]
        then
            bool['shared']="$( \
                _koopa_read_yn \
                    'Install for all users' \
                    "${bool['shared']}" \
            )"
        fi
        if [[ -z "${dict['prefix']}" ]]
        then
            if [[ "${bool['shared']}" -eq 1 ]]
            then
                dict['prefix']="${dict['_koopa_prefix_system']}"
            else
                dict['prefix']="${dict['_koopa_prefix_user']}"
            fi
        fi
        dict['prefix']="$( \
            _koopa_read \
                'Install prefix' \
                "${dict['prefix']}" \
        )"
        if _koopa_str_detect_regex \
            --string="${dict['prefix']}" \
            --pattern="^${HOME:?}"
        then
            bool['shared']=0
        fi
        if ! _koopa_is_defined_in_user_profile && \
            [[ ! -L "${dict['user_profile']}" ]]
        then
            _koopa_alert_note 'Koopa activation missing in user profile.'
            bool['add_to_user_profile']="$( \
                _koopa_read_yn \
                    "Modify '${dict['user_profile']}'" \
                    "${bool['add_to_user_profile']}" \
            )"
        fi
    else
        if [[ -z "${dict['prefix']}" ]]
        then
            if [[ "${bool['shared']}" -eq 1 ]]
            then
                dict['prefix']="${dict['_koopa_prefix_system']}"
            else
                dict['prefix']="${dict['_koopa_prefix_user']}"
            fi
        fi
    fi
    _koopa_assert_is_not_dir "${dict['prefix']}"
    _koopa_rm "${dict['config_prefix']}"
    if [[ "${bool['shared']}" -eq 1 ]]
    then
        _koopa_alert_info 'Shared installation detected.'
        _koopa_alert_note 'Admin (sudo) permissions are required.'
        _koopa_assert_is_admin
        dict['user_id']="$(_koopa_user_id)"
        dict['group_id']="$(_koopa_group_id)"
        _koopa_cp --sudo "${dict['source_prefix']}" "${dict['prefix']}"
        _koopa_chown \
            --dereference \
            --recursive \
            --sudo \
            "${dict['user_id']}:${dict['group_id']}" \
            "${dict['prefix']}"
        _koopa_add_make_prefix_link "${dict['prefix']}"
    else
        _koopa_cp "${dict['source_prefix']}" "${dict['prefix']}"
    fi
    export KOOPA_PREFIX="${dict['prefix']}"
    if [[ "${bool['shared']}" -eq 1 ]] && _koopa_is_linux
    then
        _koopa_linux_update_profile_d
    fi
    if [[ "${bool['add_to_user_profile']}" -eq 1 ]]
    then
        _koopa_add_to_user_profile
    fi
    _koopa_zsh_compaudit_set_permissions
    _koopa_add_config_link "${dict['prefix']}/activate" 'activate'
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        dict['python_version']="$(_koopa_python_major_minor_version)"
        _koopa_cli_install --bootstrap \
            'bash' \
            'coreutils' \
            "python${dict['python_version']}"
    fi
    return 0
}

_koopa_install_krb5() {
    _koopa_install_app \
        --name='krb5' \
        "$@"
}

_koopa_install_ksh93() {
    _koopa_install_app \
        --name='ksh93' \
        "$@"
    return 0
}

_koopa_install_lame() {
    _koopa_install_app \
        --name='lame' \
        "$@"
}

_koopa_install_lapack() {
    _koopa_install_app \
        --name='lapack' \
        "$@"
}

_koopa_install_latch() {
    _koopa_install_app \
        --installer='python-package' \
        --name='latch' \
        -D --python-version='3.12' \
        "$@"
}

_koopa_install_ldc() {
    _koopa_install_app \
        --name='ldc' \
        "$@"
}

_koopa_install_ldns() {
    _koopa_install_app \
        --name='ldns' \
        "$@"
}

_koopa_install_less() {
    _koopa_install_app \
        --name='less' \
        "$@"
}

_koopa_install_lesspipe() {
    _koopa_install_app \
        --name='lesspipe' \
        "$@"
}

_koopa_install_libaec() {
    _koopa_install_app \
        --name='libaec' \
        "$@"
}

_koopa_install_libarchive() {
    _koopa_install_app \
        --name='libarchive' \
        "$@"
}

_koopa_install_libassuan() {
    _koopa_install_app \
        --name='libassuan' \
        "$@"
}

_koopa_install_libcbor() {
    _koopa_install_app \
        --name='libcbor' \
        "$@"
}

_koopa_install_libconfig() {
    _koopa_install_app \
        --name='libconfig' \
        "$@"
}

_koopa_install_libde265() {
    _koopa_install_app \
        --name='libde265' \
        "$@"
}

_koopa_install_libdeflate() {
    _koopa_install_app \
        --name='libdeflate' \
        "$@"
}

_koopa_install_libedit() {
    _koopa_install_app \
        --name='libedit' \
        "$@"
}

_koopa_install_libev() {
    _koopa_install_app \
        --name='libev' \
        "$@"
}

_koopa_install_libevent() {
    _koopa_install_app \
        --name='libevent' \
        "$@"
}

_koopa_install_libffi() {
    _koopa_install_app \
        --name='libffi' \
        "$@"
}

_koopa_install_libfido2() {
    _koopa_install_app \
        --name='libfido2' \
        "$@"
}

_koopa_install_libgcrypt() {
    _koopa_install_app \
        --name='libgcrypt' \
        "$@"
}

_koopa_install_libgeotiff() {
    _koopa_install_app \
        --name='libgeotiff' \
        "$@"
}

_koopa_install_libgit2() {
    _koopa_install_app \
        --name='libgit2' \
        "$@"
}

_koopa_install_libgpg_error() {
    _koopa_install_app \
        --name='libgpg-error' \
        "$@"
}

_koopa_install_libheif() {
    _koopa_install_app \
        --name='libheif' \
        "$@"
}

_koopa_install_libiconv() {
    _koopa_install_app \
        --name='libiconv' \
        "$@"
}

_koopa_install_libidn() {
    _koopa_install_app \
        --name='libidn' \
        "$@"
}

_koopa_install_libjpeg_turbo() {
    _koopa_install_app \
        --name='libjpeg-turbo' \
        "$@"
}

_koopa_install_libksba() {
    _koopa_install_app \
        --name='libksba' \
        "$@"
}

_koopa_install_liblinear() {
    _koopa_install_app \
        --name='liblinear' \
        "$@"
}

_koopa_install_libluv() {
    _koopa_install_app \
        --name='libluv' \
        "$@"
}

_koopa_install_libpcap() {
    _koopa_install_app \
        --name='libpcap' \
        "$@"
}

_koopa_install_libpipeline() {
    _koopa_install_app \
        --name='libpipeline' \
        "$@"
}

_koopa_install_libpng() {
    _koopa_install_app \
        --name='libpng' \
        "$@"
}

_koopa_install_libsolv() {
    _koopa_install_app \
        --name='libsolv' \
        "$@"
}

_koopa_install_libssh2() {
    _koopa_install_app \
        --name='libssh2' \
        "$@"
}

_koopa_install_libtasn1() {
    _koopa_install_app \
        --name='libtasn1' \
        "$@"
}

_koopa_install_libtermkey() {
    _koopa_install_app \
        --name='libtermkey' \
        "$@"
}

_koopa_install_libtiff() {
    _koopa_install_app \
        --name='libtiff' \
        "$@"
}

_koopa_install_libtool() {
    _koopa_install_app \
        --name='libtool' \
        "$@"
}

_koopa_install_libunistring() {
    _koopa_install_app \
        --name='libunistring' \
        "$@"
}

_koopa_install_libuv() {
    _koopa_install_app \
        --name='libuv' \
        "$@"
}

_koopa_install_libvterm() {
    _koopa_install_app \
        --name='libvterm' \
        "$@"
}

_koopa_install_libxcrypt() {
    _koopa_install_app \
        --name='libxcrypt' \
        "$@"
}

_koopa_install_libxml2() {
    _koopa_install_app \
        --name='libxml2' \
        "$@"
}

_koopa_install_libxslt() {
    _koopa_install_app \
        --name='libxslt' \
        "$@"
}

_koopa_install_libyaml() {
    _koopa_install_app \
        --name='libyaml' \
        "$@"
}

_koopa_install_libzip() {
    _koopa_install_app \
        --name='libzip' \
        "$@"
}

_koopa_install_llvm() {
    _koopa_install_app \
        --name='llvm' \
        "$@"
}

_koopa_install_lsd() {
    _koopa_install_app \
        --name='lsd' \
        "$@"
}

_koopa_install_lua() {
    _koopa_install_app \
        --name='lua' \
        "$@"
}

_koopa_install_luajit() {
    _koopa_install_app \
        --name='luajit' \
        "$@"
}

_koopa_install_luarocks() {
    _koopa_install_app \
        --name='luarocks' \
        "$@"
}

_koopa_install_luigi() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='luigi' \
        "$@"
}

_koopa_install_lz4() {
    _koopa_install_app \
        --name='lz4' \
        "$@"
}

_koopa_install_lzip() {
    _koopa_install_app \
        --name='lzip' \
        "$@"
}

_koopa_install_lzo() {
    _koopa_install_app \
        --name='lzo' \
        "$@"
}

_koopa_install_m4() {
    _koopa_install_app \
        --installer='gnu-app' \
        --name='m4' \
        "$@"
}

_koopa_install_make() {
    _koopa_install_app \
        --name='make' \
        "$@"
}

_koopa_install_mamba() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mamba' \
        "$@"
}

_koopa_install_man_db() {
    _koopa_install_app \
        --name='man-db' \
        "$@"
}

_koopa_install_marimo() {
    _koopa_install_app \
        --installer='python-package' \
        --name='marimo' \
        "$@"
}

_koopa_install_markdownlint_cli() {
    _koopa_install_app \
        --installer='node-package' \
        --name='markdownlint-cli' \
        "$@"
}

_koopa_install_mcfly() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mcfly' \
        "$@"
}

_koopa_install_mdcat() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mdcat' \
        "$@"
}

_koopa_install_meson() {
    _koopa_install_app \
        --installer='python-package' \
        --name='meson' \
        "$@"
}

_koopa_install_miller() {
    _koopa_install_app \
        --name='miller' \
        "$@"
}

_koopa_install_mimalloc() {
    _koopa_install_app \
        --name='mimalloc' \
        "$@"
}

_koopa_install_minimap2() {
    _koopa_install_app \
        --name='minimap2' \
        "$@"
}

_koopa_install_misopy() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='misopy' \
        "$@"
}

_koopa_install_mold() {
    _koopa_install_app \
        --name='mold' \
        "$@"
}

_koopa_install_mosaicml_cli() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mosaicml-cli' \
        "$@"
}

_koopa_install_mpc() {
    _koopa_install_app \
        --name='mpc' \
        "$@"
}

_koopa_install_mpdecimal() {
    _koopa_install_app \
        --name='mpdecimal' \
        "$@"
}

_koopa_install_mpfr() {
    _koopa_install_app \
        --name='mpfr' \
        "$@"
}

_koopa_install_msgpack() {
    _koopa_install_app \
        --name='msgpack' \
        "$@"
}

_koopa_install_multiqc() {
    _koopa_install_app \
        --installer='python-package' \
        --name='multiqc' \
        "$@"
}

_koopa_install_mutagen() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mutagen' \
        -D --extra-package='tqdm' \
        "$@"
}

_koopa_install_mypy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mypy' \
        "$@"
}

_koopa_install_nano() {
    _koopa_install_app \
        --name='nano' \
        "$@"
}

_koopa_install_nanopolish() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='nanopolish' \
        "$@"
}

_koopa_install_ncbi_sra_tools() {
    _koopa_install_app \
        --name='ncbi-sra-tools' \
        "$@"
}

_koopa_install_ncbi_vdb() {
    _koopa_install_app \
        --name='ncbi-vdb' \
        "$@"
}

_koopa_install_ncurses() {
    _koopa_install_app \
        --name='ncurses' \
        "$@"
}

_koopa_install_neofetch() {
    _koopa_install_app \
        --name='neofetch' \
        "$@"
}

_koopa_install_neovim() {
    _koopa_install_app \
        --name='neovim' \
        "$@"
}

_koopa_install_nettle() {
    _koopa_install_app \
        --name='nettle' \
        "$@"
}

_koopa_install_nextflow() {
    _koopa_install_app \
        --name='nextflow' \
        "$@"
}

_koopa_install_nghttp2() {
    _koopa_install_app \
        --name='nghttp2' \
        "$@"
}

_koopa_install_nim() {
    _koopa_install_app \
        --name='nim' \
        "$@"
}

_koopa_install_ninja() {
    _koopa_install_app \
        --name='ninja' \
        "$@"
}

_koopa_install_nlohmann_json() {
    _koopa_install_app \
        --name='nlohmann-json' \
        "$@"
}

_koopa_install_nmap() {
    _koopa_install_app \
        --name='nmap' \
        "$@"
}

_koopa_install_node_package() {
    local -A app dict
    local -a extra_pkgs install_args
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'node'
    app['node']="$(_koopa_locate_node --realpath)"
    app['npm']="$(_koopa_locate_npm)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cache_prefix']="$(_koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
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
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    _koopa_is_root && install_args+=('--unsafe-perm')
    install_args+=(
        "--cache=${dict['cache_prefix']}"
        '--global'
        '--loglevel=silly' # -ddd
        '--no-audit'
        '--no-fund'
        "${dict['name']}@${dict['version']}"
    )
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    _koopa_dl 'npm install args' "${install_args[*]}"
    "${app['npm']}" install "${install_args[@]}" 2>&1
    _koopa_rm "${dict['cache_prefix']}"
    return 0
}

_koopa_install_node() {
    _koopa_install_app \
        --name='node' \
        "$@"
}

_koopa_install_npth() {
    _koopa_install_app \
        --name='npth' \
        "$@"
}

_koopa_install_nushell() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='nushell' \
        "$@"
}

_koopa_install_oniguruma() {
    _koopa_install_app \
        --name='oniguruma' \
        "$@"
}

_koopa_install_ont_dorado() {
    _koopa_install_app \
        --name='ont-dorado' \
        "$@"
}

_koopa_install_ont_vbz_compression() {
    _koopa_install_app \
        --name='ont-vbz-compression' \
        "$@"
}

_koopa_install_openblas() {
    _koopa_install_app \
        --name='openblas' \
        "$@"
}

_koopa_install_openjpeg() {
    _koopa_install_app \
        --name='openjpeg' \
        "$@"
}

_koopa_install_openldap() {
    _koopa_install_app \
        --name='openldap' \
        "$@"
}

_koopa_install_openssh() {
    _koopa_install_app \
        --name='openssh' \
        "$@"
}

_koopa_install_openssl() {
    _koopa_install_app \
        --name='openssl' \
        "$@"
}

_koopa_install_openssl3() {
    _koopa_install_app \
        --installer='openssl' \
        --name='openssl3' \
        "$@"
}

_koopa_install_p7zip() {
    _koopa_install_app \
        --name='p7zip' \
        "$@"
}

_koopa_install_pandoc() {
    _koopa_install_app \
        --name='pandoc' \
        "$@"
}

_koopa_install_parallel() {
    _koopa_install_app \
        --name='parallel' \
        "$@"
}

_koopa_install_password_store() {
    _koopa_install_app \
        --name='password-store' \
        "$@"
}

_koopa_install_patch() {
    _koopa_install_app \
        --name='patch' \
        "$@"
}

_koopa_install_pbzip2() {
    _koopa_install_app \
        --name='pbzip2' \
        "$@"
}

_koopa_install_pcre() {
    _koopa_install_app \
        --name='pcre' \
        "$@"
}

_koopa_install_pcre2() {
    _koopa_install_app \
        --name='pcre2' \
        "$@"
}

_koopa_install_perl_package() {
    local -A app dict
    local -a bin_files deps
    local bin_file
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'perl'
    _koopa_activate_ca_certificates
    app['bash']="$(_koopa_locate_bash)"
    app['bzip2']="$(_koopa_locate_bzip2)"
    app['cpan']="$(_koopa_locate_cpan)"
    app['gpg']="$(_koopa_locate_gpg)"
    app['gzip']="$(_koopa_locate_gzip)"
    app['less']="$(_koopa_locate_less)"
    app['make']="$(_koopa_locate_make)"
    app['patch']="$(_koopa_locate_patch)"
    app['perl']="$(_koopa_locate_perl)"
    app['tar']="$(_koopa_locate_tar)"
    app['unzip']="$(_koopa_locate_unzip)"
    app['wget']="$(_koopa_locate_wget)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cpan_path']=''
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_cpan']="$(_koopa_init_dir 'cpan')"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    deps=()
    while (("$#"))
    do
        case "$1" in
            '--cpan-path='*)
                dict['cpan_path']="${1#*=}"
                shift 1
                ;;
            '--cpan-path')
                dict['cpan_path']="${2:?}"
                shift 2
                ;;
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
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
        '--cpan-path' "${dict['cpan_path']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['cpan_config_file']="${dict['tmp_cpan']}/CPAN/MyConfig.pm"
    read -r -d '' "dict[cpan_config_string]" << END || true
\$CPAN::Config = {
  'allow_installing_module_downgrades' => q[no],
  'allow_installing_outdated_dists' => q[yes],
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[${dict['tmp_cpan']}/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[${app['bzip2']}],
  'cache_metadata' => q[0],
  'check_sigs' => q[0],
  'cleanup_after_install' => q[1],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[${dict['tmp_cpan']}],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[${app['gpg']}],
  'gzip' => q[${app['gzip']}],
  'halt_on_failure' => q[1],
  'histfile' => q[${dict['tmp_cpan']}/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[1],
  'keep_source_where' => q[${dict['tmp_cpan']}/sources],
  'load_module_verbosity' => q[v],
  'make' => q[${app['make']}],
  'make_arg' => q[-j${dict['jobs']}],
  'make_install_arg' => q[-j${dict['jobs']}],
  'make_install_make_command' => q[${app['make']}],
  'makepl_arg' => q[INSTALL_BASE=${dict['prefix']}],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[./Build],
  'mbuildpl_arg' => q[--install_base ${dict['prefix']}],
  'no_proxy' => q[],
  'pager' => q[${app['less']} -R],
  'patch' => q[${app['patch']}],
  'perl5lib_verbosity' => q[v],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[${dict['tmp_cpan']}/prefs],
  'prerequisites_policy' => q[follow],
  'pushy_https' => q[1],
  'recommends_policy' => q[1],
  'scan_cache' => q[never],
  'shell' => q[${app['bash']}],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'suggests_policy' => q[0],
  'tar' => q[${app['tar']}],
  'tar_verbosity' => q[vv],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[${app['unzip']}],
  'urllist' => [q[http://www.cpan.org/]],
  'use_prompt_default' => q[1],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[${app['wget']}],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
END
    _koopa_write_string \
        --file="${dict['cpan_config_file']}" \
        --string="${dict['cpan_config_string']}"
    dict['perl_ver']="$(_koopa_get_version "${app['perl']}")"
    dict['perl_maj_ver']="$(_koopa_major_version "${dict['perl_ver']}")"
    dict['lib_prefix']="${dict['prefix']}/lib/perl${dict['perl_maj_ver']}"
    export PERL5LIB="${dict['lib_prefix']}"
    _koopa_print_env
    if _koopa_is_array_non_empty "${deps[@]:-}"
    then
        "${app['cpan']}" \
            -j "${dict['cpan_config_file']}" \
            "${deps[@]}"
    fi
    "${app['cpan']}" \
        -j "${dict['cpan_config_file']}" \
        "${dict['cpan_path']}-${dict['version']}.tar.gz"
    _koopa_assert_is_dir "${dict['lib_prefix']}"
    dict['lib_string']="use lib \"${dict['lib_prefix']}\";"
    readarray -t bin_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}/bin" \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${bin_files[@]:-}"
    _koopa_assert_is_file "${bin_files[@]}"
    for bin_file in "${bin_files[@]}"
    do
        _koopa_insert_at_line_number \
            --file="$bin_file" \
            --line-number=2 \
            --string="${dict['lib_string']}"
    done
    return 0
}

_koopa_install_perl() {
    _koopa_install_app \
        --name='perl' \
        "$@"
}

_koopa_install_picard() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='picard' \
        "$@"
}

_koopa_install_pigz() {
    _koopa_install_app \
        --name='pigz' \
        "$@"
}

_koopa_install_pinentry() {
    _koopa_install_app \
        --name='pinentry' \
        "$@"
}

_koopa_install_pipx() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pipx' \
        "$@"
}

_koopa_install_pixman() {
    _koopa_install_app \
        --name='pixman' \
        "$@"
}

_koopa_install_pkg_config() {
    _koopa_install_app \
        --name='pkg-config' \
        "$@"
}

_koopa_install_pkgconf() {
    _koopa_install_app \
        --name='pkgconf' \
        "$@"
}

_koopa_install_poetry() {
    _koopa_install_app \
        --installer='python-package' \
        --name='poetry' \
        "$@"
}

_koopa_install_postgresql() {
    _koopa_install_app \
        --name='postgresql' \
        "$@"
}

_koopa_install_prettier() {
    _koopa_install_app \
        --name='prettier' \
        "$@"
}

_koopa_install_private_ont_guppy() {
    _koopa_install_app \
        --name='ont-guppy' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://nanoporetech.com/support/nanopore-sequencing-data-analysis'."
    return 0
}

_koopa_install_procs() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='procs' \
        "$@"
}

_koopa_install_proj() {
    _koopa_install_app \
        --name='proj' \
        "$@"
}

_koopa_install_pup() {
    _koopa_install_app \
        --name='pup' \
        "$@"
}

_koopa_install_py_spy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='py-spy' \
        "$@"
}

_koopa_install_pybind11() {
    _koopa_install_app \
        --name='pybind11' \
        "$@"
}

_koopa_install_pycodestyle() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pycodestyle' \
        "$@"
}

_koopa_install_pyenv() {
    _koopa_install_app \
        --name='pyenv' \
        "$@"
}

_koopa_install_pyflakes() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyflakes' \
        "$@"
}

_koopa_install_pygments() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pygments' \
        "$@"
}

_koopa_install_pylint() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pylint' \
        "$@"
}

_koopa_install_pymol() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='pymol' \
        "$@"
}

_koopa_install_pyrefly() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyrefly' \
        "$@"
}

_koopa_install_pyright() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyright' \
        "$@"
}

_koopa_install_pytaglib() {
    _koopa_install_app \
        --name='pytaglib' \
        "$@"
}

_koopa_install_pytest() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pytest' \
        -D --extra-package='pytest-cov' \
        "$@"
}

_koopa_install_python_package() {
    local -A app bool dict
    local -a bin_names extra_pkgs man1_names venv_args
    local bin_name man1_name
    _koopa_assert_is_install_subshell
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['binary']=1
    bool['egg_name']=0
    dict['egg_name']=''
    dict['locate_python']='_koopa_locate_python'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['pip_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--egg-name='*)
                dict['egg_name']="${1#*=}"
                shift 1
                ;;
            '--egg-name')
                dict['egg_name']="${2:?}"
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--pip-name='*)
                dict['pip_name']="${1#*=}"
                shift 1
                ;;
            '--pip-name')
                dict['pip_name']="${2:?}"
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
            '--python-version='*)
                dict['py_maj_ver']="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict['py_maj_ver']="${2:?}"
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
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict['egg_name']}" ]]
    then
        bool['egg_name']=1
    else
        dict['egg_name']="${dict['name']}"
    fi
    if [[ -z "${dict['pip_name']}" ]]
    then
        dict['pip_name']="${dict['egg_name']}"
    fi
    if [[ "${bool['egg_name']}" -eq 0 ]]
    then
        dict['egg_name']="$(_koopa_snake_case "${dict['egg_name']}")"
    fi
    _koopa_assert_is_set \
        '--egg-name' "${dict['egg_name']}" \
        '--name' "${dict['name']}" \
        '--pip-name' "${dict['pip_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    if [[ -n "${dict['py_maj_ver']}" ]]
    then
        dict['py_maj_ver_2']="$( \
            _koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['py_maj_ver']}" \
        )"
        dict['locate_python']="_koopa_locate_python${dict['py_maj_ver_2']}"
    fi
    _koopa_assert_is_function "${dict['locate_python']}"
    app['python']="$("${dict['locate_python']}" --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_add_to_path_start "$(_koopa_parent_dir "${app['python']}")"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['py_version']="$(_koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        _koopa_major_minor_version "${dict['py_version']}" \
    )"
    venv_args=(
        "--prefix=${dict['libexec']}"
        "--python=${app['python']}"
    )
    if [[ "${bool['binary']}" -eq 0 ]]
    then
        venv_args+=('--no-binary')
    fi
    venv_args+=("${dict['pip_name']}==${dict['version']}")
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        venv_args+=("${extra_pkgs[@]}")
    fi
    _koopa_print_env
    _koopa_python_create_venv "${venv_args[@]}"
    dict['record_file']="${dict['libexec']}/lib/\
python${dict['py_maj_min_ver']}/site-packages/\
${dict['egg_name']}-${dict['version']}.dist-info/RECORD"
    _koopa_assert_is_file "${dict['record_file']}"
    readarray -t bin_names <<< "$( \
        _koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./bin/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '5' \
    )"
    readarray -t man1_names <<< "$( \
        _koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./share/man/man1/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '7' \
    )"
    if _koopa_is_array_empty "${bin_names[@]:-}"
    then
        _koopa_stop "Failed to parse '${dict['record_file']}' for bin."
    fi
    for bin_name in "${bin_names[@]}"
    do
        [[ -n "$bin_name" ]] || continue
        [[ -f "${dict['libexec']}/bin/${bin_name}" ]] || continue
        _koopa_ln \
            "${dict['libexec']}/bin/${bin_name}" \
            "${dict['prefix']}/bin/${bin_name}"
    done
    if _koopa_is_array_non_empty "${man1_names[@]:-}"
    then
        for man1_name in "${man1_names[@]}"
        do
            [[ -n "$man1_name" ]] || continue
            [[ -f "${dict['libexec']}/share/man/man1/${man1_name}" ]] \
                || continue
            _koopa_ln \
                "${dict['libexec']}/share/man/man1/${man1_name}" \
                "${dict['prefix']}/share/man/man1/${man1_name}"
        done
    fi
    return 0
}

_koopa_install_python310() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.10' \
        "$@"
}

_koopa_install_python311() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        "$@"
}

_koopa_install_python312() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.12' \
        "$@"
}

_koopa_install_python313() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.13' \
        "$@"
}

_koopa_install_python314() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.14' \
        "$@"
}

_koopa_install_quarto() {
    _koopa_install_app \
        --name='quarto' \
        "$@"
}

_koopa_install_r_devel() {
    _koopa_install_app \
        --name='r-devel' \
        "$@"
}

_koopa_install_r() {
    _koopa_install_app \
        --name='r' \
        "$@"
}

_koopa_install_radian() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='radian' \
        "$@"
}

_koopa_install_ranger_fm() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ranger-fm' \
        "$@"
}

_koopa_install_rbenv() {
    _koopa_install_app \
        --name='rbenv' \
        "$@"
}

_koopa_install_rclone() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='rclone' \
        "$@"
}

_koopa_install_readline() {
    _koopa_install_app \
        --name='readline' \
        "$@"
}

_koopa_install_rename() {
    _koopa_install_app \
        --name='rename' \
        "$@"
}

_koopa_install_reproc() {
    _koopa_install_app \
        --name='reproc' \
        "$@"
}

_koopa_install_ripgrep_all() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ripgrep-all' \
        "$@"
}

_koopa_install_ripgrep() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ripgrep' \
        "$@"
}

_koopa_install_rmate() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='rmate' \
        "$@"
}

_koopa_install_rmats() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='rmats' \
        "$@"
}

_koopa_install_ronn_ng() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='ronn-ng' \
        "$@"
}

_koopa_install_rsem() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='rsem' \
        "$@"
}

_koopa_install_rsync() {
    _koopa_install_app \
        --name='rsync' \
        "$@"
}

_koopa_install_ruby_package() {
    local -A app dict
    _koopa_assert_is_install_subshell
    app['bundle']="$(_koopa_locate_bundle)"
    app['ruby']="$(_koopa_locate_ruby --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gemfile']='Gemfile'
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    read -r -d '' "dict[gemfile_string]" << END || true
source "https://rubygems.org"
gem "${dict['name']}", "${dict['version']}"
END
    dict['libexec']="${dict['prefix']}/libexec"
    _koopa_mkdir "${dict['libexec']}"
    _koopa_print_env
    (
        _koopa_cd "${dict['libexec']}"
        _koopa_write_string \
            --file="${dict['gemfile']}" \
            --string="${dict['gemfile_string']}"
        "${app['bundle']}" install \
            --gemfile="${dict['gemfile']}" \
            --jobs="${dict['jobs']}" \
            --retry=3 \
            --standalone
        "${app['bundle']}" binstubs \
            "${dict['name']}" \
            --path="${dict['prefix']}/bin" \
            --shebang="${app['ruby']}" \
            --standalone
    )
    return 0
}

_koopa_install_ruby() {
    _koopa_install_app \
        --name='ruby' \
        "$@"
}

_koopa_install_ruff_lsp() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ruff-lsp' \
        "$@"
}

_koopa_install_ruff() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ruff' \
        "$@"
}

_koopa_install_rust_package() {
    local -A app bool dict
    local -a build_deps install_args pos
    _koopa_assert_is_install_subshell
    build_deps+=(
        'rust'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    app['cargo']="$(_koopa_locate_cargo)"
    _koopa_assert_is_executable "${app[@]}"
    bool['openssl']=0
    dict['cargo_config_file']="$(_koopa_rust_cargo_config_file)"
    dict['cargo_home']="$(_koopa_init_dir 'cargo')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--features='* | \
            '--git='* | \
            '--tag='*)
                pos+=("${1%%=*}" "${1#*=}")
                shift 1
                ;;
            '--features' | \
            '--git' | \
            '--tag')
                pos+=("$1" "$2")
                shift 2
                ;;
            '--with-openssl')
                bool['openssl']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_dir "${dict['cargo_home']}"
    export CARGO_HOME="${dict['cargo_home']}"
    export CARGO_NET_GIT_FETCH_WITH_CLI='true'
    export RUST_BACKTRACE='full'
    if [[ "${bool['openssl']}" -eq 1 ]]
    then
        _koopa_activate_app 'openssl'
        dict['openssl']="$(_koopa_app_prefix 'openssl')"
        export OPENSSL_DIR="${dict['openssl']}"
    fi
    if [[ -n "${LDFLAGS:-}" ]]
    then
        local -a ldflags rustflags
        local ldflag
        rustflags=()
        IFS=' ' read -r -a ldflags <<< "${LDFLAGS:?}"
        for ldflag in "${ldflags[@]}"
        do
            rustflags+=('-C' "link-arg=${ldflag}")
        done
        export RUSTFLAGS="${rustflags[*]}"
    fi
    if [[ -f "${dict['cargo_config_file']}" ]]
    then
        _koopa_alert "Using cargo config at '${dict['cargo_config_file']}'."
        _koopa_cp --verbose \
            "${dict['cargo_config_file']}" \
            "${CARGO_HOME:?}/config.toml"
    else
        install_args+=(
            '--config' 'net.git-fetch-with-cli=true'
            '--config' 'net.retry=5'
        )
    fi
    install_args+=(
        '--jobs' "${dict['jobs']}"
        '--locked'
        '--root' "${dict['prefix']}"
        '--verbose'
        '--version' "${dict['version']}"
    )
    [[ "$#" -gt 0 ]] && install_args+=("$@")
    install_args+=("${dict['name']}")
    dict['bin_prefix']="$(_koopa_init_dir "${dict['prefix']}/bin")"
    _koopa_add_to_path_start "${dict['bin_prefix']}"
    _koopa_print_env
    _koopa_dl 'cargo install args' "${install_args[*]}"
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}

_koopa_install_rust() {
    _koopa_install_app \
        --name='rust' \
        "$@"
}

_koopa_install_s5cmd() {
    _koopa_install_app \
        --name='s5cmd' \
        "$@"
}

_koopa_install_salmon() {
    _koopa_install_app \
        --name='salmon' \
        "$@"
}

_koopa_install_sambamba() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='sambamba' \
        "$@"
}

_koopa_install_samtools() {
    if _koopa_is_macos && _koopa_is_arm64
    then
        _koopa_install_app \
            --name='samtools' \
            "$@"
    else
        _koopa_install_app \
            --installer='conda-package' \
            --name='samtools' \
            "$@"
    fi
}

_koopa_install_scalene() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scalene' \
        "$@"
}

_koopa_install_scanpy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scanpy' \
        "$@"
}

_koopa_install_scons() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scons' \
        -D --egg-name='SCons' \
        "$@"
}

_koopa_install_screen() {
    _koopa_install_app \
        --name='screen' \
        "$@"
}

_koopa_install_sd() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='sd' \
        "$@"
}

_koopa_install_sed() {
    _koopa_install_app \
        --name='sed' \
        "$@"
}

_koopa_install_seqkit() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='seqkit' \
        "$@"
}

_koopa_install_serf() {
    _koopa_install_app \
        --name='serf' \
        "$@"
}

_koopa_install_shared_apps() {
    local -A app bool dict
    local -a app_names
    local app_name
    _koopa_assert_is_owner
    if _koopa_is_macos && _koopa_is_amd64
    then
        _koopa_stop 'No longer supported for Intel Macs.'
    fi
    bool['all']=0
    bool['aws_bootstrap']=0
    bool['binary']=0
    _koopa_can_install_binary && bool['binary']=1
    bool['builder']=0
    _koopa_can_build_binary && bool['builder']=1
    bool['update']=0
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    while (("$#"))
    do
        case "$1" in
            '--update')
                bool['update']=1
                shift 1
                ;;
            '--all')
                bool['all']=1
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['binary']}" -eq 1 ]] || [[ "${bool['builder']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-missing --allow-system)"
        [[ ! -x "${app['aws']}" ]] && bool['aws_bootstrap']=1
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        _koopa_assert_can_install_binary
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    if [[ "${bool['update']}" -eq 1 ]]
    then
        _koopa_update_koopa
    fi
    if [[ "${bool['aws_bootstrap']}" -eq 1 ]]
    then
        _koopa_install_aws_cli
        if [[ "${bool['builder']}" -eq 1 ]]
        then
            readarray -t app_names <<< "$( \
                _koopa_app_dependencies 'aws-cli' \
            )"
            app_names+=('aws-cli')
            _koopa_push_app_build "${app_names[@]}"
        fi
    fi
    if [[ "${bool['all']}" -eq 1 ]]
    then
        readarray -t app_names <<< "$( \
            _koopa_shared_apps --mode='all' \
        )"
    else
        readarray -t app_names <<< "$( \
            _koopa_shared_apps --mode='default' \
        )"
    fi
    for app_name in "${app_names[@]}"
    do
        local prefix
        prefix="$(_koopa_app_prefix --allow-missing "$app_name")"
        [[ -f "${prefix}/.koopa-install-stdout.log" ]] && continue
        _koopa_cli_install "$app_name"
    done
    return 0
}

_koopa_install_shellcheck() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='shellcheck' \
        "$@"
}

_koopa_install_shunit2() {
    _koopa_install_app \
        --name='shunit2' \
        "$@"
}

_koopa_install_shyaml() {
    _koopa_install_app \
        --installer='python-package' \
        --name='shyaml' \
        "$@"
}

_koopa_install_simdjson() {
    _koopa_install_app \
        --name='simdjson' \
        "$@"
}

_koopa_install_snakefmt() {
    _koopa_install_app \
        --installer='python-package' \
        --name='snakefmt' \
        "$@"
}

_koopa_install_snakemake() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='snakemake' \
        "$@"
}

_koopa_install_sox() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='sox' \
        "$@"
}

_koopa_install_spdlog() {
    _koopa_install_app \
        --name='spdlog' \
        "$@"
}

_koopa_install_sphinx() {
    _koopa_install_app \
        --installer='python-package' \
        --name='sphinx' \
        "$@"
}

_koopa_install_sqlfluff() {
    _koopa_install_app \
        --installer='python-package' \
        --name='sqlfluff' \
        "$@"
}

_koopa_install_sqlite() {
    _koopa_install_app \
        --name='sqlite' \
        "$@"
}

_koopa_install_staden_io_lib() {
    _koopa_install_app \
        --name='staden-io-lib' \
        "$@"
}

_koopa_install_star_fusion() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='star-fusion' \
        "$@"
}

_koopa_install_star() {
    _koopa_install_app \
        --name='star' \
        "$@"
}

_koopa_install_starship() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='starship' \
        "$@"
}

_koopa_install_stow() {
    _koopa_install_app \
        --name='stow' \
        "$@"
}

_koopa_install_streamlit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='streamlit' \
        "$@"
}

_koopa_install_subread() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='subread' \
        "$@"
}

_koopa_install_subversion() {
    _koopa_install_app \
        --name='subversion' \
        "$@"
}

_koopa_install_swig() {
    _koopa_install_app \
        --name='swig' \
        "$@"
}

_koopa_install_system_homebrew_bundle() {
    _koopa_install_app \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

_koopa_install_system_homebrew() {
    _koopa_install_app \
        --name='homebrew' \
        --prefix="$(_koopa_homebrew_prefix)" \
        --system \
        "$@"
}

_koopa_install_system_tex_packages() {
    _koopa_install_app \
        --name='tex-packages' \
        --system \
        "$@"
}

_koopa_install_taglib() {
    _koopa_install_app \
        --name='taglib' \
        "$@"
}

_koopa_install_tar() {
    _koopa_install_app \
        --name='tar' \
        "$@"
}

_koopa_install_tbb() {
    _koopa_install_app \
        --name='tbb' \
        "$@"
}

_koopa_install_tcl_tk() {
    _koopa_install_app \
        --name='tcl-tk' \
        "$@"
}

_koopa_install_tealdeer() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tealdeer' \
        "$@"
}

_koopa_install_temurin() {
    _koopa_install_app \
        --name='temurin' \
        "$@"
}

_koopa_install_termcolor() {
    _koopa_install_app \
        --name='termcolor' \
        "$@"
}

_koopa_install_texinfo() {
    _koopa_install_app \
        --name='texinfo' \
        "$@"
}

_koopa_install_tl_expected() {
    _koopa_install_app \
        --name='tl-expected' \
        "$@"
}

_koopa_install_tmux() {
    _koopa_install_app \
        --name='tmux' \
        "$@"
}

_koopa_install_tokei() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tokei' \
        "$@"
}

_koopa_install_tqdm() {
    _koopa_install_app \
        --installer='python-package' \
        --name='tqdm' \
        "$@"
}

_koopa_install_tree_sitter() {
    _koopa_install_app \
        --name='tree-sitter' \
        "$@"
}

_koopa_install_tree() {
    _koopa_install_app \
        --name='tree' \
        "$@"
}

_koopa_install_tryceratops() {
    _koopa_install_app \
        --installer='python-package' \
        --name='tryceratops' \
        "$@"
}

_koopa_install_tuc() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tuc' \
        "$@"
}

_koopa_install_ty() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ty' \
        "$@"
}

_koopa_install_udunits() {
    _koopa_install_app \
        --name='udunits' \
        "$@"
}

_koopa_install_umis() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='umis' \
        "$@"
}

_koopa_install_unibilium() {
    _koopa_install_app \
        --name='unibilium' \
        "$@"
}

_koopa_install_units() {
    _koopa_install_app \
        --name='units' \
        "$@"
}

_koopa_install_unzip() {
    _koopa_install_app \
        --name='unzip' \
        "$@"
}

_koopa_install_user_bootstrap() {
    _koopa_install_app \
        --name='bootstrap' \
        --user \
        "$@"
}

_koopa_install_user_doom_emacs() {
    _koopa_install_app \
        --name='doom-emacs' \
        --prefix="$(_koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

_koopa_install_user_prelude_emacs() {
    _koopa_install_app \
        --name='prelude-emacs' \
        --prefix="$(_koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

_koopa_install_user_spacemacs() {
    _koopa_install_app \
        --name='spacemacs' \
        --prefix="$(_koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

_koopa_install_user_spacevim() {
    _koopa_install_app \
        --name='spacevim' \
        --prefix="$(_koopa_spacevim_prefix)" \
        --user \
        "$@"
}

_koopa_install_utf8proc() {
    _koopa_install_app \
        --name='utf8proc' \
        "$@"
}

_koopa_install_uv() {
    _koopa_install_app \
        --name='uv' \
        "$@"
}

_koopa_install_vim() {
    _koopa_install_app \
        --name='vim' \
        "$@"
}

_koopa_install_visidata() {
    _koopa_install_app \
        --installer='python-package' \
        --name='visidata' \
        "$@"
}

_koopa_install_vulture() {
    _koopa_install_app \
        --installer='python-package' \
        --name='vulture' \
        "$@"
}

_koopa_install_walk() {
    _koopa_install_app \
        --name='walk' \
        "$@"
}

_koopa_install_wget() {
    _koopa_install_app \
        --name='wget' \
        "$@"
}

_koopa_install_wget2() {
    _koopa_install_app \
        --name='wget2' \
        "$@"
}

_koopa_install_which() {
    _koopa_install_app \
        --name='which' \
        "$@"
}

_koopa_install_woff2() {
    _koopa_install_app \
        --name='woff2' \
        "$@"
}

_koopa_install_xorg_libice() {
    _koopa_install_app \
        --name='xorg-libice' \
        "$@"
}

_koopa_install_xorg_libpthread_stubs() {
    _koopa_install_app \
        --name='xorg-libpthread-stubs' \
        "$@"
}

_koopa_install_xorg_libsm() {
    _koopa_install_app \
        --name='xorg-libsm' \
        "$@"
}

_koopa_install_xorg_libx11() {
    _koopa_install_app \
        --name='xorg-libx11' \
        "$@"
}

_koopa_install_xorg_libxau() {
    _koopa_install_app \
        --name='xorg-libxau' \
        "$@"
}

_koopa_install_xorg_libxcb() {
    _koopa_install_app \
        --name='xorg-libxcb' \
        "$@"
}

_koopa_install_xorg_libxdmcp() {
    _koopa_install_app \
        --name='xorg-libxdmcp' \
        "$@"
}

_koopa_install_xorg_libxext() {
    _koopa_install_app \
        --name='xorg-libxext' \
        "$@"
}

_koopa_install_xorg_libxrandr() {
    _koopa_install_app \
        --name='xorg-libxrandr' \
        "$@"
}

_koopa_install_xorg_libxrender() {
    _koopa_install_app \
        --name='xorg-libxrender' \
        "$@"
}

_koopa_install_xorg_libxt() {
    _koopa_install_app \
        --name='xorg-libxt' \
        "$@"
}

_koopa_install_xorg_xcb_proto() {
    _koopa_install_app \
        --name='xorg-xcb-proto' \
        "$@"
}

_koopa_install_xorg_xorgproto() {
    _koopa_install_app \
        --name='xorg-xorgproto' \
        "$@"
}

_koopa_install_xorg_xtrans() {
    _koopa_install_app \
        --name='xorg-xtrans' \
        "$@"
}

_koopa_install_xsra() {
    _koopa_install_app \
        --name='xsra' \
        "$@"
}

_koopa_install_xsv() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='xsv' \
        "$@"
}

_koopa_install_xxhash() {
    _koopa_install_app \
        --name='xxhash' \
        "$@"
}

_koopa_install_xz() {
    _koopa_install_app \
        --name='xz' \
        "$@"
}

_koopa_install_yaml_cpp() {
    _koopa_install_app \
        --name='yaml-cpp' \
        "$@"
}

_koopa_install_yamllint() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yamllint' \
        "$@"
}

_koopa_install_yapf() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yapf' \
        "$@"
}

_koopa_install_yq() {
    _koopa_install_app \
        --name='yq' \
        "$@"
}

_koopa_install_yt_dlp() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yt-dlp' \
        "$@"
}

_koopa_install_zellij() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zellij' \
        "$@"
}

_koopa_install_zenith() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zenith' \
        "$@"
}

_koopa_install_zip() {
    _koopa_install_app \
        --name='zip' \
        "$@"
}

_koopa_install_zlib() {
    _koopa_install_app \
        --name='zlib' \
        "$@"
}

_koopa_install_zoxide() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zoxide' \
        "$@"
}

_koopa_install_zsh() {
    local -A dict
    _koopa_install_app \
        --installer='conda-package' \
        --name='zsh' \
        "$@"
    dict['zsh']="$(_koopa_app_prefix 'zsh')"
    _koopa_chmod --recursive 'g-w' "${dict['zsh']}/share/zsh"
    return 0
}

_koopa_install_zstd() {
    _koopa_install_app \
        --name='zstd' \
        "$@"
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

_koopa_is_defined_in_user_profile() {
    local file
    _koopa_assert_has_no_args "$#"
    file="$(_koopa_find_user_profile)"
    [[ -f "$file" ]] || return 1
    _koopa_file_detect_fixed --file="$file" --pattern='koopa'
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

_koopa_is_existing_aws_s3_uri() {
    local -A app dict
    local -a pos
    local uri
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
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
    _koopa_is_aws_s3_uri "$@" || return 1
    for uri in "$@"
    do
        local -A dict2
        dict2['uri']="$uri"
        dict2['bucket']="$(_koopa_aws_s3_bucket "${dict2['uri']}")"
        dict2['key']="$(_koopa_aws_s3_key "${dict2['uri']}")"
        "${app['aws']}" --profile="${dict['profile']}" \
            s3api head-object \
            --bucket "${dict2['bucket']}" \
            --key "${dict2['key']}" \
            --no-cli-pager \
            &> /dev/null \
            || return 1
        continue
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

_koopa_is_git_repo_clean() {
    local prefix
    _koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        _koopa_is_git_repo "$prefix" || return 1
        _koopa_git_repo_has_unstaged_changes "$prefix" && return 1
        _koopa_git_repo_needs_pull_or_push "$prefix" && return 1
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
    bool['only_bootstrap']=0
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
        if [[ -x "${dict['app']}" ]] && \
            _koopa_is_installed "${dict['app']}"
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
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
        dict['path']="${PATH:?}"
        dict['bin_prefix']="$(_koopa_bin_prefix)"
        _koopa_remove_from_path "${dict['bin_prefix']}"
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        export PATH="${dict['path']}"
        if [[ -x "${dict['app']}" ]]
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
    fi
    if [[ "${bool['allow_bootstrap']}" -eq 1 ]]
    then
        dict['bs_prefix']="$(_koopa_bootstrap_prefix)"
        dict['app']="${dict['bs_prefix']}/bin/${dict['bin_name']}"
        if [[ -x "${dict['app']}" ]]
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
    fi
    if [[ "${bool['allow_koopa_bin']}" -eq 1 ]]
    then
        dict['bin_prefix']="$(_koopa_bin_prefix)"
        dict['app']="${dict['bin_prefix']}/${dict['bin_name']}"
        if [[ -x "${dict['app']}" ]]
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
    fi
    if [[ "${bool['allow_opt_bin']}" -eq 1 ]]
    then
        dict['opt_prefix']="$(_koopa_opt_prefix)"
        dict['app']="${dict['opt_prefix']}/${dict['app_name']}/\
bin/${dict['bin_name']}"
        if [[ -x "${dict['app']}" ]]
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
    fi
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        if [[ -x "${dict['app']}" ]]
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(_koopa_realpath "${dict['app']}")"
            fi
            _koopa_print "${dict['app']}"
            return 0
        fi
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

_koopa_macos_activate_cli_colors() {
    [[ -z "${CLICOLOR:-}" ]] && export CLICOLOR=1
    return 0
}

_koopa_macos_activate_egnyte() {
    _koopa_add_to_path_end "${HOME}/Library/Group Containers/FELUD555VC.group.com.egnyte.DesktopApp/CLI"
    return 0
}

_koopa_macos_activate_homebrew() {
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    if [[ ! -x "${prefix}/bin/brew" ]]
    then
        return 0
    fi
    local brewfile
    brewfile="$(_koopa_xdg_config_home)/homebrew/Brewfile"
    _koopa_add_to_path_start "${prefix}/bin"
    if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]] && [[ -f "$brewfile" ]]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="$brewfile"
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

_koopa_macos_is_light_mode() {
    ! _koopa_macos_is_dark_mode
}

_koopa_macos_os_version() {
    local str
    str="$(/usr/bin/sw_vers -productVersion)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
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

_koopa_patch_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/lang/bash/include/patch"
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

_koopa_python_scripts_prefix() {
    _koopa_print "$(_koopa_koopa_prefix)/lang/python/scripts"
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

_koopa_python_activate_venv() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['active_env']="${VIRTUAL_ENV:-}"
    dict['name']="${1:?}"
    dict['nounset']="$(_koopa_boolean_nounset)"
    dict['prefix']="$(_koopa_python_virtualenvs_prefix)"
    dict['script']="${dict['prefix']}/${dict['name']}/bin/activate"
    _koopa_assert_is_readable "${dict['script']}"
    if [[ -n "${dict['active_env']}" ]]
    then
        _koopa_python_deactivate_venv "${dict['active_env']}"
    fi
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    source "${dict['script']}"
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

_koopa_python_create_venv() {
    local -A app bool dict
    local -a pip_args pkgs pos venv_args
    _koopa_assert_has_args "$#"
    app['python']=''
    bool['binary']=1
    bool['bootstrap']=0
    bool['system_site_packages']=1
    dict['name']=''
    dict['prefix']=''
    pos=()
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
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            '--bootstrap')
                bool['bootstrap']=1
                shift 1
                ;;
            '--no-binary')
                bool['binary']=0
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
    pkgs=("$@")
    [[ -z "${app['python']}" ]] && \
        app['python']="$(_koopa_locate_python --realpath)"
    _koopa_assert_is_set --python "${app['python']}"
    _koopa_assert_is_installed "${app['python']}"
    dict['py_version']="$(_koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        _koopa_major_minor_version "${dict['py_version']}" \
    )"
    if [[ -z "${dict['prefix']}" ]]
    then
        _koopa_assert_is_set --name "${dict['name']}"
        dict['venv_prefix']="$(_koopa_python_virtualenvs_prefix)"
        dict['prefix']="${dict['venv_prefix']}/${dict['name']}"
        dict['app_bn']="$(_koopa_basename "${dict['venv_prefix']}")"
        dict['app_prefix']="$(_koopa_app_prefix)/${dict['app_bn']}/\
${dict['py_maj_min_ver']}"
        if [[ ! -d "${dict['app_prefix']}" ]]
        then
            _koopa_alert "Configuring venv prefix at '${dict['app_prefix']}'."
            _koopa_mkdir "${dict['app_prefix']}"
        fi
        _koopa_link_in_opt \
            --name="${dict['app_bn']}" \
            --source="${dict['app_prefix']}"
    fi
    [[ -d "${dict['prefix']}" ]] && _koopa_rm "${dict['prefix']}"
    _koopa_assert_is_not_dir "${dict['prefix']}"
    _koopa_mkdir "${dict['prefix']}"
    unset -v PYTHONPATH
    venv_args=()
    if [[ "${bool['bootstrap']}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${bool['system_site_packages']}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict['prefix']}")
    "${app['python']}" -m venv "${venv_args[@]}"
    app['venv_python']="${dict['prefix']}/bin/python${dict['py_maj_min_ver']}"
    _koopa_assert_is_installed "${app['venv_python']}"
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        pip_args+=("--python=${app['venv_python']}")
        case "${bool['binary']}" in
            '0')
                pip_args+=('--no-binary=:all:')
                ;;
            '1')
                pip_args+=('--only-binary=:all:')
                ;;
        esac
        pip_args+=('pip' 'setuptools' 'wheel')
        _koopa_python_pip_install "${pip_args[@]}"
    fi
    if _koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        pip_args+=("--python=${app['venv_python']}")
        case "${bool['binary']}" in
            '0')
                pip_args+=('--no-binary=:all:')
                ;;
            '1')
                pip_args+=('--only-binary=:all:')
                ;;
        esac
        pip_args+=("${pkgs[@]}")
        _koopa_python_pip_install "${pip_args[@]}"
    fi
    return 0
}

_koopa_python_deactivate_venv() {
    local -A dict
    dict['prefix']="${VIRTUAL_ENV:-}"
    if [[ -z "${dict['prefix']}" ]]
    then
        _koopa_stop 'Python virtual environment is not active.'
    fi
    _koopa_remove_from_path_string "${dict['prefix']}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

_koopa_python_major_minor_version() {
    _koopa_print '3.14'
    return 0
}

_koopa_python_pip_install() {
    local -A app dict
    local -a dl_args pos
    _koopa_assert_has_args "$#"
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--no-binary='* | \
            '--only-binary='*)
                pos=("$1")
                shift 1
                ;;
            '--no-binary' | \
            '--only-binary')
                pos=("$1" "${2:?}")
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
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
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
    [[ -z "${app['python']}" ]] && \
        app['python']="$(_koopa_locate_python --realpath)"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    _koopa_assert_is_executable "${app[@]}"
    install_args=(
        '--default-timeout=300'
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-cache-dir'
        '--no-warn-script-location'
        '--progress-bar=on'
    )
    if [[ -n "${dict['prefix']}" ]]
    then
        install_args+=(
            "--target=${dict['prefix']}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict['prefix']}")
    fi
    install_args+=("$@")
    dl_args=(
        'python' "${app['python']}"
        'pip install args' "${install_args[*]}"
    )
    _koopa_dl "${dl_args[@]}"
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app['python']}" -m pip --isolated install "${install_args[@]}"
    return 0
}

_koopa_python_script() {
    local -A app dict
    local -a pos
    _koopa_assert_has_args "$#"
    app['python']=''
    while (("$#"))
    do
        case "$1" in
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            *)
                pos+=("${1:?}")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    if [[ -z "${app['python']}" ]]
    then
        app['python']="$(_koopa_locate_python --allow-bootstrap --allow-system)"
    fi
    _koopa_assert_is_installed "${app[@]}"
    dict['prefix']="$(_koopa_python_scripts_prefix)"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['cmd_name']="${1:?}"
    shift 1
    dict['script']="${dict['prefix']}/${dict['cmd_name']}"
    _koopa_assert_is_executable "${dict['script']}"
    "${app['python']}" "${dict['script']}" "$@"
}

_koopa_python_update_venv() {
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['venv_prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['venv_prefix']}"
    dict['requirements']="$(_koopa_mktemp)"
    _koopa_python_activate_venv "${dict['venv_prefix']}"
    pip freeze > "$dict['requirements']}"
    pip install -r "${dict['requirements']}" --upgrade
    _koopa_python_deactivate_venv
    _koopa_rm "${dict['requirements']}"
    return 0
}

_koopa_r_bioconda_check() {
    local -A dict
    _koopa_assert_has_args "$#"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    dict['pkg_cache_prefix']="$(_koopa_init_dir "${dict['tmp_dir']}/conda")"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(_koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            _koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tarball']="https://github.com/acidgenomics/\
r-${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['conda_prefix']="$(_koopa_init_dir "${dict2['tmp_dir']}/conda")"
        dict2['tarball']="https://github.com/acidgenomics/${dict2['pkg2']}/\
archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
pkgbuild::check_build_tools(debug = TRUE)
install.packages(
    pkgs = c("AcidDevTools", "AcidTest"),
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = FALSE
)
AcidDevTools::check("src")
END
        _koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        _koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            local -A app2
            local -a conda_deps
            _koopa_cd "${dict2['tmp_dir']}"
            conda_deps=(
                'r-biocmanager'
                'r-desc'
                'r-goalie'
                'r-knitr'
                'r-rcmdcheck'
                'r-rmarkdown'
                'r-testthat'
                'r-urlchecker'
                "${dict2['pkg2']}"
            )
            _koopa_conda_create_env \
                --package-cache-prefix="${dict['pkg_cache_prefix']}" \
                --prefix="${dict2['conda_prefix']}" \
                "${conda_deps[@]}"
            app2['rscript']="${dict2['conda_prefix']}/bin/Rscript"
            _koopa_assert_is_executable "${app2[@]}"
            _koopa_download "${dict2['tarball']}"
            _koopa_extract "$(_koopa_basename "${dict2['tarball']}")" 'src'
            _koopa_conda_activate_env "${dict2['conda_prefix']}"
            "${app2['rscript']}" "${dict2['rscript']}"
            _koopa_conda_deactivate
        )
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_r_check() {
    local -A app
    local -A dict
    local pkg
    _koopa_assert_has_args "$#"
    app['rscript']="$(_koopa_locate_rscript --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(_koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            _koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tmp_lib']="$(_koopa_init_dir "${dict2['tmp_dir']}/lib")"
        dict2['tarball']="https://github.com/acidgenomics/\
${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
.libPaths(new = "${dict2['tmp_lib']}", include.site = FALSE)
message("repos")
print(getOption("repos"))
message(".libPaths")
print(.libPaths())
message("Installing AcidDevTools.")
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
if (!requireNamespace("AcidDevTools", quietly = TRUE)) {
    install.packages(
        pkgs = c(
            "AcidDevTools",
            "desc",
            "goalie",
            "rcmdcheck",
            "testthat",
            "urlchecker"
        ),
        repos = c(
            "https://r.acidgenomics.com",
            BiocManager::repositories()
        ),
        dependencies = NA
    )
}
message("Installing ${dict2['pkg']}.")
install.packages(
    pkgs = "${dict2['pkg']}",
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = TRUE
)
AcidDevTools::check("src")
END
        _koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        _koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            _koopa_cd "${dict2['tmp_dir']}"
            _koopa_download "${dict2['tarball']}"
            _koopa_extract "$(_koopa_basename "${dict2['tarball']}")" 'src'
            "${app['rscript']}" "${dict2['rscript']}"
        )
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_r_configure_environ() {
    local -A app app_pc_path_arr bool conf_dict dict
    local -a keys lines path_arr pc_path_arr
    local i key
    lines=()
    path_arr=()
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    [[ "${bool['system']}" -eq 1 ]] && bool['use_apps']=0
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ! _koopa_is_macos && app['bzip2']="$(_koopa_locate_bzip2)"
        app['cat']="$(_koopa_locate_cat)"
        app['gzip']="$(_koopa_locate_gzip)"
        app['less']="$(_koopa_locate_less)"
        app['ln']="$(_koopa_locate_ln)"
        app['make']="$(_koopa_locate_make)"
        app['pkg_config']="$(_koopa_locate_pkg_config)"
        app['sed']="$(_koopa_locate_sed --allow-system)"
        app['strip']="$(_koopa_locate_strip)"
        app['tar']="$(_koopa_locate_tar)"
        app['texi2dvi']="$(_koopa_locate_texi2dvi)"
        app['unzip']="$(_koopa_locate_unzip)"
        app['vim']="$(_koopa_locate_vim)"
        app['zip']="$(_koopa_locate_zip)"
        _koopa_assert_is_executable "${app[@]}"
        app['lpr']="$(_koopa_locate_lpr --allow-missing --only-system)"
        app['open']="$(_koopa_locate_open --allow-missing --only-system)"
        dict['udunits2']="$(_koopa_app_prefix 'udunits')"
    fi
    dict['arch']="$(_koopa_arch)"
    if _koopa_is_macos && _koopa_is_arm64
    then
        dict['arch']='aarch64'
    fi
    dict['bin_prefix']="$(_koopa_bin_prefix)"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['r_prefix']="$(_koopa_r_prefix "${app['r']}")"
    _koopa_assert_is_dir "${dict['r_prefix']}"
    lines+=(
        "KOOPA_PREFIX=${dict['_koopa_prefix']}"
        'R_BATCHSAVE=--no-save --no-restore'
        "R_LIBS_SITE=\${R_HOME}/site-library"
        "R_LIBS_USER=\${R_LIBS_SITE}"
        'R_PAPERSIZE=letter'
        "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
        "TZ=\${TZ:-America/New_York}"
    )
    if _koopa_is_linux
    then
        path_arr+=(
            '/usr/lib/rstudio-server/bin/quarto/bin'
            "/usr/lib/rstudio-server/bin/quarto/bin/tools/${dict['arch']}"
            '/usr/lib/rstudio-server/bin/postback'
        )
    elif _koopa_is_macos
    then
        path_arr+=(
            '/Applications/RStudio.app/Contents/Resources/app/quarto/bin'
            "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/\
tools/${dict['arch']}"
            '/Applications/RStudio.app/Contents/Resources/app/bin/postback'
        )
    fi
    if [[ "${bool['system']}" -eq 0 ]] || _koopa_is_macos
    then
        path_arr+=("${dict['bin_prefix']}")
    fi
    path_arr+=(
        '/usr/bin'
        '/bin'
        '/usr/sbin'
        '/sbin'
    )
    if _koopa_is_macos
    then
        path_arr+=(
            '/Library/TeX/texbin'
            '/usr/local/MacGPG2/bin'
            '/opt/X11/bin'
        )
    fi
    conf_dict['path']="$(printf '%s:' "${path_arr[@]}")"
    lines+=("PATH=${conf_dict['path']}")
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ! _koopa_is_macos && keys+=('bzip2')
        keys+=(
            'cairo'
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'harfbuzz'
            'hdf5'
            'icu4c' # libxml2
            'imagemagick'
            'libffi'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'readline'
            'sqlite'
            'xorg-libice'
            'xorg-libpthread-stubs'
            'xorg-libsm'
            'xorg-libx11'
            'xorg-libxau'
            'xorg-libxcb'
            'xorg-libxdmcp'
            'xorg-libxext'
            'xorg-libxrandr'
            'xorg-libxrender'
            'xorg-libxt'
            'xorg-xorgproto'
            'xz'
            'zlib'
            'zstd'
        )
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(_koopa_app_prefix "$key")"
            _koopa_assert_is_dir "$prefix"
            app_pc_path_arr[$key]="$prefix"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            case "$i" in
                'xorg-xorgproto')
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/share/pkgconfig"
                    ;;
                *)
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib/pkgconfig"
                    ;;
            esac
        done
        _koopa_assert_is_dir "${app_pc_path_arr[@]}"
        pc_path_arr=()
        pc_path_arr+=("${app_pc_path_arr[@]}")
        if [[ "${bool['system']}" -eq 1 ]]
        then
            local -a sys_pc_path_arr
            readarray -t sys_pc_path_arr <<< "$( \
                "${app['pkg_config']}" --variable 'pc_path' 'pkg-config' \
            )"
            pc_path_arr+=("${sys_pc_path_arr[@]}")
        fi
        conf_dict['pkg_config_path']="$(printf '%s:' "${pc_path_arr[@]}")"
        if ! _koopa_is_macos
        then
            lines+=("R_BZIPCMD=${app['bzip2']}")
        fi
        lines+=(
            "EDITOR=${app['vim']}"
            "LN_S=${app['ln']} -s"
            "MAKE=${app['make']}"
            "PAGER=${app['less']}"
            "PKG_CONFIG_PATH=${conf_dict['pkg_config_path']}"
            "R_BROWSER=${app['open']}"
            "R_GZIPCMD=${app['gzip']}"
            "R_PDFVIEWER=${app['open']}"
            "R_PRINTCMD=${app['lpr']}"
            "R_STRIP_SHARED_LIB=${app['strip']} -x"
            "R_STRIP_STATIC_LIB=${app['strip']} -S"
            "R_TEXI2DVICMD=${app['texi2dvi']}"
            "R_UNZIPCMD=${app['unzip']}"
            "R_ZIPCMD=${app['zip']}"
            "SED=${app['sed']}"
            "TAR=${app['tar']}"
        )
    fi
    if _koopa_is_macos
    then
        lines+=('R_MAX_NUM_DLLS=153')
    fi
    lines+=('R_DATATABLE_NUM_PROCS_PERCENT=100')
    lines+=('RCMDCHECK_ERROR_ON=error')
    lines+=(
        'R_REMOTES_STANDALONE=true'
        'R_REMOTES_UPGRADE=always'
    )
    lines+=(
        "RETICULATE_CONDA=${app['conda']}"
        "WORKON_HOME=\${HOME}/.venv"
    )
    lines+=(
        'STRINGI_DISABLE_ICU_BUNDLE=1'
    )
    lines+=(
        "R_USER_CACHE_DIR=\${HOME}/.cache"
        "R_USER_CONFIG_DIR=\${HOME}/.config"
        "R_USER_DATA_DIR=\${HOME}/.local/share"
    )
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        lines+=(
            "UDUNITS2_INCLUDE=${dict['udunits2']}/include"
            "UDUNITS2_LIBS=${dict['udunits2']}/lib"
        )
    fi
    lines+=("VROOM_CONNECTION_SIZE=524288")
    if _koopa_is_fedora_like
    then
        dict['oracle_ver']="$( \
            _koopa_app_json_version 'oracle-instant-client' \
        )"
        dict['oracle_ver']="$( \
            _koopa_major_minor_version "${dict['oracle_ver']}" \
        )"
        lines+=(
            "OCI_VERSION=${dict['oracle_ver']}"
            "ORACLE_HOME=/usr/lib/oracle/\${OCI_VERSION}/client64"
            "OCI_INC=/usr/include/oracle/\${OCI_VERSION}/client64"
            "OCI_LIB=\${ORACLE_HOME}/lib"
            "PATH=\${PATH}:\${ORACLE_HOME}/bin"
            "TNS_ADMIN=\${ORACLE_HOME}/network/admin"
        )
    fi
    lines+=(
        '_R_CHECK_EXECUTABLES_=false'
        '_R_CHECK_EXECUTABLES_EXCLUSIONS_=false'
        "_R_CHECK_LENGTH_1_CONDITION_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        "_R_CHECK_LENGTH_1_LOGIC2_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        '_R_CHECK_S3_METHODS_NOT_REGISTERED_=true'
        'R_DEFAULT_INTERNET_TIMEOUT=600'
    )
    lines+=(
        '_R_CHECK_SYSTEM_CLOCK_=0'
        '_R_CHECK_TESTS_NLINES_=0'
    )
    if _koopa_is_debian_like
    then
        lines+=(
            "_R_CHECK_COMPILATION_FLAGS_KNOWN_=-Wformat \
-Werror=format-security -Wdate-time"
        )
    fi
    dict['file']="${dict['r_prefix']}/etc/Renviron.site"
    if [[ -L "${dict['file']}" ]]
    then
        dict['realfile']="$(_koopa_realpath "${dict['file']}")"
        if [[ "${dict['realfile']}" == '/etc/R/Renviron.site' ]]
        then
            dict['file']="${dict['realfile']}"
        fi
    fi
    _koopa_alert_info "Modifying '${dict['file']}'."
    dict['string']="$(_koopa_print "${lines[@]}" | "${app['sort']}")"
    if [[ "${bool['system']}" -eq 1 ]]
    then
        _koopa_rm --sudo "${dict['file']}"
        _koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
        _koopa_chmod --sudo 0644 "${dict['file']}"
    else
        _koopa_rm "${dict['file']}"
        _koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    return 0
}

_koopa_r_configure_java() {
    local -A app bool conf_dict dict
    local -a java_args r_cmd
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]]
    then
        _koopa_is_macos || return 0
        _koopa_has_standard_umask || return 0
        bool['use_apps']=0
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        dict['java_home']="$(_koopa_app_prefix 'temurin')"
    else
        if _koopa_is_linux
        then
            dict['java_home']='/usr/lib/jvm/default-java'
        elif _koopa_is_macos
        then
            dict['java_home']="$(/usr/libexec/java_home || true)"
        fi
    fi
    if [[ ! -d "${dict['java_home']}" ]]
    then
        _koopa_alert_note "Failed to detected system Java. \
Skipping configuration."
        return 0
    fi
    app['jar']="${dict['java_home']}/bin/jar"
    app['java']="${dict['java_home']}/bin/java"
    app['javac']="${dict['java_home']}/bin/javac"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert_info "Using Java SDK at '${dict['java_home']}'."
    conf_dict['java_home']="${dict['java_home']}"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['javah']=''
    java_args=(
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
    )
    if [[ "${bool['system']}" -eq 1 ]]
    then
        r_cmd=('_koopa_sudo' "${app['r']}")
    else
        r_cmd=("${app['r']}")
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}

_koopa_r_configure_ldpaths() {
    local -A app bool dict ld_lib_app_arr
    local -a keys ld_lib_arr lines
    local key
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    bool['use_local']=0
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    [[ "${bool['system']}" -eq 1 ]] && bool['use_apps']=0
    dict['arch']="$(_koopa_arch)"
    if _koopa_is_macos
    then
        case "${dict['arch']}" in
            'aarch64')
                dict['arch']='arm64'
                ;;
        esac
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        dict['java_home']="$(_koopa_app_prefix 'temurin')"
    else
        if _koopa_is_linux
        then
            dict['java_home']='/usr/lib/jvm/default-java'
        elif _koopa_is_macos
        then
            dict['java_home']="$(/usr/libexec/java_home)"
        fi
    fi
    _koopa_assert_is_dir "${dict['java_home']}"
    lines=()
    lines+=(": \${JAVA_HOME=${dict['java_home']}}")
    if _koopa_is_macos
    then
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/Contents/Home/lib/server}")
    else
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/lib/server}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ! _koopa_is_macos && keys+=('bzip2')
        keys+=(
            'cairo'
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'harfbuzz'
            'hdf5'
            'icu4c' # libxml2
            'imagemagick'
            'libffi'
            'libgit2'
            'libiconv'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'readline'
            'sqlite'
            'xorg-libice'
            'xorg-libpthread-stubs'
            'xorg-libsm'
            'xorg-libx11'
            'xorg-libxau'
            'xorg-libxcb'
            'xorg-libxdmcp'
            'xorg-libxext'
            'xorg-libxrandr'
            'xorg-libxrender'
            'xorg-libxt'
            'xz'
            'zlib'
            'zstd'
        )
        if _koopa_is_macos || [[ "${bool['system']}" -eq 0 ]]
        then
            keys+=('gettext')
        fi
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(_koopa_app_prefix "$key")"
            _koopa_assert_is_dir "$prefix"
            ld_lib_app_arr[$key]="$prefix"
        done
        for i in "${!ld_lib_app_arr[@]}"
        do
            ld_lib_app_arr[$i]="${ld_lib_app_arr[$i]}/lib"
        done
        _koopa_assert_is_dir "${ld_lib_app_arr[@]}"
    fi
    ld_lib_arr=()
    ld_lib_arr+=("\${R_HOME}/lib")
    if [[ "${bool['use_local']}" -eq 1 ]] && [[ -d '/usr/local/lib' ]]
    then
        ld_lib_arr+=('/usr/local/lib')
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ld_lib_arr+=("${ld_lib_app_arr[@]}")
    fi
    if _koopa_is_linux
    then
        dict['sys_libdir']="/usr/lib/${dict['arch']}-linux-gnu"
        _koopa_assert_is_dir "${dict['sys_libdir']}" '/usr/lib' '/lib'
        ld_lib_arr+=("${dict['sys_libdir']}" '/usr/lib' '/lib')
    fi
    ld_lib_arr+=("\${R_JAVA_LD_LIBRARY_PATH}")
    dict['library_path']="$(printf '%s:' "${ld_lib_arr[@]}")"
    lines+=(
        "R_LD_LIBRARY_PATH=\"${dict['library_path']}\""
    )
    if _koopa_is_linux
    then
        lines+=(
            "LD_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export LD_LIBRARY_PATH'
        )
    elif _koopa_is_macos
    then
        lines+=(
            "DYLD_FALLBACK_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export DYLD_FALLBACK_LIBRARY_PATH'
        )
    fi
    dict['r_prefix']="$(_koopa_r_prefix "${app['r']}")"
    _koopa_assert_is_dir "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    dict['file_bak']="${dict['file']}.bak"
    _koopa_assert_is_file "${dict['file']}"
    dict['string']="$(_koopa_print "${lines[@]}")"
    _koopa_alert_info "Modifying '${dict['file']}'."
    if [[ "${bool['system']}" -eq 1 ]]
    then
        if [[ ! -f "${dict['file_bak']}" ]]
        then
            _koopa_cp --sudo "${dict['file']}" "${dict['file_bak']}"
        fi
        _koopa_rm --sudo "${dict['file']}"
        _koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
        _koopa_chmod --sudo 0644 "${dict['file']}"
    else
        if [[ ! -f "${dict['file_bak']}" ]]
        then
            _koopa_cp "${dict['file']}" "${dict['file_bak']}"
        fi
        _koopa_rm "${dict['file']}"
        _koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    return 0
}

_koopa_r_configure_makevars() {
    local -A app app_pc_path_arr bool conf_dict dict
    local -a cppflags keys ldflags lines pkg_config
    local i key
    _koopa_assert_has_args_eq "$#" 1
    lines=()
    app['r']="${1:?}"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    [[ "${bool['system']}" -eq 1 ]] && bool['use_apps']=0
    if [[ "${bool['system']}" -eq 1 ]] && _koopa_is_macos
    then
        _koopa_assert_is_file '/usr/local/include/omp.h'
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=("SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        app['ar']="$(_koopa_locate_ar --only-system)"
        app['awk']="$(_koopa_locate_awk)"
        app['bash']="$(_koopa_locate_bash)"
        app['cc']="$(_koopa_locate_cc --only-system)"
        app['cxx']="$(_koopa_locate_cxx --only-system)"
        app['echo']="$(_koopa_locate_echo)"
        app['gfortran']="$(_koopa_locate_gfortran --only-system)"
        app['make']="$(_koopa_locate_make)"
        app['pkg_config']="$(_koopa_locate_pkg_config)"
        app['ranlib']="$(_koopa_locate_ranlib --only-system)"
        app['sed']="$(_koopa_locate_sed)"
        app['strip']="$(_koopa_locate_strip)"
        app['tar']="$(_koopa_locate_tar)"
        app['yacc']="$(_koopa_locate_yacc)"
        _koopa_assert_is_executable "${app[@]}"
        _koopa_is_macos && dict['gettext']="$(_koopa_app_prefix 'gettext')"
        dict['openssl']="$(_koopa_app_prefix 'openssl')"
        ! _koopa_is_macos && keys+=('bzip2')
        keys+=(
            'cairo'
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'harfbuzz'
            'hdf5'
            'icu4c' # libxml2
            'imagemagick'
            'libffi'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'readline'
            'sqlite'
            'xorg-libice'
            'xorg-libpthread-stubs'
            'xorg-libsm'
            'xorg-libx11'
            'xorg-libxau'
            'xorg-libxcb'
            'xorg-libxdmcp'
            'xorg-libxext'
            'xorg-libxrandr'
            'xorg-libxrender'
            'xorg-libxt'
            'xorg-xorgproto'
            'xz'
            'zlib'
            'zstd'
        )
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(_koopa_app_prefix "$key")"
            _koopa_assert_is_dir "$prefix"
            app_pc_path_arr[$key]="$prefix"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            case "$i" in
                'xorg-xorgproto')
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
share/pkgconfig"
                    ;;
                *)
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
lib/pkgconfig"
                    ;;
            esac
        done
        _koopa_assert_is_dir "${app_pc_path_arr[@]}"
        _koopa_add_to_pkg_config_path "${app_pc_path_arr[@]}"
        pkg_config+=(
            'fontconfig'
            'freetype2'
            'fribidi'
            'harfbuzz'
            'hdf5'
            'icu-i18n'
            'icu-uc'
            'libcurl'
            'libjpeg'
            'libpcre2-8'
            'libpng'
            'libtiff-4'
            'libxml-2.0'
            'libzstd'
            'zlib'
        )
        cppflags+=(
            "$("${app['pkg_config']}" --cflags "${pkg_config[@]}")"
            "-I${dict['openssl']}/include"
        )
        ldflags+=(
            "$("${app['pkg_config']}" --libs-only-L "${pkg_config[@]}")"
            "-L${dict['openssl']}/lib"
        )
        if _koopa_is_macos
        then
            cppflags+=("-I${dict['gettext']}/include")
            ldflags+=("-L${dict['gettext']}/lib")
            if [[ "${bool['system']}" -eq 1 ]]
            then
                ldflags+=('-lomp')
            fi
        fi
        conf_dict['ar']="${app['ar']}"
        conf_dict['awk']="${app['awk']}"
        conf_dict['cc']="${app['cc']}"
        conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
        conf_dict['cppflags']="${cppflags[*]}"
        conf_dict['cxx']="${app['cxx']} -std=gnu++14"
        conf_dict['echo']="${app['echo']}"
        conf_dict['f77']="${app['gfortran']}"
        conf_dict['fc']="${app['gfortran']}"
        conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
        conf_dict['flibs']="$(_koopa_r_gfortran_libs)"
        conf_dict['ldflags']="${ldflags[*]}"
        conf_dict['make']="${app['make']}"
        conf_dict['objc_libs']='-lobjc'
        conf_dict['objcflags']="-Wall -g -O2 -fobjc-exceptions \$(LTO)"
        conf_dict['ranlib']="${app['ranlib']}"
        conf_dict['safe_fflags']='-Wall -g -O2 -msse2 -mfpmath=sse'
        conf_dict['sed']="${app['sed']}"
        conf_dict['shell']="${app['bash']}"
        conf_dict['strip_shared_lib']="${app['strip']} -x"
        conf_dict['strip_static_lib']="${app['strip']} -S"
        conf_dict['tar']="${app['tar']}"
        conf_dict['yacc']="${app['yacc']}"
        conf_dict['cxx11']="${conf_dict['cxx']}"
        conf_dict['cxx14']="${conf_dict['cxx']}"
        conf_dict['cxx17']="${conf_dict['cxx']}"
        conf_dict['cxx20']="${conf_dict['cxx']}"
        conf_dict['cxxflags']="${conf_dict['cflags']}"
        conf_dict['cxx11flags']="${conf_dict['cxxflags']}"
        conf_dict['cxx14flags']="${conf_dict['cxxflags']}"
        conf_dict['cxx17flags']="${conf_dict['cxxflags']}"
        conf_dict['cxx20flags']="${conf_dict['cxxflags']}"
        conf_dict['f77flags']="${conf_dict['fflags']}"
        conf_dict['fcflags']="${conf_dict['fflags']}"
        conf_dict['objc']="${conf_dict['cc']}"
        conf_dict['objcxx']="${conf_dict['cxx']}"
        if [[ "${bool['system']}" -eq 1 ]]
        then
            conf_dict['op']='='
        else
            conf_dict['op']='+='
        fi
        lines+=(
            "AR = ${conf_dict['ar']}"
            "AWK = ${conf_dict['awk']}"
            "CC = ${conf_dict['cc']}"
            "CFLAGS = ${conf_dict['cflags']}"
            "CPPFLAGS ${conf_dict['op']} ${conf_dict['cppflags']}"
            "CXX = ${conf_dict['cxx']}"
            "CXX11 = ${conf_dict['cxx11']}"
            "CXX11FLAGS = ${conf_dict['cxx11flags']}"
            "CXX14 = ${conf_dict['cxx14']}"
            "CXX14FLAGS = ${conf_dict['cxx14flags']}"
            "CXX17 = ${conf_dict['cxx17']}"
            "CXX17FLAGS = ${conf_dict['cxx17flags']}"
            "CXX20 = ${conf_dict['cxx20']}"
            "CXX20FLAGS = ${conf_dict['cxx20flags']}"
            "CXXFLAGS = ${conf_dict['cxxflags']}"
            "ECHO = ${conf_dict['echo']}"
            "F77 = ${conf_dict['f77']}"
            "F77FLAGS = ${conf_dict['f77flags']}"
            "FC = ${conf_dict['fc']}"
            "FCFLAGS = ${conf_dict['fcflags']}"
            "FFLAGS = ${conf_dict['fflags']}"
            "FLIBS = ${conf_dict['flibs']}"
            "LDFLAGS ${conf_dict['op']} ${conf_dict['ldflags']}"
            "MAKE = ${conf_dict['make']}"
            "OBJC = ${conf_dict['objc']}"
            "OBJCFLAGS = ${conf_dict['objcflags']}"
            "OBJCXX = ${conf_dict['objcxx']}"
            "OBJC_LIBS = ${conf_dict['objc_libs']}"
            "RANLIB = ${conf_dict['ranlib']}"
            "SAFE_FFLAGS = ${conf_dict['safe_fflags']}"
            "SED = ${conf_dict['sed']}"
            "SHELL = ${conf_dict['shell']}"
            "STRIP_SHARED_LIB = ${conf_dict['strip_shared_lib']}"
            "STRIP_STATIC_LIB = ${conf_dict['strip_static_lib']}"
            "TAR = ${conf_dict['tar']}"
            "YACC = ${conf_dict['yacc']}"
        )
    fi
    dict['r_prefix']="$(_koopa_r_prefix "${app['r']}")"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    if _koopa_is_linux && \
        [[ "${bool['system']}" -eq 1 ]] && \
        [[ -f "${dict['file']}" ]]
    then
        _koopa_alert_info "Deleting '${dict['file']}'."
        _koopa_rm --sudo "${dict['file']}"
        return 0
    fi
    _koopa_is_array_empty "${lines[@]}" && return 0
    dict['string']="$(_koopa_print "${lines[@]}" | "${app['sort']}")"
    _koopa_alert_info "Modifying '${dict['file']}'."
    if [[ "${bool['system']}" -eq 1 ]]
    then
        _koopa_rm --sudo "${dict['file']}"
        _koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    else
        _koopa_rm "${dict['file']}"
        _koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    unset -v PKG_CONFIG_PATH
    return 0
}

_koopa_r_copy_files_into_etc() {
    local -A app bool dict
    local -a files
    local file
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['r_prefix']="$(_koopa_r_prefix "${app['r']}")"
    dict['r_etc_source']="$(_koopa_koopa_prefix)/etc/R"
    dict['r_etc_target']="${dict['r_prefix']}/etc"
    _koopa_assert_is_dir \
        "${dict['r_etc_source']}" \
        "${dict['r_etc_target']}" \
        "${dict['r_prefix']}"
    files=('Rprofile.site' 'repositories')
    for file in "${files[@]}"
    do
        local -A dict2
        dict2['source']="${dict['r_etc_source']}/${file}"
        dict2['target']="${dict['r_etc_target']}/${file}"
        _koopa_assert_is_file "${dict2['source']}"
        if [[ -L "${dict2['target']}" ]]
        then
            dict2['realtarget']="$(_koopa_realpath "${dict2['target']}")"
            if [[ "${dict2['realtarget']}" == "/etc/R/${file}" ]]
            then
                dict2['target']="${dict2['realtarget']}"
            fi
        fi
        _koopa_alert "Modifying '${dict2['target']}'."
        if [[ "${bool['system']}" -eq 1 ]]
        then
            _koopa_cp --sudo "${dict2['source']}" "${dict2['target']}"
            _koopa_chmod --sudo 0644 "${dict2['target']}"
        else
            _koopa_cp "${dict2['source']}" "${dict2['target']}"
        fi
    done
    return 0
}

_koopa_r_gfortran_libs() {
    local -A app dict
    local -a flibs libs libs2
    local lib
    _koopa_assert_has_no_args "$#"
    dict['arch']="$(_koopa_arch)"
    if _koopa_is_linux
    then
        app['gfortran']="$(_koopa_locate_gfortran --only-system)"
        _koopa_assert_is_executable "${app[@]}"
    elif _koopa_is_macos
    then
        app['dirname']="$(_koopa_locate_dirname --allow-system)"
        app['sort']="$(_koopa_locate_sort --allow-system)"
        app['xargs']="$(_koopa_locate_xargs --allow-system)"
        _koopa_assert_is_executable "${app[@]}"
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['lib_prefix']='/opt/gfortran/lib'
        _koopa_assert_is_dir "${dict['lib_prefix']}"
        readarray -t libs <<< "$( \
            _koopa_find \
                --pattern='libgfortran.a' \
                --prefix="${dict['lib_prefix']}" \
                --type='f' \
            | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
            | "${app['sort']}" --unique \
        )"
        _koopa_assert_is_array_non_empty "${libs[@]:-}"
        for lib in "${libs[@]}"
        do
            case "$lib" in
                */"${dict['arch']}-"*)
                    libs2+=("$lib")
                    ;;
            esac
        done
        _koopa_assert_is_array_non_empty "${libs2[@]:-}"
        libs=("${libs2[@]}")
        libs+=("${dict['lib_prefix']}")
        for lib in "${libs[@]}"
        do
            flibs+=("-L${lib}")
        done
    fi
    flibs+=('-lgfortran')
    if _koopa_is_linux
    then
        flibs+=('-lm')
    fi
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    _koopa_print "${flibs[*]}"
    return 0
}

_koopa_r_install_packages_in_site_library() {
    local -A app
    _koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    shift 1
    _koopa_r_script \
        --r="${app['r']}" \
        'install-packages-in-site-library.R' \
        "$@"
    return 0
}

_koopa_r_migrate_non_base_packages() {
    local -A app
    local -a pkgs
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    readarray -t pkgs <<< "$( \
        _koopa_r_system_packages_non_base "${app['r']}"
    )"
    _koopa_is_array_non_empty "${pkgs[@]:-}" || return 0
    _koopa_alert 'Migrating non-base packages to site library.'
    _koopa_dl 'Packages' "$(_koopa_to_string "${pkgs[@]}")"
    _koopa_r_install_packages_in_site_library "${app['r']}" "${pkgs[@]}"
    _koopa_r_remove_packages_in_system_library "${app['r']}" "${pkgs[@]}"
    return 0
}

_koopa_r_package_version() {
    local -A app
    local str vec
    _koopa_assert_has_args "$#"
    app['rscript']="$(_koopa_locate_rscript)"
    _koopa_assert_is_executable "${app[@]}"
    pkgs=("$@")
    _koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(_koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app['rscript']}" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_r_paste_to_vector() {
    local str
    _koopa_assert_has_args "$#"
    str="$(printf '"%s", ' "$@")"
    str="$(_koopa_strip_right --pattern=', ' "$str")"
    str="$(printf 'c(%s)\n' "$str")"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_r_remove_packages_in_system_library() {
    local -A app bool dict
    local -a rscript_cmd
    _koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    shift 1
    bool['system']=0
    ! _koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['script']="$(_koopa_r_scripts_prefix)/\
remove-packages-in-system-library.R"
    _koopa_assert_is_executable "${dict['script']}"
    rscript_cmd=()
    if [[ "${bool['system']}" -eq 1 ]]
    then
        rscript_cmd+=('_koopa_sudo')
    fi
    rscript_cmd+=("${app['rscript']}")
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}

_koopa_r_script() {
    local -A app bool dict
    local -a pos rscript_cmd
    _koopa_assert_has_args "$#"
    app['r']=''
    bool['system']=0
    bool['vanilla']=0
    while (("$#"))
    do
        case "$1" in
            '--r='*)
                app['r']="${1#*=}"
                shift 1
                ;;
            '--r')
                app['r']="${2:?}"
                shift 2
                ;;
            '--system')
                bool['system']=1
                shift 1
                ;;
            '--vanilla')
                bool['vanilla']=1
                shift 1
                ;;
            *)
                pos+=("${1:?}")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    if [[ -z "${app['r']}" ]]
    then
        if [[ "${bool['system']}" -eq 1 ]]
        then
            app['r']="$(_koopa_locate_system_r)"
        else
            app['r']="$(_koopa_locate_r)"
        fi
    fi
    app['rscript']="${app['r']}script"
    _koopa_assert_is_installed "${app[@]}"
    dict['prefix']="$(_koopa_r_scripts_prefix)"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['cmd_name']="${1:?}"
    shift 1
    dict['script']="${dict['prefix']}/${dict['cmd_name']}"
    _koopa_assert_is_executable "${dict['script']}"
    rscript_cmd+=("${app['rscript']}")
    if [[ "${bool['vanilla']}" -eq 1 ]]
    then
        rscript_cmd+=('--vanilla')
    fi
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}

_koopa_r_shiny_run_app() {
    local -A app dict
    app['r']="$(_koopa_locate_r)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    "${app['r']}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict['prefix']}')"
    return 0
}

_koopa_r_system_packages_non_base() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$( \
        _koopa_r_script \
            --r="${app['r']}" \
            --vanilla \
            'system-packages-non-base.R' \
    )"
    [[ -n "${dict['string']}" ]] || return 0
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_r_version() {
    local -A app
    local str
    _koopa_assert_has_args_le "$#" 1
    app['head']="$(_koopa_locate_head --allow-system)"
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(_koopa_locate_r)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        R_HOME='' \
        "${app['r']}" --version 2>/dev/null \
            | "${app['head']}" -n 1 \
    )"
    if _koopa_str_detect_fixed \
        --string="$str" \
        --pattern='R Under development (unstable)'
    then
        str='devel'
    else
        str="$(_koopa_extract_version "$str")"
    fi
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_reinstall_all_revdeps() {
    local -a flags pos
    local app_name
    _koopa_assert_has_args "$#"
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--'*)
                flags+=("$1")
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        local -a install_args revdeps
        install_args=()
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            install_args+=("${flags[@]}")
        fi
        install_args+=("$app_name")
        readarray -t revdeps <<< "$(_koopa_app_reverse_dependencies "$app_name")"
        if _koopa_is_array_non_empty "${revdeps[@]:-}"
        then
            install_args+=("${revdeps[@]}")
            _koopa_dl \
                "${app_name} reverse dependencies" \
                "$(_koopa_to_string "${revdeps[@]}")"
        else
            _koopa_alert_note "'${app_name}' has no reverse dependencies."
        fi
        _koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}

_koopa_reinstall_only_revdeps() {
    local -a flags pos
    local app_name
    _koopa_assert_has_args "$#"
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--'*)
                flags+=("$1")
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        local -a install_args revdeps
        install_args=()
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            install_args+=("${flags[@]}")
        fi
        readarray -t revdeps <<< "$(_koopa_app_reverse_dependencies "$app_name")"
        if _koopa_assert_is_array_non_empty "${revdeps[@]}"
        then
            install_args+=("${revdeps[@]}")
            _koopa_dl \
                "${app_name} reverse dependencies" \
                "$(_koopa_to_string "${revdeps[@]}")"
        else
            _koopa_stop "'${app_name}' has no reverse dependencies."
        fi
        _koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}

_koopa_salmon_detect_bam_library_type() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['jq']="$(_koopa_locate_jq --allow-system)"
    app['salmon']="$(_koopa_locate_salmon)"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    dict['fasta_file']=''
    dict['n']='1000000'
    dict['threads']="$(_koopa_cpu_count)"
    dict['tmp_dir']="$(_koopa_tmp_dir_in_wd)"
    dict['output_dir']="${dict['tmp_dir']}/quant"
    while (("$#"))
    do
        case "$1" in
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                dict['fasta_file']="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict['fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--fasta-file' "${dict['fasta_file']}"
    _koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['fasta_file']}"
    dict['alignments']="${dict['tmp_dir']}/alignments.sam"
    "${app['samtools']}" view \
            -@ "${dict['threads']}" \
            -h \
            "${dict['bam_file']}" \
        | "${app['head']}" -n "${dict['n']}" \
        > "${dict['alignments']}" \
        || true
    quant_args+=(
        "--alignments=${dict['alignments']}"
        '--libType=A'
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--targets=${dict['fasta_file']}"
        "--threads=${dict['threads']}"
    )
    "${app['salmon']}" quant "${quant_args[@]}" 1>&2
    dict['json_file']="${dict['output_dir']}/aux_info/meta_info.json"
    _koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" \
            --raw-output \
            '.library_types.[]' \
            "${dict['json_file']}" \
    )"
    _koopa_print "${dict['lib_type']}"
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_salmon_detect_fastq_library_type() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['jq']="$(_koopa_locate_jq --allow-system)"
    app['salmon']="$(_koopa_locate_salmon)"
    _koopa_assert_is_executable "${app[@]}"
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['n']='1000000'
    dict['threads']="$(_koopa_cpu_count)"
    dict['tmp_dir']="$(_koopa_tmp_dir_in_wd)"
    dict['output_dir']="${dict['tmp_dir']}/quant"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--index-dir' "${dict['index_dir']}"
    _koopa_assert_is_file "${dict['fastq_r1_file']}"
    _koopa_assert_is_dir "${dict['index_dir']}"
    quant_args+=(
        "--index=${dict['index_dir']}"
        '--libType=A'
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--threads=${dict['threads']}"
    )
    if [[ -n "${dict['fastq_r2_file']}" ]]
    then
        _koopa_assert_is_file "${dict['fastq_r2_file']}"
        dict['mates1']="${dict['tmp_dir']}/mates1.fastq"
        dict['mates2']="${dict['tmp_dir']}/mates2.fastq"
        _koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates1']}"
        _koopa_decompress --stdout "${dict['fastq_r2_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates2']}"
        quant_args+=(
            "--mates1=${dict['mates1']}"
            "--mates2=${dict['mates2']}"
        )
    else
        dict['unmated_reads']="${dict['tmp_dir']}/reads.fastq"
        _koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['unmated_reads']}"
        quant_args+=("--unmatedReads=${dict['unmated_reads']}")
    fi
    "${app['salmon']}" quant "${quant_args[@]}" 1>&2
    dict['json_file']="${dict['output_dir']}/lib_format_counts.json"
    _koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" --raw-output '.expected_format' "${dict['json_file']}" \
    )"
    _koopa_print "${dict['lib_type']}"
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_salmon_index() {
    local -A app bool dict
    local -a index_args
    _koopa_assert_has_args "$#"
    app['salmon']="$(_koopa_locate_salmon)"
    _koopa_assert_is_executable "${app[@]}"
    bool['decoys']=1
    bool['gencode']=0
    dict['fasta_pattern']="$(_koopa_fasta_pattern)"
    dict['genome_fasta_file']=''
    dict['kmer_length']=31
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    dict['type']='puff'
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--decoys')
                bool['decoys']=1
                shift 1
                ;;
            '--gencode')
                bool['gencode']=1
                shift 1
                ;;
            '--no-decoys')
                bool['decoys']=0
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    [[ "${dict['decoys']}" -eq 1 ]] && dict['mem_gb_cutoff']=30
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "salmon index requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    _koopa_assert_is_matching_regex \
        --pattern="${dict['fasta_pattern']}" \
        --string="${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating salmon index at '${dict['output_dir']}'."
    if [[ "${bool['gencode']}" -eq 0 ]] && \
        _koopa_str_detect_regex \
            --string="$(_koopa_basename "${dict['transcriptome_fasta_file']}")" \
            --pattern='^gencode\.'
    then
        bool['gencode']=1
    fi
    if [[ "${bool['gencode']}" -eq 1 ]]
    then
        _koopa_alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${bool['decoys']}" -eq 1 ]]
    then
        _koopa_alert 'Preparing decoy-aware reference transcriptome.'
        _koopa_assert_is_set \
            '--genome-fasta-file' "${dict['genome_fasta_file']}"
        _koopa_assert_is_file "${dict['genome_fasta_file']}"
        dict['genome_fasta_file']="$( \
            _koopa_realpath "${dict['genome_fasta_file']}" \
        )"
        _koopa_assert_is_matching_regex \
            --pattern="${dict['fasta_pattern']}" \
            --string="${dict['genome_fasta_file']}"
        _koopa_assert_is_matching_regex \
            --pattern="${dict['fasta_pattern']}" \
            --string="${dict['transcriptome_fasta_file']}"
        dict['decoys_file']="$(_koopa_tmp_file_in_wd)"
        dict['gentrome_fasta_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_fasta_generate_chromosomes_file \
            --genome-fasta-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['decoys_file']}"
        _koopa_assert_is_file "${dict['decoys_file']}"
        _koopa_fasta_generate_decoy_transcriptome_file \
            --genome-fasta-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['gentrome_fasta_file']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
        _koopa_assert_is_file "${dict['gentrome_fasta_file']}"
        index_args+=(
            "--decoys=${dict['decoys_file']}"
            "--transcripts=${dict['gentrome_fasta_file']}"
        )
    else
        index_args+=(
            "--transcripts=${dict['transcriptome_fasta_file']}"
        )
    fi
    index_args+=(
        "--index=${dict['output_dir']}"
        "--kmerLen=${dict['kmer_length']}"
        '--no-version-check'
        "--threads=${dict['threads']}"
        "--type=${dict['type']}"
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['salmon']}" index "${index_args[@]}"
    if [[ "${bool['decoys']}" -eq 1 ]]
    then
        _koopa_rm \
            "${dict['decoys_file']}" \
            "${dict['gentrome_fasta_file']}"
    fi
    _koopa_alert_success "salmon index created at '${dict['output_dir']}'."
    return 0
}

_koopa_salmon_library_type_to_hisat2() {
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'U')
            return 0
            ;;
        'ISF')
            to='FR'
            ;;
        'ISR')
            to='RF'
            ;;
        'SF')
            to='F'
            ;;
        'SR')
            to='R'
            ;;
        *)
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}

_koopa_salmon_library_type_to_kallisto() {
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            return 0
            ;;
        'ISF')
            to='--fr-stranded'
            ;;
        'ISR')
            to='--rf-stranded'
            ;;
        *)
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}

_koopa_salmon_library_type_to_miso() {
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            to='fr-unstranded'
            ;;
        'ISF')
            to='fr-secondstrand'
            ;;
        'ISR')
            to='fr-firststrand'
            ;;
        *)
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}

_koopa_salmon_library_type_to_rmats() {
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            to='fr-unstranded'
            ;;
        'ISF')
            to='fr-secondstrand'
            ;;
        'ISR')
            to='fr-firststrand'
            ;;
        *)
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}

_koopa_salmon_library_type_to_rsem() {
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'U')
            to='none'
            ;;
        'ISF')
            to='forward'
            ;;
        'ISR')
            to='reverse'
            ;;
        *)
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}

_koopa_salmon_quant_bam_per_sample() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['salmon']="$(_koopa_locate_salmon)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    dict['bootstraps']=30
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['transcriptome_fasta_file']}"
    dict['bam_file']="$(_koopa_realpath "${dict['bam_file']}")"
    dict['bam_bn']="$(_koopa_basename "${dict['bam_file']}")"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['bam_bn']}' in '${dict['output_dir']}'."
    quant_args+=(
        "--alignments=${dict['bam_file']}"
        "--libType=${dict['lib_type']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        "--targets=${dict['transcriptome_fasta_file']}"
        "--threads=${dict['threads']}"
    )
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

_koopa_salmon_quant_bam() {
    local -A app bool dict
    local -a bam_files
    local bam_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['bam_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--bam-dir='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['bam_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-dir' "${dict['bam_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_dir "${dict['bam_dir']}"
    _koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['bam_dir']="$(_koopa_realpath "${dict['bam_dir']}")"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running salmon quant.'
    _koopa_dl \
        'Transcriptome FASTA' "${dict['transcriptome_fasta_file']}" \
        'BAM dir' "${dict['bam_dir']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t bam_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.bam" \
            --prefix="${dict['bam_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${bam_files[@]:-}"
    then
        _koopa_stop "No BAM files detected in '${dict['bam_dir']}'."
    fi
    _koopa_assert_is_file "${bam_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#bam_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for bam_file in "${bam_files[@]}"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['sample_id']="$(_koopa_basename_sans_ext "${dict2['bam_file']}")"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_salmon_quant_bam_per_sample \
            --bam-file="${dict2['bam_file']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'salmon quant was successful.'
    return 0
}

_koopa_salmon_quant_paired_end_per_sample() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['salmon']="$(_koopa_locate_salmon)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    _koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(_koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(_koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(_koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(_koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    quant_args+=(
        '--gcBias'
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--mates1=${dict['fastq_r1_file']}"
        "--mates2=${dict['fastq_r2_file']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        '--useVBOpt'
    )
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

_koopa_salmon_quant_paired_end() {
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running salmon quant.'
    _koopa_dl \
        'Mode' 'paired-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    _koopa_assert_is_file "${fastq_r1_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement="${dict['fastq_r2_tail']}" \
                "${dict2['fastq_r1_file']}" \
        )"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_r1_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_r1_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_salmon_quant_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'salmon quant was successful.'
    return 0
}

_koopa_salmon_quant_single_end_per_sample() {
    local -A app dict
    local -a quant_args
    _koopa_assert_has_args "$#"
    app['salmon']="$(_koopa_locate_salmon)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        _koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    _koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(_koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(_koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--numBootstraps=${dict['bootstraps']}"
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        "--unmatedReads=${dict['fastq']}"
        '--useVBOpt'
    )
    _koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

_koopa_salmon_quant_single_end() {
    local -A app bool dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running salmon quant.'
    _koopa_dl \
        'Mode' 'single-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${fastq_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    _koopa_assert_is_file "${fastq_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        local -A dict2
        dict2['fastq_file']="$fastq_file"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_salmon_quant_single_end_per_sample \
            --fastq-file="${dict2['fastq_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'salmon quant was successful.'
    return 0
}

_koopa_uninstall_ack() {
    _koopa_uninstall_app \
        --name='ack' \
        "$@"
}

_koopa_uninstall_agat() {
    _koopa_uninstall_app \
        --name='agat' \
        "$@"
}

_koopa_uninstall_air() {
    _koopa_uninstall_app \
        --name='air' \
        "$@"
}

_koopa_uninstall_anaconda() {
    _koopa_uninstall_app \
        --name='anaconda' \
        "$@"
}

_koopa_uninstall_apache_airflow() {
    _koopa_uninstall_app \
        --name='apache-airflow' \
        "$@"
}

_koopa_uninstall_apache_arrow() {
    _koopa_uninstall_app \
        --name='apache-arrow' \
        "$@"
}

_koopa_uninstall_apache_spark() {
    _koopa_uninstall_app \
        --name='apache-spark' \
        "$@"
}

_koopa_uninstall_app() {
    local -A bool dict
    local -a bin_arr man1_arr
    bool['quiet']=0
    bool['unlink_in_bin']=''
    bool['unlink_in_man1']=''
    bool['unlink_in_opt']=''
    bool['verbose']=0
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['mode']='shared'
    dict['name']=''
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['platform']='common'
    dict['prefix']=''
    dict['uninstaller_bn']=''
    dict['uninstaller_fun']='main'
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--uninstaller='*)
                dict['uninstaller_bn']="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict['uninstaller_bn']="${2:?}"
                shift 2
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            '--no-unlink-in-bin')
                bool['unlink_in_bin']=0
                shift 1
                ;;
            '--no-unlink-in-man1')
                bool['unlink_in_man1']=0
                shift 1
                ;;
            '--no-unlink-in-opt')
                bool['unlink_in_opt']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    case "${dict['mode']}" in
        'shared')
            _koopa_assert_is_owner
            [[ -z "${dict['prefix']}" ]] && \
                dict['prefix']="${dict['app_prefix']}/${dict['name']}"
            [[ -z "${bool['unlink_in_bin']}" ]] && bool['unlink_in_bin']=1
            [[ -z "${bool['unlink_in_man1']}" ]] && bool['unlink_in_man1']=1
            [[ -z "${bool['unlink_in_opt']}" ]] && bool['unlink_in_opt']=1
            ;;
        'system')
            _koopa_assert_is_owner
            _koopa_assert_is_admin
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            ;;
        'user')
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]]
    then
        if [[ ! -d "${dict['prefix']}" ]]
        then
            _koopa_alert_is_not_installed "${dict['name']}" "${dict['prefix']}"
            return 0
        fi
        dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
    fi
    [[ -z "${dict['uninstaller_bn']}" ]] && \
        dict['uninstaller_bn']="${dict['name']}"
    dict['uninstaller_file']="$(_koopa_bash_prefix)/include/uninstall/\
${dict['platform']}/${dict['mode']}/${dict['uninstaller_bn']}.sh"
    if [[ -f "${dict['uninstaller_file']}" ]]
    then
        dict['tmp_dir']="$(_koopa_tmp_dir)"
        (
            case "${dict['mode']}" in
                'system')
                    _koopa_add_to_path_end '/usr/sbin' '/sbin'
                    ;;
            esac
            _koopa_cd "${dict['tmp_dir']}"
            source "${dict['uninstaller_file']}"
            _koopa_assert_is_function "${dict['uninstaller_fun']}"
            "${dict['uninstaller_fun']}"
        )
        _koopa_rm "${dict['tmp_dir']}"
    fi
    if [[ -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                _koopa_rm --sudo "${dict['prefix']}"
                ;;
            *)
                _koopa_rm "${dict['prefix']}"
                ;;
        esac
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['unlink_in_opt']}" -eq 1 ]]
            then
                _koopa_unlink_in_opt "${dict['name']}"
            fi
            if [[ "${bool['unlink_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    _koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    _koopa_unlink_in_bin "${bin_arr[@]}"
                fi
            fi
            if [[ "${bool['unlink_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    _koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    _koopa_unlink_in_man1 "${man1_arr[@]}"
                fi
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
    fi
    return 0
}

_koopa_uninstall_apr_util() {
    _koopa_uninstall_app \
        --name='apr-util' \
        "$@"
}

_koopa_uninstall_apr() {
    _koopa_uninstall_app \
        --name='apr' \
        "$@"
}

_koopa_uninstall_aria2() {
    _koopa_uninstall_app \
        --name='aria2' \
        "$@"
}

_koopa_uninstall_armadillo() {
    _koopa_uninstall_app \
        --name='armadillo' \
        "$@"
}

_koopa_uninstall_asdf() {
    _koopa_uninstall_app \
        --name='asdf' \
        "$@"
}

_koopa_uninstall_aspell() {
    _koopa_uninstall_app \
        --name='aspell' \
        "$@"
}

_koopa_uninstall_autoconf() {
    _koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

_koopa_uninstall_autodock_adfr() {
    _koopa_uninstall_app \
        --name='autodock-adfr' \
        "$@"
}

_koopa_uninstall_autodock_vina() {
    _koopa_uninstall_app \
        --name='autodock-vina' \
        "$@"
}

_koopa_uninstall_autodock() {
    _koopa_uninstall_app \
        --name='autodock' \
        "$@"
}

_koopa_uninstall_autoflake() {
    _koopa_uninstall_app \
        --name='autoflake' \
        "$@"
}

_koopa_uninstall_automake() {
    _koopa_uninstall_app \
        --name='automake' \
        "$@"
}

_koopa_uninstall_aws_azure_login() {
    _koopa_uninstall_app \
        --name='aws-azure-login' \
        "$@"
}

_koopa_uninstall_aws_cli() {
    _koopa_uninstall_app \
        --name='aws-cli' \
        "$@"
}

_koopa_uninstall_axel() {
    _koopa_uninstall_app \
        --name='axel' \
        "$@"
}

_koopa_uninstall_azure_cli() {
    _koopa_uninstall_app \
        --name='azure-cli' \
        "$@"
}

_koopa_uninstall_bamtools() {
    _koopa_uninstall_app \
        --name='bamtools' \
        "$@"
}

_koopa_uninstall_bandit() {
    _koopa_uninstall_app \
        --name='bandit' \
        "$@"
}

_koopa_uninstall_bandwhich() {
    _koopa_uninstall_app \
        --name='bandwhich' \
        "$@"
}

_koopa_uninstall_bash_completion() {
    _koopa_uninstall_app \
        --name='bash-completion' \
        "$@"
}

_koopa_uninstall_bash_language_server() {
    _koopa_uninstall_app \
        --name='bash-language-server' \
        "$@"
}

_koopa_uninstall_bash() {
    _koopa_uninstall_app \
        --name='bash' \
        "$@"
}

_koopa_uninstall_bashcov() {
    _koopa_uninstall_app \
        --name='bashcov' \
        "$@"
}

_koopa_uninstall_bat() {
    _koopa_uninstall_app \
        --name='bat' \
        "$@"
}

_koopa_uninstall_bc() {
    _koopa_uninstall_app \
        --name='bc' \
        "$@"
}

_koopa_uninstall_bedtools() {
    _koopa_uninstall_app \
        --name='bedtools' \
        "$@"
}

_koopa_uninstall_bfg() {
    _koopa_uninstall_app \
        --name='bfg' \
        "$@"
}

_koopa_uninstall_binutils() {
    _koopa_uninstall_app \
        --name='binutils' \
        "$@"
}

_koopa_uninstall_bioawk() {
    _koopa_uninstall_app \
        --name='bioawk' \
        "$@"
}

_koopa_uninstall_bioconda_utils() {
    _koopa_uninstall_app \
        --name='bioconda-utils' \
        "$@"
}

_koopa_uninstall_bison() {
    _koopa_uninstall_app \
        --name='bison' \
        "$@"
}

_koopa_uninstall_black() {
    _koopa_uninstall_app \
        --name='black' \
        "$@"
}

_koopa_uninstall_blast() {
    _koopa_uninstall_app \
        --name='blast' \
        "$@"
}

_koopa_uninstall_boost() {
    _koopa_uninstall_app \
        --name='boost' \
        "$@"
}

_koopa_uninstall_bottom() {
    _koopa_uninstall_app \
        --name='bottom' \
        "$@"
}

_koopa_uninstall_bowtie2() {
    _koopa_uninstall_app \
        --name='bowtie2' \
        "$@"
}

_koopa_uninstall_bpytop() {
    _koopa_uninstall_app \
        --name='bpytop' \
        "$@"
}

_koopa_uninstall_broot() {
    _koopa_uninstall_app \
        --name='broot' \
        "$@"
}

_koopa_uninstall_brotli() {
    _koopa_uninstall_app \
        --name='brotli' \
        "$@"
}

_koopa_uninstall_btop() {
    _koopa_uninstall_app \
        --name='btop' \
        "$@"
}

_koopa_uninstall_bustools() {
    _koopa_uninstall_app \
        --name='bustools' \
        "$@"
}

_koopa_uninstall_byobu() {
    _koopa_uninstall_app \
        --name='byobu' \
        "$@"
}

_koopa_uninstall_bzip2() {
    _koopa_uninstall_app \
        --name='bzip2' \
        "$@"
}

_koopa_uninstall_c_ares() {
    _koopa_uninstall_app \
        --name='c-ares' \
        "$@"
}

_koopa_uninstall_ca_certificates() {
    _koopa_uninstall_app \
        --name='ca-certificates' \
        "$@"
}

_koopa_uninstall_cairo() {
    _koopa_uninstall_app \
        --name='cairo' \
        "$@"
}

_koopa_uninstall_cereal() {
    _koopa_uninstall_app \
        --name='cereal' \
        "$@"
}

_koopa_uninstall_cheat() {
    _koopa_uninstall_app \
        --name='cheat' \
        "$@"
}

_koopa_uninstall_chemacs() {
    _koopa_uninstall_app \
        --name='chemacs' \
        "$@"
}

_koopa_uninstall_chezmoi() {
    _koopa_uninstall_app \
        --name='chezmoi' \
        "$@"
}

_koopa_uninstall_claude_code() {
    _koopa_uninstall_app \
        --name='claude-code' \
        "$@"
}

_koopa_uninstall_cli11() {
    _koopa_uninstall_app \
        --name='cli11' \
        "$@"
}

_koopa_uninstall_cmake() {
    _koopa_uninstall_app \
        --name='cmake' \
        "$@"
}

_koopa_uninstall_colorls() {
    _koopa_uninstall_app \
        --name='colorls' \
        "$@"
}

_koopa_uninstall_commitizen() {
    _koopa_uninstall_app \
        --name='commitizen' \
        "$@"
}

_koopa_uninstall_conda() {
    _koopa_uninstall_app \
        --name='conda' \
        "$@"
}

_koopa_uninstall_convmv() {
    _koopa_uninstall_app \
        --name='convmv' \
        "$@"
}

_koopa_uninstall_coreutils() {
    _koopa_uninstall_app \
        --name='coreutils' \
        "$@"
}

_koopa_uninstall_cpufetch() {
    _koopa_uninstall_app \
        --name='cpufetch' \
        "$@"
}

_koopa_uninstall_csvkit() {
    _koopa_uninstall_app \
        --name='csvkit' \
        "$@"
}

_koopa_uninstall_csvtk() {
    _koopa_uninstall_app \
        --name='csvtk' \
        "$@"
}

_koopa_uninstall_curl() {
    _koopa_uninstall_app \
        --name='curl' \
        "$@"
}

_koopa_uninstall_dash() {
    _koopa_uninstall_app \
        --name='dash' \
        "$@"
}

_koopa_uninstall_databricks_cli() {
    _koopa_uninstall_app \
        --name='databricks-cli' \
        "$@"
}

_koopa_uninstall_deeptools() {
    _koopa_uninstall_app \
        --name='deeptools' \
        "$@"
}

_koopa_uninstall_delta() {
    _koopa_uninstall_app \
        --name='delta' \
        "$@"
}

_koopa_uninstall_diff_so_fancy() {
    _koopa_uninstall_app \
        --name='diff-so-fancy' \
        "$@"
}

_koopa_uninstall_difftastic() {
    _koopa_uninstall_app \
        --name='difftastic' \
        "$@"
}

_koopa_uninstall_direnv() {
    _koopa_uninstall_app \
        --name='direnv' \
        "$@"
}

_koopa_uninstall_docker_credential_helpers() {
    _koopa_uninstall_app \
        --name='docker-credential-helpers' \
        "$@"
}

_koopa_uninstall_dotfiles() {
    _koopa_uninstall_app \
        --name='dotfiles' \
        "$@"
}

_koopa_uninstall_du_dust() {
    _koopa_uninstall_app \
        --name='du-dust' \
        "$@"
}

_koopa_uninstall_duckdb() {
    _koopa_uninstall_app \
        --name='duckdb' \
        "$@"
}

_koopa_uninstall_ed() {
    _koopa_uninstall_app \
        --name='ed' \
        "$@"
}

_koopa_uninstall_editorconfig() {
    _koopa_uninstall_app \
        --name='editorconfig' \
        "$@"
}

_koopa_uninstall_emacs() {
    _koopa_uninstall_app \
        --name='emacs' \
        "$@"
}

_koopa_uninstall_ensembl_perl_api() {
    _koopa_uninstall_app \
        --name='ensembl-perl-api' \
        "$@"
}

_koopa_uninstall_entrez_direct() {
    _koopa_uninstall_app \
        --name='entrez-direct' \
        "$@"
}

_koopa_uninstall_exa() {
    _koopa_uninstall_app \
        --name='exa' \
        "$@"
}

_koopa_uninstall_exiftool() {
    _koopa_uninstall_app \
        --name='exiftool' \
        "$@"
}

_koopa_uninstall_expat() {
    _koopa_uninstall_app \
        --name='expat' \
        "$@"
}

_koopa_uninstall_eza() {
    _koopa_uninstall_app \
        --name='eza' \
        "$@"
}

_koopa_uninstall_fastqc() {
    _koopa_uninstall_app \
        --name='fastqc' \
        "$@"
}

_koopa_uninstall_fd_find() {
    _koopa_uninstall_app \
        --name='fd-find' \
        "$@"
}

_koopa_uninstall_ffmpeg() {
    _koopa_uninstall_app \
        --name='ffmpeg' \
        "$@"
}

_koopa_uninstall_ffq() {
    _koopa_uninstall_app \
        --name='ffq' \
        "$@"
}

_koopa_uninstall_fgbio() {
    _koopa_uninstall_app \
        --name='fgbio' \
        "$@"
}

_koopa_uninstall_findutils() {
    _koopa_uninstall_app \
        --name='findutils' \
        "$@"
}

_koopa_uninstall_fish() {
    _koopa_uninstall_app \
        --name='fish' \
        "$@"
}

_koopa_uninstall_flac() {
    _koopa_uninstall_app \
        --name='flac' \
        "$@"
}

_koopa_uninstall_flake8() {
    _koopa_uninstall_app \
        --name='flake8' \
        "$@"
}

_koopa_uninstall_flex() {
    _koopa_uninstall_app \
        --name='flex' \
        "$@"
}

_koopa_uninstall_fltk() {
    _koopa_uninstall_app \
        --name='fltk' \
        "$@"
}

_koopa_uninstall_fmt() {
    _koopa_uninstall_app \
        --name='fmt' \
        "$@"
}

_koopa_uninstall_fontconfig() {
    _koopa_uninstall_app \
        --name='fontconfig' \
        "$@"
}

_koopa_uninstall_fq() {
    _koopa_uninstall_app \
        --name='fq' \
        "$@"
}

_koopa_uninstall_fqtk() {
    _koopa_uninstall_app \
        --name='fqtk' \
        "$@"
}

_koopa_uninstall_freetype() {
    _koopa_uninstall_app \
        --name='freetype' \
        "$@"
}

_koopa_uninstall_fribidi() {
    _koopa_uninstall_app \
        --name='fribidi' \
        "$@"
}

_koopa_uninstall_fzf() {
    _koopa_uninstall_app \
        --name='fzf' \
        "$@"
}

_koopa_uninstall_gatk() {
    _koopa_uninstall_app \
        --name='gatk' \
        "$@"
}

_koopa_uninstall_gawk() {
    _koopa_uninstall_app \
        --name='gawk' \
        "$@"
}

_koopa_uninstall_gdal() {
    _koopa_uninstall_app \
        --name='gdal' \
        "$@"
}

_koopa_uninstall_gdbm() {
    _koopa_uninstall_app \
        --name='gdbm' \
        "$@"
}

_koopa_uninstall_gdc_client() {
    _koopa_uninstall_app \
        --name='gdc-client' \
        "$@"
}

_koopa_uninstall_gemini_cli() {
    _koopa_uninstall_app \
        --name='gemini-cli' \
        "$@"
}

_koopa_uninstall_genomepy() {
    _koopa_uninstall_app \
        --name='genomepy' \
        "$@"
}

_koopa_uninstall_gentropy() {
    _koopa_uninstall_app \
        --name='gentropy' \
        "$@"
}

_koopa_uninstall_geos() {
    _koopa_uninstall_app \
        --name='geos' \
        "$@"
}

_koopa_uninstall_gettext() {
    _koopa_uninstall_app \
        --name='gettext' \
        "$@"
}

_koopa_uninstall_gffutils() {
    _koopa_uninstall_app \
        --name='gffutils' \
        "$@"
}

_koopa_uninstall_gget() {
    _koopa_uninstall_app \
        --name='gget' \
        "$@"
}

_koopa_uninstall_gh() {
    _koopa_uninstall_app \
        --name='gh' \
        "$@"
}

_koopa_uninstall_ghostscript() {
    _koopa_uninstall_app \
        --name='ghostscript' \
        "$@"
}

_koopa_uninstall_git_filter_repo() {
    _koopa_uninstall_app \
        --name='git-filter-repo' \
        "$@"
}

_koopa_uninstall_git_lfs() {
    _koopa_uninstall_app \
        --name='git-lfs' \
        "$@"
}

_koopa_uninstall_git() {
    _koopa_uninstall_app \
        --name='git' \
        "$@"
}

_koopa_uninstall_gitui() {
    _koopa_uninstall_app \
        --name='gitui' \
        "$@"
}

_koopa_uninstall_glances() {
    _koopa_uninstall_app \
        --name='glances' \
        "$@"
}

_koopa_uninstall_glib() {
    _koopa_uninstall_app \
        --name='glib' \
        "$@"
}

_koopa_uninstall_gmp() {
    _koopa_uninstall_app \
        --name='gmp' \
        "$@"
}

_koopa_uninstall_gnupg() {
    _koopa_uninstall_app \
        --name='gnupg' \
        "$@"
}

_koopa_uninstall_gnutls() {
    _koopa_uninstall_app \
        --name='gnutls' \
        "$@"
}

_koopa_uninstall_go() {
    _koopa_uninstall_app \
        --name='go' \
        "$@"
}

_koopa_uninstall_google_cloud_sdk() {
    _koopa_uninstall_app \
        --name='google-cloud-sdk' \
        "$@"
}

_koopa_uninstall_googletest() {
    _koopa_uninstall_app \
        --name='googletest' \
        "$@"
}

_koopa_uninstall_gperf() {
    _koopa_uninstall_app \
        --name='gperf' \
        "$@"
}

_koopa_uninstall_graphviz() {
    _koopa_uninstall_app \
        --name='graphviz' \
        "$@"
}

_koopa_uninstall_grep() {
    _koopa_uninstall_app \
        --name='grep' \
        "$@"
}

_koopa_uninstall_grex() {
    _koopa_uninstall_app \
        --name='grex' \
        "$@"
}

_koopa_uninstall_groff() {
    _koopa_uninstall_app \
        --name='groff' \
        "$@"
}

_koopa_uninstall_gseapy() {
    _koopa_uninstall_app \
        --name='gseapy' \
        "$@"
}

_koopa_uninstall_gsl() {
    _koopa_uninstall_app \
        --name='gsl' \
        "$@"
}

_koopa_uninstall_gtop() {
    _koopa_uninstall_app \
        --name='gtop' \
        "$@"
}

_koopa_uninstall_gum() {
    _koopa_uninstall_app \
        --name='gum' \
        "$@"
}

_koopa_uninstall_gzip() {
    _koopa_uninstall_app \
        --name='gzip' \
        "$@"
}

_koopa_uninstall_hadolint() {
    _koopa_uninstall_app \
        --name='hadolint' \
        "$@"
}

_koopa_uninstall_harfbuzz() {
    _koopa_uninstall_app \
        --name='harfbuzz' \
        "$@"
}

_koopa_uninstall_haskell_cabal() {
    _koopa_uninstall_app \
        --name='haskell-cabal' \
        "$@"
}

_koopa_uninstall_haskell_ghcup() {
    _koopa_uninstall_app \
        --name='haskell-ghcup' \
        "$@"
}

_koopa_uninstall_haskell_stack() {
    _koopa_uninstall_app \
        --name='haskell-stack' \
        "$@"
}

_koopa_uninstall_hdf5() {
    _koopa_uninstall_app \
        --name='hdf5' \
        "$@"
}

_koopa_uninstall_hexyl() {
    _koopa_uninstall_app \
        --name='hexyl' \
        "$@"
}

_koopa_uninstall_hisat2() {
    _koopa_uninstall_app \
        --name='hisat2' \
        "$@"
}

_koopa_uninstall_htop() {
    _koopa_uninstall_app \
        --name='htop' \
        "$@"
}

_koopa_uninstall_htseq() {
    _koopa_uninstall_app \
        --name='htseq' \
        "$@"
}

_koopa_uninstall_htslib() {
    _koopa_uninstall_app \
        --name='htslib' \
        "$@"
}

_koopa_uninstall_httpie() {
    _koopa_uninstall_app \
        --name='httpie' \
        "$@"
}

_koopa_uninstall_httpx() {
    _koopa_uninstall_app \
        --name='httpx' \
        "$@"
}

_koopa_uninstall_huggingface_hub() {
    _koopa_uninstall_app \
        --name='huggingface-hub' \
        "$@"
}

_koopa_uninstall_hugo() {
    _koopa_uninstall_app \
        --name='hugo' \
        "$@"
}

_koopa_uninstall_hyperfine() {
    _koopa_uninstall_app \
        --name='hyperfine' \
        "$@"
}

_koopa_uninstall_icu4c() {
    _koopa_uninstall_app \
        --name='icu4c' \
        "$@"
}

_koopa_uninstall_illumina_ica_cli() {
    _koopa_uninstall_app \
        --name='illumina-ica-cli' \
        "$@"
}

_koopa_uninstall_imagemagick() {
    _koopa_uninstall_app \
        --name='imagemagick' \
        "$@"
}

_koopa_uninstall_ipython() {
    _koopa_uninstall_app \
        --name='ipython' \
        "$@"
}

_koopa_uninstall_isl() {
    _koopa_uninstall_app \
        --name='isl' \
        "$@"
}

_koopa_uninstall_isort() {
    _koopa_uninstall_app \
        --name='isort' \
        "$@"
}

_koopa_uninstall_jemalloc() {
    _koopa_uninstall_app \
        --name='jemalloc' \
        "$@"
}

_koopa_uninstall_jfrog_cli() {
    _koopa_uninstall_app \
        --name='jfrog-cli' \
        "$@"
}

_koopa_uninstall_jless() {
    _koopa_uninstall_app \
        --name='jless' \
        "$@"
}

_koopa_uninstall_jpeg() {
    _koopa_uninstall_app \
        --name='jpeg' \
        "$@"
}

_koopa_uninstall_jq() {
    _koopa_uninstall_app \
        --name='jq' \
        "$@"
}

_koopa_uninstall_julia() {
    _koopa_uninstall_app \
        --name='julia' \
        "$@"
}

_koopa_uninstall_jupyterlab() {
    _koopa_uninstall_app \
        --name='jupyterlab' \
        "$@"
}

_koopa_uninstall_k9s() {
    _koopa_uninstall_app \
        --name='k9s' \
        "$@"
}

_koopa_uninstall_kallisto() {
    _koopa_uninstall_app \
        --name='kallisto' \
        "$@"
}

_koopa_uninstall_koopa() {
    local -A bool dict
    bool['uninstall_koopa']=1
    dict['bootstrap_prefix']="$(_koopa_bootstrap_prefix)"
    dict['config_prefix']="$(_koopa_config_prefix)"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    if _koopa_is_interactive
    then
        bool['uninstall_koopa']="$( \
            _koopa_read_yn \
                'Proceed with koopa uninstall' \
                "${bool['uninstall_koopa']}" \
        )"
    fi
    [[ "${bool['uninstall_koopa']}" -eq 0 ]] && return 1
    _koopa_rm --verbose \
        "${dict['bootstrap_prefix']}" \
        "${dict['config_prefix']}"
    if _koopa_is_shared_install && _koopa_is_admin
    then
        if _koopa_is_linux
        then
            dict['profile_d_file']="$(_koopa_linux_profile_d_file)"
            _koopa_rm --sudo --verbose "${dict['profile_d_file']}"
        fi
        _koopa_rm --sudo --verbose "${dict['_koopa_prefix']}"
    else
        _koopa_rm --verbose "${dict['_koopa_prefix']}"
    fi
    return 0
}

_koopa_uninstall_krb5() {
    _koopa_uninstall_app \
        --name='krb5' \
        "$@"
}

_koopa_uninstall_ksh93() {
    _koopa_uninstall_app \
        --name='ksh93' \
        "$@"
}

_koopa_uninstall_lame() {
    _koopa_uninstall_app \
        --name='lame' \
        "$@"
}

_koopa_uninstall_lapack() {
    _koopa_uninstall_app \
        --name='lapack' \
        "$@"
}

_koopa_uninstall_latch() {
    _koopa_uninstall_app \
        --name='latch' \
        "$@"
}

_koopa_uninstall_ldc() {
    _koopa_uninstall_app \
        --name='ldc' \
        "$@"
}

_koopa_uninstall_ldns() {
    _koopa_uninstall_app \
        --name='ldns' \
        "$@"
}

_koopa_uninstall_less() {
    _koopa_uninstall_app \
        --name='less' \
        "$@"
}

_koopa_uninstall_lesspipe() {
    _koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

_koopa_uninstall_libaec() {
    _koopa_uninstall_app \
        --name='libaec' \
        "$@"
}

_koopa_uninstall_libarchive() {
    _koopa_uninstall_app \
        --name='libarchive' \
        "$@"
}

_koopa_uninstall_libassuan() {
    _koopa_uninstall_app \
        --name='libassuan' \
        "$@"
}

_koopa_uninstall_libcbor() {
    _koopa_uninstall_app \
        --name='libcbor' \
        "$@"
}

_koopa_uninstall_libconfig() {
    _koopa_uninstall_app \
        --name='libconfig' \
        "$@"
}

_koopa_uninstall_libde265() {
    _koopa_uninstall_app \
        --name='libde265' \
        "$@"
}

_koopa_uninstall_libdeflate() {
    _koopa_uninstall_app \
        --name='libdeflate' \
        "$@"
}

_koopa_uninstall_libedit() {
    _koopa_uninstall_app \
        --name='libedit' \
        "$@"
}

_koopa_uninstall_libev() {
    _koopa_uninstall_app \
        --name='libev' \
        "$@"
}

_koopa_uninstall_libevent() {
    _koopa_uninstall_app \
        --name='libevent' \
        "$@"
}

_koopa_uninstall_libffi() {
    _koopa_uninstall_app \
        --name='libffi' \
        "$@"
}

_koopa_uninstall_libfido2() {
    _koopa_uninstall_app \
        --name='libfido2' \
        "$@"
}

_koopa_uninstall_libgcrypt() {
    _koopa_uninstall_app \
        --name='libgcrypt' \
        "$@"
}

_koopa_uninstall_libgeotiff() {
    _koopa_uninstall_app \
        --name='libgeotiff' \
        "$@"
}

_koopa_uninstall_libgit2() {
    _koopa_uninstall_app \
        --name='libgit2' \
        "$@"
}

_koopa_uninstall_libgpg_error() {
    _koopa_uninstall_app \
        --name='libgpg-error' \
        "$@"
}

_koopa_uninstall_libheif() {
    _koopa_uninstall_app \
        --name='libheif' \
        "$@"
}

_koopa_uninstall_libiconv() {
    _koopa_uninstall_app \
        --name='libiconv' \
        "$@"
}

_koopa_uninstall_libidn() {
    _koopa_uninstall_app \
        --name='libidn' \
        "$@"
}

_koopa_uninstall_libjpeg_turbo() {
    _koopa_uninstall_app \
        --name='libjpeg-turbo' \
        "$@"
}

_koopa_uninstall_libksba() {
    _koopa_uninstall_app \
        --name='libksba' \
        "$@"
}

_koopa_uninstall_liblinear() {
    _koopa_uninstall_app \
        --name='liblinear' \
        "$@"
}

_koopa_uninstall_libluv() {
    _koopa_uninstall_app \
        --name='libluv' \
        "$@"
}

_koopa_uninstall_liblinear() {
    _koopa_uninstall_app \
        --name='liblinear' \
        "$@"
}

_koopa_uninstall_libpipeline() {
    _koopa_uninstall_app \
        --name='libpipeline' \
        "$@"
}

_koopa_uninstall_libpng() {
    _koopa_uninstall_app \
        --name='libpng' \
        "$@"
}

_koopa_uninstall_libsolv() {
    _koopa_uninstall_app \
        --name='libsolv' \
        "$@"
}

_koopa_uninstall_libssh2() {
    _koopa_uninstall_app \
        --name='libssh2' \
        "$@"
}

_koopa_uninstall_libtasn1() {
    _koopa_uninstall_app \
        --name='libtasn1' \
        "$@"
}

_koopa_uninstall_libtermkey() {
    _koopa_uninstall_app \
        --name='libtermkey' \
        "$@"
}

_koopa_uninstall_libtiff() {
    _koopa_uninstall_app \
        --name='libtiff' \
        "$@"
}

_koopa_uninstall_libtool() {
    _koopa_uninstall_app \
        --name='libtool' \
        "$@"
}

_koopa_uninstall_libunistring() {
    _koopa_uninstall_app \
        --name='libunistring' \
        "$@"
}

_koopa_uninstall_libuv() {
    _koopa_uninstall_app \
        --name='libuv' \
        "$@"
}

_koopa_uninstall_libvterm() {
    _koopa_uninstall_app \
        --name='libvterm' \
        "$@"
}

_koopa_uninstall_libxcrypt() {
    _koopa_uninstall_app \
        --name='libxcrypt' \
        "$@"
}

_koopa_uninstall_libxml2() {
    _koopa_uninstall_app \
        --name='libxml2' \
        "$@"
}

_koopa_uninstall_libxslt() {
    _koopa_uninstall_app \
        --name='libxslt' \
        "$@"
}

_koopa_uninstall_libyaml() {
    _koopa_uninstall_app \
        --name='libyaml' \
        "$@"
}

_koopa_uninstall_libzip() {
    _koopa_uninstall_app \
        --name='libzip' \
        "$@"
}

_koopa_uninstall_llama() {
    _koopa_uninstall_app \
        --name='llama' \
        "$@"
}

_koopa_uninstall_llvm() {
    _koopa_uninstall_app \
        --name='llvm' \
        "$@"
}

_koopa_uninstall_lsd() {
    _koopa_uninstall_app \
        --name='lsd' \
        "$@"
}

_koopa_uninstall_lua() {
    _koopa_uninstall_app \
        --name='lua' \
        "$@"
}

_koopa_uninstall_luajit() {
    _koopa_uninstall_app \
        --name='luajit' \
        "$@"
}

_koopa_uninstall_luarocks() {
    _koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

_koopa_uninstall_luigi() {
    _koopa_uninstall_app \
        --name='luigi' \
        "$@"
}

_koopa_uninstall_lz4() {
    _koopa_uninstall_app \
        --name='lz4' \
        "$@"
}

_koopa_uninstall_lzip() {
    _koopa_uninstall_app \
        --name='lzip' \
        "$@"
}

_koopa_uninstall_lzo() {
    _koopa_uninstall_app \
        --name='lzo' \
        "$@"
}

_koopa_uninstall_m4() {
    _koopa_uninstall_app \
        --name='m4' \
        "$@"
}

_koopa_uninstall_make() {
    _koopa_uninstall_app \
        --name='make' \
        "$@"
}

_koopa_uninstall_mamba() {
    _koopa_uninstall_app \
        --name='mamba' \
        "$@"
}

_koopa_uninstall_man_db() {
    _koopa_uninstall_app \
        --name='man-db' \
        "$@"
}

_koopa_uninstall_marimo() {
    _koopa_uninstall_app \
        --name='marimo' \
        "$@"
}

_koopa_uninstall_markdownlint_cli() {
    _koopa_uninstall_app \
        --name='markdownlint-cli' \
        "$@"
}

_koopa_uninstall_mcfly() {
    _koopa_uninstall_app \
        --name='mcfly' \
        "$@"
}

_koopa_uninstall_mdcat() {
    _koopa_uninstall_app \
        --name='mdcat' \
        "$@"
}

_koopa_uninstall_meson() {
    _koopa_uninstall_app \
        --name='meson' \
        "$@"
}

_koopa_uninstall_miller() {
    _koopa_uninstall_app \
        --name='miller' \
        "$@"
}

_koopa_uninstall_mimalloc() {
    _koopa_uninstall_app \
        --name='mimalloc' \
        "$@"
}

_koopa_uninstall_minimap2() {
    _koopa_uninstall_app \
        --name='minimap2' \
        "$@"
}

_koopa_uninstall_misopy() {
    _koopa_uninstall_app \
        --name='misopy' \
        "$@"
}

_koopa_uninstall_mold() {
    _koopa_uninstall_app \
        --name='mold' \
        "$@"
}

_koopa_uninstall_mosaicml_cli() {
    _koopa_uninstall_app \
        --name='mosaicml-cli' \
        "$@"
}

_koopa_uninstall_mpc() {
    _koopa_uninstall_app \
        --name='mpc' \
        "$@"
}

_koopa_uninstall_mpdecimal() {
    _koopa_uninstall_app \
        --name='mpdecimal' \
        "$@"
}

_koopa_uninstall_mpfr() {
    _koopa_uninstall_app \
        --name='mpfr' \
        "$@"
}

_koopa_uninstall_msgpack() {
    _koopa_uninstall_app \
        --name='msgpack' \
        "$@"
}

_koopa_uninstall_multiqc() {
    _koopa_uninstall_app \
        --name='multiqc' \
        "$@"
}

_koopa_uninstall_mutagen() {
    _koopa_uninstall_app \
        --name='mutagen' \
        "$@"
}

_koopa_uninstall_mypy() {
    _koopa_uninstall_app \
        --name='mypy' \
        "$@"
}

_koopa_uninstall_nano() {
    _koopa_uninstall_app \
        --name='nano' \
        "$@"
}

_koopa_uninstall_nanopolish() {
    _koopa_uninstall_app \
        --name='nanopolish' \
        "$@"
}

_koopa_uninstall_ncbi_sra_tools() {
    _koopa_uninstall_app \
        --name='ncbi-sra-tools' \
        "$@"
}

_koopa_uninstall_ncbi_vdb() {
    _koopa_uninstall_app \
        --name='ncbi-vdb' \
        "$@"
}

_koopa_uninstall_ncurses() {
    _koopa_uninstall_app \
        --name='ncurses' \
        "$@"
}

_koopa_uninstall_neofetch() {
    _koopa_uninstall_app \
        --name='neofetch' \
        "$@"
}

_koopa_uninstall_neovim() {
    _koopa_uninstall_app \
        --name='neovim' \
        "$@"
}

_koopa_uninstall_nettle() {
    _koopa_uninstall_app \
        --name='nettle' \
        "$@"
}

_koopa_uninstall_nextflow() {
    _koopa_uninstall_app \
        --name='nextflow' \
        "$@"
}

_koopa_uninstall_nghttp2() {
    _koopa_uninstall_app \
        --name='nghttp2' \
        "$@"
}

_koopa_uninstall_nim() {
    _koopa_uninstall_app \
        --name='nim' \
        "$@"
}

_koopa_uninstall_ninja() {
    _koopa_uninstall_app \
        --name='ninja' \
        "$@"
}

_koopa_uninstall_nlohmann_json() {
    _koopa_uninstall_app \
        --name='nlohmann-json' \
        "$@"
}

_koopa_uninstall_nmap() {
    _koopa_uninstall_app \
        --name='nmap' \
        "$@"
}

_koopa_uninstall_node() {
    _koopa_uninstall_app \
        --name='node' \
        "$@"
}

_koopa_uninstall_npth() {
    _koopa_uninstall_app \
        --name='npth' \
        "$@"
}

_koopa_uninstall_nushell() {
    _koopa_uninstall_app \
        --name='nushell' \
        "$@"
}

_koopa_uninstall_oniguruma() {
    _koopa_uninstall_app \
        --name='oniguruma' \
        "$@"
}

_koopa_uninstall_ont_dorado() {
    _koopa_uninstall_app \
        --name='ont-dorado' \
        "$@"
}

_koopa_uninstall_ont_vbz_compression() {
    _koopa_uninstall_app \
        --name='ont-vbz-compression' \
        "$@"
}

_koopa_uninstall_openbb() {
    _koopa_uninstall_app \
        --name='openbb' \
        "$@"
}

_koopa_uninstall_openblas() {
    _koopa_uninstall_app \
        --name='openblas' \
        "$@"
}

_koopa_uninstall_openjpeg() {
    _koopa_uninstall_app \
        --name='openjpeg' \
        "$@"
}

_koopa_uninstall_openldap() {
    _koopa_uninstall_app \
        --name='openldap' \
        "$@"
}

_koopa_uninstall_openssh() {
    _koopa_uninstall_app \
        --name='openssh' \
        "$@"
}

_koopa_uninstall_openssl() {
    _koopa_uninstall_app \
        --name='openssl' \
        "$@"
}

_koopa_uninstall_openssl3() {
    _koopa_uninstall_app \
        --name='openssl3' \
        "$@"
}

_koopa_uninstall_p7zip() {
    _koopa_uninstall_app \
        --name='p7zip' \
        "$@"
}

_koopa_uninstall_pandoc() {
    _koopa_uninstall_app \
        --name='pandoc' \
        "$@"
}

_koopa_uninstall_parallel() {
    _koopa_uninstall_app \
        --name='parallel' \
        "$@"
}

_koopa_uninstall_password_store() {
    _koopa_uninstall_app \
        --name='password-store' \
        "$@"
}

_koopa_uninstall_patch() {
    _koopa_uninstall_app \
        --name='patch' \
        "$@"
}

_koopa_uninstall_pbzip2() {
    _koopa_uninstall_app \
        --name='pbzip2' \
        "$@"
}

_koopa_uninstall_pcre() {
    _koopa_uninstall_app \
        --name='pcre' \
        "$@"
}

_koopa_uninstall_pcre2() {
    _koopa_uninstall_app \
        --name='pcre2' \
        "$@"
}

_koopa_uninstall_perl() {
    _koopa_uninstall_app \
        --name='perl' \
        "$@"
}

_koopa_uninstall_picard() {
    _koopa_uninstall_app \
        --name='picard' \
        "$@"
}

_koopa_uninstall_pigz() {
    _koopa_uninstall_app \
        --name='pigz' \
        "$@"
}

_koopa_uninstall_pinentry() {
    _koopa_uninstall_app \
        --name='pinentry' \
        "$@"
}

_koopa_uninstall_pipx() {
    _koopa_uninstall_app \
        --name='pipx' \
        "$@"
}

_koopa_uninstall_pixman() {
    _koopa_uninstall_app \
        --name='pixman' \
        "$@"
}

_koopa_uninstall_pkg_config() {
    _koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}

_koopa_uninstall_pkgconf() {
    _koopa_uninstall_app \
        --name='pkgconf' \
        "$@"
}

_koopa_uninstall_poetry() {
    _koopa_uninstall_app \
        --name='poetry' \
        "$@"
}

_koopa_uninstall_postgresql() {
    _koopa_uninstall_app \
        --name='postgresql' \
        "$@"
}

_koopa_uninstall_prettier() {
    _koopa_uninstall_app \
        --name='prettier' \
        "$@"
}

_koopa_uninstall_private_ont_guppy() {
    _koopa_uninstall_app \
        --name='ont-guppy' \
        "$@"
}

_koopa_uninstall_procs() {
    _koopa_uninstall_app \
        --name='procs' \
        "$@"
}

_koopa_uninstall_proj() {
    _koopa_uninstall_app \
        --name='proj' \
        "$@"
}

_koopa_uninstall_pup() {
    _koopa_uninstall_app \
        --name='pup' \
        "$@"
}

_koopa_uninstall_py_spy() {
    _koopa_uninstall_app \
        --name='py_spy' \
        "$@"
}

_koopa_uninstall_pybind11() {
    _koopa_uninstall_app \
        --name='pybind11' \
        "$@"
}

_koopa_uninstall_pycodestyle() {
    _koopa_uninstall_app \
        --name='pycodestyle' \
        "$@"
}

_koopa_uninstall_pyenv() {
    _koopa_uninstall_app \
        --name='pyenv' \
        "$@"
}

_koopa_uninstall_pyflakes() {
    _koopa_uninstall_app \
        --name='pyflakes' \
        "$@"
}

_koopa_uninstall_pygments() {
    _koopa_uninstall_app \
        --name='pygments' \
        "$@"
}

_koopa_uninstall_pylint() {
    _koopa_uninstall_app \
        --name='pylint' \
        "$@"
}

_koopa_uninstall_pymol() {
    _koopa_uninstall_app \
        --name='pymol' \
        "$@"
}

_koopa_uninstall_pyrefly() {
    _koopa_uninstall_app \
        --name='pyrefly' \
        "$@"
}

_koopa_uninstall_pyright() {
    _koopa_uninstall_app \
        --name='pyright' \
        "$@"
}

_koopa_uninstall_pytaglib() {
    _koopa_uninstall_app \
        --name='pytaglib' \
        "$@"
}

_koopa_uninstall_pytest() {
    _koopa_uninstall_app \
        --name='pytest' \
        "$@"
}

_koopa_uninstall_python310() {
    _koopa_uninstall_app \
        --name='python3.10' \
        "$@"
}

_koopa_uninstall_python311() {
    local -A dict
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['bin_prefix']="$(_koopa_bin_prefix)"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    _koopa_uninstall_app \
        --name='python3.11' \
        "$@"
    _koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}

_koopa_uninstall_python312() {
    _koopa_uninstall_app \
        --name='python3.12' \
        "$@"
}

_koopa_uninstall_python313() {
    _koopa_uninstall_app \
        --name='python3.13' \
        "$@"
}

_koopa_uninstall_python314() {
    _koopa_uninstall_app \
        --name='python3.14' \
        "$@"
}

_koopa_uninstall_quarto() {
    _koopa_uninstall_app \
        --name='quarto' \
        "$@"
}

_koopa_uninstall_r_devel() {
    _koopa_uninstall_app \
        --name='r-devel' \
        "$@"
}

_koopa_uninstall_r() {
    _koopa_uninstall_app \
        --name='r' \
        "$@"
}

_koopa_uninstall_radian() {
    _koopa_uninstall_app \
        --name='radian' \
        "$@"
}

_koopa_uninstall_ranger_fm() {
    _koopa_uninstall_app \
        --name='ranger-fm' \
        "$@"
}

_koopa_uninstall_rbenv() {
    _koopa_uninstall_app \
        --name='rbenv' \
        "$@"
}

_koopa_uninstall_rclone() {
    _koopa_uninstall_app \
        --name='rclone' \
        "$@"
}

_koopa_uninstall_readline() {
    _koopa_uninstall_app \
        --name='readline' \
        "$@"
}

_koopa_uninstall_rename() {
    _koopa_uninstall_app \
        --name='rename' \
        "$@"
}

_koopa_uninstall_reproc() {
    _koopa_uninstall_app \
        --name='reproc' \
        "$@"
}

_koopa_uninstall_ripgrep_all() {
    _koopa_uninstall_app \
        --name='ripgrep-all' \
        "$@"
}

_koopa_uninstall_ripgrep() {
    _koopa_uninstall_app \
        --name='ripgrep' \
        "$@"
}

_koopa_uninstall_rmate() {
    _koopa_uninstall_app \
        --name='rmate' \
        "$@"
}

_koopa_uninstall_rmats() {
    _koopa_uninstall_app \
        --name='rmats' \
        "$@"
}

_koopa_uninstall_ronn_ng() {
    _koopa_uninstall_app \
        --name='ronn-ng' \
        "$@"
}

_koopa_uninstall_ronn() {
    _koopa_uninstall_app \
        --name='ronn' \
        "$@"
}

_koopa_uninstall_rsem() {
    _koopa_uninstall_app \
        --name='rsem' \
        "$@"
}

_koopa_uninstall_rsync() {
    _koopa_uninstall_app \
        --name='rsync' \
        "$@"
}

_koopa_uninstall_ruby() {
    _koopa_uninstall_app \
        --name='ruby' \
        "$@"
}

_koopa_uninstall_ruff_lsp() {
    _koopa_uninstall_app \
        --name='ruff-lsp' \
        "$@"
}

_koopa_uninstall_ruff() {
    _koopa_uninstall_app \
        --name='ruff' \
        "$@"
}

_koopa_uninstall_rust() {
    _koopa_uninstall_app \
        --name='rust' \
        "$@"
}

_koopa_uninstall_s5cmd() {
    _koopa_uninstall_app \
        --name='s5cmd' \
        "$@"
}

_koopa_uninstall_salmon() {
    _koopa_uninstall_app \
        --name='salmon' \
        "$@"
}

_koopa_uninstall_sambamba() {
    _koopa_uninstall_app \
        --name='sambamba' \
        "$@"
}

_koopa_uninstall_samtools() {
    _koopa_uninstall_app \
        --name='samtools' \
        "$@"
}

_koopa_uninstall_scalene() {
    _koopa_uninstall_app \
        --name='scalene' \
        "$@"
}

_koopa_uninstall_scanpy() {
    _koopa_uninstall_app \
        --name='scanpy' \
        "$@"
}

_koopa_uninstall_scons() {
    _koopa_uninstall_app \
        --name='scons' \
        "$@"
}

_koopa_uninstall_screen() {
    _koopa_uninstall_app \
        --name='screen' \
        "$@"
}

_koopa_uninstall_sd() {
    _koopa_uninstall_app \
        --name='sd' \
        "$@"
}

_koopa_uninstall_sed() {
    _koopa_uninstall_app \
        --name='sed' \
        "$@"
}

_koopa_uninstall_seqkit() {
    _koopa_uninstall_app \
        --name='seqkit' \
        "$@"
}

_koopa_uninstall_serf() {
    _koopa_uninstall_app \
        --name='serf' \
        "$@"
}

_koopa_uninstall_shellcheck() {
    _koopa_uninstall_app \
        --name='shellcheck' \
        "$@"
}

_koopa_uninstall_shunit2() {
    _koopa_uninstall_app \
        --name='shunit2' \
        "$@"
}

_koopa_uninstall_shyaml() {
    _koopa_uninstall_app \
        --name='shyaml' \
        "$@"
}

_koopa_uninstall_simdjson() {
    _koopa_uninstall_app \
        --name='simdjson' \
        "$@"
}

_koopa_uninstall_snakefmt() {
    _koopa_uninstall_app \
        --name='snakefmt' \
        "$@"
}

_koopa_uninstall_snakemake() {
    _koopa_uninstall_app \
        --name='snakemake' \
        "$@"
}

_koopa_uninstall_sox() {
    _koopa_uninstall_app \
        --name='sox' \
        "$@"
}

_koopa_uninstall_spdlog() {
    _koopa_uninstall_app \
        --name='spdlog' \
        "$@"
}

_koopa_uninstall_sphinx() {
    _koopa_uninstall_app \
        --name='sphinx' \
        "$@"
}

_koopa_uninstall_sqlfluff() {
    _koopa_uninstall_app \
        --name='sqlfluff' \
        "$@"
}

_koopa_uninstall_sqlite() {
    _koopa_uninstall_app \
        --name='sqlite' \
        "$@"
}

_koopa_uninstall_staden_io_lib() {
    _koopa_uninstall_app \
        --name='staden-io-lib' \
        "$@"
}

_koopa_uninstall_star_fusion() {
    _koopa_uninstall_app \
        --name='star-fusion' \
        "$@"
}

_koopa_uninstall_star() {
    _koopa_uninstall_app \
        --name='star' \
        "$@"
}

_koopa_uninstall_starship() {
    _koopa_uninstall_app \
        --name='starship' \
        "$@"
}

_koopa_uninstall_stow() {
    _koopa_uninstall_app \
        --name='stow' \
        "$@"
}

_koopa_uninstall_streamlit() {
    _koopa_uninstall_app \
        --name='streamlit' \
        "$@"
}

_koopa_uninstall_subread() {
    _koopa_uninstall_app \
        --name='subread' \
        "$@"
}

_koopa_uninstall_subversion() {
    _koopa_uninstall_app \
        --name='subversion' \
        "$@"
}

_koopa_uninstall_swig() {
    _koopa_uninstall_app \
        --name='swig' \
        "$@"
}

_koopa_uninstall_system_homebrew() {
    _koopa_uninstall_app \
        --name='homebrew' \
        --system \
        "$@"
}

_koopa_uninstall_taglib() {
    _koopa_uninstall_app \
        --name='taglib' \
        "$@"
}

_koopa_uninstall_tar() {
    _koopa_uninstall_app \
        --name='tar' \
        "$@"
}

_koopa_uninstall_tbb() {
    _koopa_uninstall_app \
        --name='tbb' \
        "$@"
}

_koopa_uninstall_tcl_tk() {
    _koopa_uninstall_app \
        --name='tcl-tk' \
        "$@"
}

_koopa_uninstall_tealdeer() {
    _koopa_uninstall_app \
        --name='tealdeer' \
        "$@"
}

_koopa_uninstall_temurin() {
    _koopa_uninstall_app \
        --name='temurin' \
        "$@"
}

_koopa_uninstall_termcolor() {
    _koopa_uninstall_app \
        --name='termcolor' \
        "$@"
}

_koopa_uninstall_texinfo() {
    _koopa_uninstall_app \
        --name='texinfo' \
        "$@"
}

_koopa_uninstall_tl_expected() {
    _koopa_uninstall_app \
        --name='tl-expected' \
        "$@"
}

_koopa_uninstall_tmux() {
    _koopa_uninstall_app \
        --name='tmux' \
        "$@"
}

_koopa_uninstall_tokei() {
    _koopa_uninstall_app \
        --name='tokei' \
        "$@"
}

_koopa_uninstall_tqdm() {
    _koopa_uninstall_app \
        --name='tqdm' \
        "$@"
}

_koopa_uninstall_tree_sitter() {
    _koopa_uninstall_app \
        --name='tree-sitter' \
        "$@"
}

_koopa_uninstall_tree() {
    _koopa_uninstall_app \
        --name='tree' \
        "$@"
}

_koopa_uninstall_tryceratops() {
    _koopa_uninstall_app \
        --name='tryceratops' \
        "$@"
}

_koopa_uninstall_tuc() {
    _koopa_uninstall_app \
        --name='tuc' \
        "$@"
}

_koopa_uninstall_ty() {
    _koopa_uninstall_app \
        --name='ty' \
        "$@"
}

_koopa_uninstall_udunits() {
    _koopa_uninstall_app \
        --name='udunits' \
        "$@"
}

_koopa_uninstall_umis() {
    _koopa_uninstall_app \
        --name='umis' \
        "$@"
}

_koopa_uninstall_unibilium() {
    _koopa_uninstall_app \
        --name='unibilium' \
        "$@"
}

_koopa_uninstall_units() {
    _koopa_uninstall_app \
        --name='units' \
        "$@"
}

_koopa_uninstall_unzip() {
    _koopa_uninstall_app \
        --name='unzip' \
        "$@"
}

_koopa_uninstall_user_bootstrap() {
    _koopa_uninstall_app \
        --name='bootstrap' \
        --prefix="$(_koopa_bootstrap_prefix)" \
        --user \
        "$@"
}

_koopa_uninstall_user_doom_emacs() {
    _koopa_uninstall_app \
        --name='doom-emacs' \
        --prefix="$(_koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

_koopa_uninstall_user_prelude_emacs() {
    _koopa_uninstall_app \
        --name='prelude-emacs' \
        --prefix="$(_koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

_koopa_uninstall_user_spacemacs() {
    _koopa_uninstall_app \
        --name='spacemacs' \
        --prefix="$(_koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

_koopa_uninstall_user_spacevim() {
    _koopa_uninstall_app \
        --name='spacevim' \
        --prefix="$(_koopa_spacevim_prefix)" \
        --user \
        "$@"
}

_koopa_uninstall_utf8proc() {
    _koopa_uninstall_app \
        --name='utf8proc' \
        "$@"
}

_koopa_uninstall_uv() {
    _koopa_uninstall_app \
        --name='uv' \
        "$@"
}

_koopa_uninstall_vim() {
    _koopa_uninstall_app \
        --name='vim' \
        "$@"
}

_koopa_uninstall_visidata() {
    _koopa_uninstall_app \
        --name='visidata' \
        "$@"
}

_koopa_uninstall_vulture() {
    _koopa_uninstall_app \
        --name='vulture' \
        "$@"
}

_koopa_uninstall_walk() {
    _koopa_uninstall_app \
        --name='walk' \
        "$@"
}

_koopa_uninstall_wget() {
    _koopa_uninstall_app \
        --name='wget' \
        "$@"
}

_koopa_uninstall_wget2() {
    _koopa_uninstall_app \
        --name='wget2' \
        "$@"
}

_koopa_uninstall_which() {
    _koopa_uninstall_app \
        --name='which' \
        "$@"
}

_koopa_uninstall_woff2() {
    _koopa_uninstall_app \
        --name='woff2' \
        "$@"
}

_koopa_uninstall_xorg_libice() {
    _koopa_uninstall_app \
        --name='xorg-libice' \
        "$@"
}

_koopa_uninstall_xorg_libpthread_stubs() {
    _koopa_uninstall_app \
        --name='xorg-libpthread-stubs' \
        "$@"
}

_koopa_uninstall_xorg_libsm() {
    _koopa_uninstall_app \
        --name='xorg-libsm' \
        "$@"
}

_koopa_uninstall_xorg_libx11() {
    _koopa_uninstall_app \
        --name='xorg-libx11' \
        "$@"
}

_koopa_uninstall_xorg_libxau() {
    _koopa_uninstall_app \
        --name='xorg-libxau' \
        "$@"
}

_koopa_uninstall_xorg_libxcb() {
    _koopa_uninstall_app \
        --name='xorg-libxcb' \
        "$@"
}

_koopa_uninstall_xorg_libxdmcp() {
    _koopa_uninstall_app \
        --name='xorg-libxdmcp' \
        "$@"
}

_koopa_uninstall_xorg_libxext() {
    _koopa_uninstall_app \
        --name='xorg-libxext' \
        "$@"
}

_koopa_uninstall_xorg_libxrandr() {
    _koopa_uninstall_app \
        --name='xorg-libxrandr' \
        "$@"
}

_koopa_uninstall_xorg_libxrender() {
    _koopa_uninstall_app \
        --name='xorg-libxrender' \
        "$@"
}

_koopa_uninstall_xorg_libxt() {
    _koopa_uninstall_app \
        --name='xorg-libxt' \
        "$@"
}

_koopa_uninstall_xorg_xcb_proto() {
    _koopa_uninstall_app \
        --name='xorg-xcb-proto' \
        "$@"
}

_koopa_uninstall_xorg_xorgproto() {
    _koopa_uninstall_app \
        --name='xorg-xorgproto' \
        "$@"
}

_koopa_uninstall_xorg_xtrans() {
    _koopa_uninstall_app \
        --name='xorg-xtrans' \
        "$@"
}

_koopa_uninstall_xsra() {
    _koopa_uninstall_app \
        --name='xsra' \
        "$@"
}

_koopa_uninstall_xsv() {
    _koopa_uninstall_app \
        --name='xsv' \
        "$@"
}

_koopa_uninstall_xxhash() {
    _koopa_uninstall_app \
        --name='xxhash' \
        "$@"
}

_koopa_uninstall_xz() {
    _koopa_uninstall_app \
        --name='xz' \
        "$@"
}

_koopa_uninstall_yaml_cpp() {
    _koopa_uninstall_app \
        --name='yaml-cpp' \
        "$@"
}

_koopa_uninstall_yamllint() {
    _koopa_uninstall_app \
        --name='yamllint' \
        "$@"
}

_koopa_uninstall_yapf() {
    _koopa_uninstall_app \
        --name='yapf' \
        "$@"
}

_koopa_uninstall_yq() {
    _koopa_uninstall_app \
        --name='yq' \
        "$@"
}

_koopa_uninstall_yt_dlp() {
    _koopa_uninstall_app \
        --name='yt-dlp' \
        "$@"
}

_koopa_uninstall_zellij() {
    _koopa_uninstall_app \
        --name='zellij' \
        "$@"
}

_koopa_uninstall_zenith() {
    _koopa_uninstall_app \
        --name='zenith' \
        "$@"
}

_koopa_uninstall_zip() {
    _koopa_uninstall_app \
        --name='zip' \
        "$@"
}

_koopa_uninstall_zlib() {
    _koopa_uninstall_app \
        --name='zlib' \
        "$@"
}

_koopa_uninstall_zopfli() {
    _koopa_uninstall_app \
        --name='zopfli' \
        "$@"
}

_koopa_uninstall_zoxide() {
    _koopa_uninstall_app \
        --name='zoxide' \
        "$@"
}

_koopa_uninstall_zsh() {
    _koopa_uninstall_app \
        --name='zsh' \
        "$@"
}

_koopa_uninstall_zstd() {
    _koopa_uninstall_app \
        --name='zstd' \
        "$@"
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

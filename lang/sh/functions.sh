#!/bin/sh
# shellcheck disable=all

_koopa_activate_alacritty() {
    # """
    # Activate Alacritty terminal client.
    # @note Updated 2024-01-02.
    #
    # This function dynamically updates dark/light color mode.
    #
    # @seealso
    # - Live config reload doesn't detect symlink change.
    #   https://github.com/alacritty/alacritty/issues/2237
    # """
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
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2025-04-27.
    # """
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
    alias realcd='_koopa_alias_realcd'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias venv='_koopa_alias_venv'
    alias week='_koopa_alias_week'
    # Application aliases ------------------------------------------------------
    # asdf.
    if [ -x "${__kvar_bin_prefix}/asdf" ]
    then
        alias asdf='_koopa_activate_asdf; asdf'
    fi
    # black.
    if [ -x "${__kvar_bin_prefix}/black" ]
    then
        alias black='black --line-length=79'
    fi
    # broot.
    if [ -x "${__kvar_bin_prefix}/broot" ]
    then
        alias br='_koopa_activate_broot; br'
        alias br-size='br --sort-by-size'
    fi
    # chezmoi.
    if [ -x "${__kvar_bin_prefix}/chezmoi" ]
    then
        alias cm='chezmoi'
    fi
    # colorls.
    if [ -x "${__kvar_bin_prefix}/colorls" ]
    then
        alias cls='_koopa_alias_colorls'
    fi
    # conda.
    if [ -x "${__kvar_bin_prefix}/conda" ]
    then
        alias conda='_koopa_activate_conda; conda'
    fi
    # emacs.
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
    # fd-find.
    if [ -x "${__kvar_bin_prefix}/fd" ]
    then
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    fi
    # glances.
    if [ -x "${__kvar_bin_prefix}/glances" ]
    then
        alias glances='_koopa_alias_glances'
    fi
    # neovim.
    if [ -x "${__kvar_bin_prefix}/nvim" ]
    then
        alias nvim-vanilla='_koopa_alias_nvim_vanilla'
        if [ -x "${__kvar_bin_prefix}/fzf" ]
        then
            alias nvim-fzf='_koopa_alias_nvim_fzf'
        fi
    fi
    # pyenv.
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias pyenv='_koopa_activate_pyenv; pyenv'
    fi
    # python.
    if [ -x "${__kvar_bin_prefix}/python3" ]
    then
        alias python3-dev='PYTHONPATH="$(pwd)" python3'
    fi
    # r.
    if [ -x '/usr/local/bin/R' ] || [ -x '/usr/bin/R' ]
    then
        alias R='R --no-restore --no-save --quiet'
    fi
    # radian.
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias radian='radian --no-restore --no-save --quiet'
    fi
    # rbenv.
    if [ -x "${__kvar_bin_prefix}/rbenv" ]
    then
        alias rbenv='_koopa_activate_rbenv; rbenv'
    fi
    # shasum.
    if [ -x '/usr/bin/shasum' ]
    then
        alias sha256='shasum -a 256'
    fi
    # tmux.
    if [ -x "${__kvar_bin_prefix}/tmux" ]
    then
        alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    fi
    # vim.
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
    # walk.
    if [ -x "${__kvar_bin_prefix}/walk" ]
    then
        alias lk='_koopa_walk'
    fi
    # zoxide.
    if [ -x "${__kvar_bin_prefix}/zoxide" ]
    then
        alias z='_koopa_activate_zoxide; __zoxide_z'
        # Keep our legacy 'j' binding to mimic autojump.
        alias j='z'
    fi
    # User-defined aliases -----------------------------------------------------
    # Keep these at the end to allow the user to override our defaults.
    if [ -f "${HOME:?}/.aliases" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases"
    fi
    if [ -f "${HOME:?}/.aliases-private" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases-private"
    fi
    if [ -f "${HOME:?}/.aliases-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases-work"
    fi
    unset -v __kvar_bin_prefix __kvar_xdg_data_home
    return 0
}

_koopa_activate_asdf() {
    # """
    # Activate asdf.
    # @note Updated 2023-03-09.
    # """
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
    # NOTE Use 'asdf.fish' for Fish shell.
    __kvar_script="${__kvar_prefix}/libexec/asdf.sh"
    if [ ! -r "$__kvar_script" ]
    then
        unset -v __kvar_prefix __kvar_script
        return 0
    fi
    _koopa_is_alias 'asdf' && unalias 'asdf'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$__kvar_script"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v __kvar_nounset __kvar_prefix __kvar_script
    return 0
}

_koopa_activate_bat() {
    # """
    # Activate bat configuration.
    # @note Updated 2023-03-09.
    #
    # Ensure this follows '_koopa_activate_color_mode'.
    # """
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

# FIXME Need to document that we need to update python3.12 check here on
# a version bump, say to python3.13.

_koopa_activate_bootstrap() {
    # """
    # Conditionally activate koopa bootstrap in current path.
    # @note Updated 2026-04-24.
    # """
    __kvar_bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    if [ ! -d "$(_koopa_bootstrap_prefix)" ]
    then
        unset -v __kvar_bootstrap_prefix
        return 0
    fi
    __kvar_opt_prefix="$(_koopa_opt_prefix)"
    if [ \( -d "${__kvar_opt_prefix}/bash" \) \
        -a \( -d "${__kvar_opt_prefix}/coreutils" \) \
        -a \( -d "${__kvar_opt_prefix}/openssl3" \) \
        -a \( -d "${__kvar_opt_prefix}/python3.12" \) \
        -a \( -d "${__kvar_opt_prefix}/zlib" \) ]
    then
        unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
        return 0
    fi
    _koopa_add_to_path_start "${__kvar_bootstrap_prefix}/bin"
    unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
    return 0
}

_koopa_activate_bottom() {
    # """
    # Activate bottom.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # Activate broot directory tree utility.
    # @note Updated 2023-06-29.
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
    # This is supported for Bash and Zsh.
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
    # shellcheck source=/dev/null
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
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2026-01-22.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51925384/
    # - https://curl.se/docs/caextract.html
    # - https://stat.ethz.ch/R-manual/R-devel/library/utils/html/
    #   download.file.html
    # """
    __kvar_prefix="$(_koopa_xdg_data_home)/ca-certificates"
    __kvar_file="${__kvar_prefix}/cacert.pem"
    if [ ! -f "$__kvar_file" ] && _koopa_is_linux
    then
        __kvar_prefix='/etc/ssl/certs'
        __kvar_file="${__kvar_prefix}/ca-certificates.crt"
    fi
    if [ ! -f "$__kvar_file" ]
    then
        __kvar_prefix="$(_koopa_opt_prefix)/ca-certificates/share/\
ca-certificates"
        __kvar_file="${__kvar_prefix}/cacert.pem"
    fi
    if [ ! -f "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_prefix
        return 0
    fi
    export AWS_CA_BUNDLE="$__kvar_file"
    export CURL_CA_BUNDLE="$__kvar_file"
    export DEFAULT_CA_BUNDLE_PATH="$__kvar_prefix"
    export NODE_EXTRA_CA_CERTS="$__kvar_file"
    export REQUESTS_CA_BUNDLE="$__kvar_file"
    export SSL_CERT_FILE="$__kvar_file"
    if _koopa_is_linux
    then
        export SSL_CERT_DIR='/etc/ssl/certs'
    fi
    unset -v __kvar_file __kvar_prefix
    return 0
}

_koopa_activate_color_mode() {
    # """
    # Activate dark / light color mode.
    # @note Updated 2022-04-13.
    # """
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

_koopa_activate_conda() {
    # """
    # Activate conda.
    # @note Updated 2023-06-29.
    #
    # @seealso
    # - https://conda.io/projects/conda/en/latest/user-guide/
    #     getting-started.html
    # - conda shell.bash hook
    # - conda shell.posix hook
    # - conda shell.zsh hook
    # - conda init <shell>
    # """
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
    # """
    # Activate GNU coreutils aliases.
    # @note Updated 2023-04-07.
    #
    # Creates hardened interactive aliases for coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # gmv on macOS can run into issues on NFS shares.
    # """
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
    # """
    # Activate delta (git-delta) diff tool.
    # @note Updated 2025-02-20.
    # """
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
    ln -fns \
        "$__kvar_source_file" \
        "$__kvar_target_file" \
        >/dev/null 2>&1
    unset -v \
        __kvar_prefix \
        __kvar_source_bn \
        __kvar_source_file \
        __kvar_target_file \
        __kvar_target_link_bn
    return 0
}

_koopa_activate_difftastic() {
    # """
    # Activate difftastic.
    # @note Updated 2022-05-12.
    # """
    [ -x "$(_koopa_bin_prefix)/difft" ] || return 0
    DFT_BACKGROUND="$(_koopa_color_mode)"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}

_koopa_activate_dircolors() {
    # """
    # Activate directory colors.
    # @note Updated 2023-03-09.
    #
    # This will set the 'LS_COLORS' environment variable.
    #
    # Ensure this follows '_koopa_activate_color_mode'.
    # """
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

_koopa_activate_direnv() {
    # """
    # Activate direnv.
    # @note Updated 2026-04-22.
    #
    # @seealso
    # - https://direnv.net/docs/hook.html
    # """
    __kvar_direnv="$(_koopa_bin_prefix)/direnv"
    if [ ! -x "$__kvar_direnv" ]
    then
        unset -v __kvar_direnv
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # Harden against stale, transient values inherited from parent app process.
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_direnv" hook "$__kvar_shell")"
            eval "$("$__kvar_direnv" export "$__kvar_shell")"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_direnv \
        __kvar_nounset \
        __kvar_shell
    return 0
}

_koopa_activate_docker() {
    # """
    # Activate Docker.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://docs.docker.com/engine/release-notes/23.0/
    # """
    _koopa_add_to_path_start "${HOME:?}/.docker/bin"
    return 0
}

_koopa_activate_fzf() {
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2022-05-12.
    # """
    [ -x "$(_koopa_bin_prefix)/fzf" ] || return 0
    if [ -z "${FZF_DEFAULT_OPTS:-}" ]
    then
        export FZF_DEFAULT_OPTS='--border --color bw --multi'
    fi
    return 0
}

_koopa_activate_gcc_colors() {
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

_koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2023-03-09.
    #
    # Check depot setting with 'Base.DEPOT_PATH'.
    # Check number of cores with 'Threads.nthreads()'.
    #
    # @seealso
    # - https://docs.julialang.org/en/v1/manual/environment-variables/
    # - https://docs.julialang.org/en/v1/manual/multi-threading/
    # - https://github.com/JuliaLang/julia/issues/43949
    # """
    [ -x "$(_koopa_bin_prefix)/julia" ] || return 0
    JULIA_DEPOT_PATH="$(_koopa_julia_packages_prefix)"
    JULIA_NUM_THREADS="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH JULIA_NUM_THREADS
    return 0
}

_koopa_activate_kitty() {
    # """
    # Activate Kitty terminal client.
    # @note Updated 2023-03-10.
    #
    # This function dynamically updates dark/light color mode.
    #
    # @seealso
    # - https://sw.kovidgoyal.net/kitty/kittens/themes/
    # """
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
    # """
    # Activate lesspipe.
    # @note Updated 2023-03-10.
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
    # - Use extended ANSI codes, for Markdown rendering in iTerm2.
    #   https://github.com/wofr06/lesspipe/issues/48
    # """
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

_koopa_activate_micromamba() {
    # """
    # Activate mamba (micromamba).
    # @note Update 2022-12-07.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba/issues/984
    # - https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html
    # - https://mamba.readthedocs.io/en/latest/user_guide/configuration.html
    # """
    if [ -z "${MAMBA_ROOT_PREFIX:-}" ]
    then
        export MAMBA_ROOT_PREFIX="${HOME:?}/.mamba"
    fi
    return 0
}

_koopa_activate_path_helper() {
    # """
    # Activate 'path_helper'.
    # @note Updated 2023-03-10.
    #
    # This will source '/etc/paths.d' on supported platforms (e.g. BSD/macOS).
    # """
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
    # """
    # Activate pipx for Python.
    # @note Updated 2023-03-10.
    #
    # @seealso
    # - https://pypa.github.io/pipx/docs/
    # - https://pipxproject.github.io/pipx/installation/
    # """
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
    # """
    # Source additional profile files.
    # @note Updated 2024-07-18.
    # """
    if [ -r "${HOME:?}/.profile-personal" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-personal"
    fi
    if [ -r "${HOME:?}/.profile-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-work"
    fi
    if [ -r "${HOME:?}/.profile-private" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-private"
    fi
    if [ -r "${HOME:?}/.secrets" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets"
    fi
    if [ -r "${HOME:?}/.secrets-personal" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets-personal"
    fi
    if [ -r "${HOME:?}/.secrets-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets-work"
    fi
    return 0
}

_koopa_activate_pyenv() {
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2025-05-05.
    #
    # Supporting multi-user config here.
    #
    # @seealso
    # - https://github.com/macdub/pyenv-multiuser
    # """
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
    export PYENV_LOCAL_SHIM="${HOME:?}/.pyenv_local_shim"
    if [ ! -d "$PYENV_LOCAL_SHIM" ]
    then
        mkdir -p "$PYENV_LOCAL_SHIM"
    fi
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # > eval "$("$__kvar_pyenv" init -)"
    eval "$("$__kvar_pyenv" virtualenv-init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_pyenv
    return 0
}

_koopa_activate_pyright() {
    # """
    # Disable pyright version check spam.
    # @note Updated 2025-05-06.
    # """
    [ -x "$(_koopa_bin_prefix)/pyright" ] || return 0
    export PYRIGHT_PYTHON_FORCE_VERSION='latest'
    return 0
}

_koopa_activate_python() {
    # """
    # Activate Python, including custom installed packages.
    # @note Updated 2026-04-24.
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
    if [ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [ -z "${PYTHONDONTWRITEBYTECODE:-}" ]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    # Added in Python 3.11.
    # This messes with Google Cloud SDK currently, so disabling.
    # https://github.com/GoogleCloudPlatform/gsutil/issues/1735
    # > if [ -z "${PYTHONSAFEPATH:-}" ]
    # > then
    # >     export PYTHONSAFEPATH=1
    # > fi
    if [ -z "${PYTHONSTARTUP:-}" ]
    then
        __kvar_startup_file="${HOME:?}/.pyrc"
        if [ -f "$__kvar_startup_file" ]
        then
            export PYTHONSTARTUP="$__kvar_startup_file"
        fi
        unset -v __kvar_startup_file
    fi
    # 2026-04-24: Harden aws CLI against SyntaxWarning spamming console:
    # https://github.com/conda-forge/awscli-feedstock/issues/2087
    if [ -z "${PYTHONWARNINGS:-}" ]
    then
        export PYTHONWARNINGS='ignore::SyntaxWarning'
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

_koopa_activate_rbenv() {
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2023-06-29.
    # """
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
    # """
    # Activate ripgrep.
    # @note Updated 2023-05-15.
    #
    # @seealso
    # - https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
    # """
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
    # """
    # Activate Ruby gems for current user.
    # @note Updated 2023-03-10.
    # """
    __kvar_prefix="${HOME:?}/.gem"
    export GEM_HOME="$__kvar_prefix"
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    unset -v __kvar_prefix
    return 0
}

_koopa_activate_tealdeer() {
    # """
    # Activate Rust tealdeer (tldr).
    # @note Updated 2025-01-03.
    #
    # This helps standardization the configuration across Linux and macOS.
    #
    # Usage of 'TEALDEER_CACHE_DIR' is now deprecated.
    #
    # @seealso
    # - https://tealdeer-rs.github.io/tealdeer/config.html
    # """
    [ -x "$(_koopa_bin_prefix)/tldr" ] || return 0
    # > if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    # > then
    # >     TEALDEER_CACHE_DIR="$(_koopa_xdg_cache_home)/tealdeer"
    # > fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    # > if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    # > then
    # >     _koopa_is_alias 'mkdir' && unalias 'mkdir'
    # >     mkdir -p "${TEALDEER_CACHE_DIR:?}" >/dev/null
    # > fi
    # > export TEALDEER_CACHE_DIR
    export TEALDEER_CONFIG_DIR
    return 0
}

_koopa_activate_today_bucket() {
    # """
    # Create a dated file today bucket.
    # @note Updated 2024-09-17.
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
    __kvar_bucket_dir="${KOOPA_BUCKET:-}"
    if [ -n "$__kvar_bucket_dir" ]
    then
        [ -d "$KOOPA_BUCKET" ] || return 1
        __kvar_today_link="${HOME:?}/today"
    elif [ -d "${HOME:?}/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/bucket"
        __kvar_today_link="${HOME:?}/today"
    elif [ -d "${HOME:?}/Documents/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/Documents/bucket"
        __kvar_today_link="${HOME:?}/Documents/today"
    else
        unset -v __kvar_bucket_dir
        return 0
    fi
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
    # """
    # Activate XDG base directory specification.
    # @note Updated 2023-03-30.
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
    # """
    # Activate zoxide.
    # @note Updated 2023-05-11.
    #
    # Highly recommended to use along with fzf.
    #
    # @seealso
    # - https://github.com/ajeetdsouza/zoxide
    # """
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

_koopa_alias_colorls() {
    # """
    # colorls alias.
    # @note Updated 2023-03-11.
    #
    # Use of '--git-status' is slow for large directories / monorepos.
    # """
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
    # """
    # Vanilla Emacs alias.
    # @note Updated 2022-04-07.
    # """
    emacs --no-init-file --no-window-system "$@"
}

_koopa_alias_emacs() {
    # """
    # Emacs alias.
    # @note Updated 2023-03-22.
    # """
    _koopa_emacs "$@"
}

_koopa_alias_glances() {
    # """
    # glances alias.
    # @note Updated 2023-03-11.
    #
    # The '--theme-white' setting only works when the background is exactly
    # white. Otherwise, need to use '9' hotkey.
    #
    # @seealso
    # - https://github.com/nicolargo/glances/issues/976
    # """
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
    # """
    # Koopa 'k' shortcut alias.
    # @note Updated 2021-06-08.
    # """
    cd "$(_koopa_koopa_prefix)" || return 1
}

_koopa_alias_kb() {
    # """
    # Koopa 'kb' shortcut alias.
    # @note Updated 2023-05-18.
    # """
    __kvar_bash_prefix="$(_koopa_koopa_prefix)/lang/bash"
    [ -d "$__kvar_bash_prefix" ] || return 1
    cd "$__kvar_bash_prefix" || return 1
    return 0
}

_koopa_alias_kbs() {
    # """
    # Koopa 'kbs' bootstrap alias.
    # @note Updated 2024-06-15.
    # """
    _koopa_add_to_path_start "$(_koopa_xdg_data_home)/koopa-bootstrap/bin"
    return 0
}

_koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2024-09-18.
    #
    # Potentially useful Bash options:
    # * --debugger
    # * --pretty-print
    # * --verbose
    # * -o option
    # * -O shopt_option
    #
    # @seealso
    # - https://superuser.com/questions/319043/
    # """
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
    # > PATH='/usr/bin:/bin'
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
        PATH="${PATH:?}" \
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
    # """
    # List files alias that uses 'eza' instead of 'ls', when possible.
    # @note Updated 2023-09-07.
    #
    # @section Useful exa flags:
    # * -F, --classify
    #         Displays file type indicators by file names.
    # * -a, --all
    #         Shows hidden and 'dot' files.
    #         Use this twice to also show the . and .. directories.
    # * -g, --group
    #         Lists each file's group.
    # * -l, --long
    #         Displays files in a table along with their metadata.
    # * -s, --sort=SORT_FIELD
    #         Configures which field to sort by.
    # *     --git-ignore
    #         Ignores files mentioned in .gitignore.
    # *     --group-directories-first
    #         Lists directories before other files when sorting.
    #
    # @section Useful ls flags:
    # * -B, --ignore-backups
    #         do not list implied entries ending with ~
    # * -F, --classify
    #         append indicator (one of */=>@|) to entries
    # * -h, --human-readable
    #         with -l and -s, print sizes like 1K 234M 2G etc.
    # """
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
    # """
    # Pipe FZF output to Neovim.
    # @note Updated 2022-04-08.
    # """
    nvim "$(fzf)"
}

_koopa_alias_nvim_vanilla() {
    # """
    # Vanilla Neovim.
    # @note Updated 2022-04-08.
    # """
    nvim -u 'NONE' "$@"
}

_koopa_alias_realcd() {
    # """
    # Change directory and automatically resolve realpath.
    # @note Updated 2025-04-27.
    #
    # Defaults to resolving current working directory.
    # """
    __kvar_dir="${1:-}"
    [ -z "$__kvar_dir" ] && __kvar_dir="$(pwd)"
    __kvar_dir="$(_koopa_realpath "$__kvar_dir")"
    cd "$__kvar_dir" || return 1
    unset -v __kvar_dir
    return 0
}

_koopa_alias_tmux_vanilla() {
    # """
    # Vanilla tmux.
    # @note Updated 2022-04-13.
    # """
    tmux -f '/dev/null'
}

_koopa_alias_today() {
    # """
    # Today alias.
    # @note Updated 2021-06-08.
    # """
    date '+%Y-%m-%d'
}

_koopa_alias_venv() {
    # """
    # Python virtual environment activation alias.
    # @note Updated 2025-04-17.
    # """
    if [ -f '.venv/bin/activate' ]
    then
        # shellcheck source=/dev/null
        source '.venv/bin/activate'
    elif [ -f "venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "venv/bin/activate"
    elif [ -f "${HOME}/.venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "${HOME}/.venv/bin/activate"
    elif [ -f "${HOME}/venv/bin/activate" ]
    then
        # shellcheck source=/dev/null
        source "${HOME}/venv/bin/activate"
    else
        _koopa_print 'Failed to locate Python virtual environment.'
        return 1
    fi
    return 0
}

_koopa_alias_vim_fzf() {
    # """
    # Pipe FZF output to Vim.
    # @note Updated 2021-06-08.
    # """
    vim "$(fzf)"
}

_koopa_alias_vim_vanilla() {
    # """
    # Vanilla Vim.
    # @note Updated 2022-04-08.
    # """
    vim -i 'NONE' -u 'NONE' -U 'NONE' "$@"
}

_koopa_alias_week() {
    # """
    # Numerical week alias.
    # @note Updated 2021-06-08.
    # """
    date '+%V'
}

_koopa_add_to_manpath_end() {
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2023-03-10.
    # """
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
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2022-03-10.
    #
    # @seealso
    # - /etc/manpath.config
    # """
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
    # """
    # Force add to 'PATH' end.
    # @note Updated 2023-03-10.
    # """
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
    # """
    # Force add to 'PATH' start.
    # @note Updated 2023-03-10.
    # """
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
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2023-03-10.
    # """
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
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2023-03-11.
    # """
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

_koopa_arch() {
    # """
    # Platform architecture.
    # @note Updated 2023-03-11.
    #
    # e.g. Intel: x86_64; ARM: aarch64.
    # """
    __kvar_string="$(uname -m)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    return 0
}

_koopa_boolean_nounset() {
    # """
    # Return '0' (false) / '1' (true) boolean whether nounset mode is enabled.
    # @note Updated 2023-03-11.
    #
    # @details
    # Intended for [ "$x" -eq 1 ] (true) checks.
    #
    # This approach is the opposite of POSIX shell status codes, where 0 is
    # true and 1 is false.
    # """
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

_koopa_check_multiple_users() {
    # """
    # Check for multiple users, and print who is logged in.
    # @note Updated 2023-09-14.
    #
    # Only performing this check on AWS EC2 currently.
    # """
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
    # """
    # Color mode.
    # @note Updated 2023-03-11.
    # """
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

_koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2024-07-03.
    # """
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

_koopa_doom_emacs() {
    # """
    # Doom Emacs.
    # @note Updated 2023-09-13.
    # """
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

_koopa_duration_start() {
    # """
    # Start activation duration timer.
    # @note Updated 2023-03-11.
    # """
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
    # """
    # Stop activation duration timer.
    # @note Updated 2023-03-11.
    # """
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

_koopa_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2024-01-31.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # Alternatively can set 'export COLORTERM=truecolor'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # - https://chadaustin.me/2024/01/truecolor-terminal-emacs/
    # - https://news.ycombinator.com/item?id=39189881
    # """
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

_koopa_locate_shell() {
    # """
    # Locate the current shell (name, not absolute path).
    # @note Updated 2023-03-10.
    #
    # Don't use 'lsof' on macOS, as it can hang on NFS shares
    # (see '-b' flag for details).
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013/
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
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
    # """
    # Number of logged in users.
    # @note Updated 2023-09-14.
    # """
    __kvar_string="$(_koopa_logged_in_users | wc -l)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

_koopa_logged_in_users() {
    # """
    # Logged in users.
    # @note Updated 2023-09-14.
    #
    # Usage of 'who -q' is problematic when the same user is connected via
    # multiple SSH sessions. Need to filter this out.
    #
    # @seealso
    # - man who
    # - man w
    # """
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

_koopa_prelude_emacs() {
    # """
    # Prelude Emacs.
    # @note Updated 2023-05-09.
    # """
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
    # """
    # Print a string.
    # @note Updated 2023-03-11.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
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

_koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2023-03-23.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
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
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2023-03-11.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/145402/
    #
    # @examples
    # > _koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/local/bin'
    # > _koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/bin'
    # """
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

_koopa_shell_name() {
    # """
    # Current shell name.
    # @note Updated 2024-07-09.
    # """
    __kvar_shell="$(_koopa_locate_shell)"
    __kvar_shell="$(basename "$__kvar_shell")"
    [ -n "$__kvar_shell" ] || return 1
    _koopa_print "$__kvar_shell"
    unset -v __kvar_shell
    return 0
}

_koopa_spacemacs() {
    # """
    # Spacemacs.
    # @note Updated 2023-09-13.
    # """
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

_koopa_spacevim() {
    # """
    # SpaceVim alias.
    # @note Updated 2023-05-09.
    # """
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

_koopa_walk() {
    __kvar_walk="$(_koopa_bin_prefix)/walk"
    [ -x "$__kvar_walk" ] || return 1
    cd "$("$__kvar_walk" "$@")" || return 1
    unset -v __kvar_walk
    return 0
}

_koopa_export_editor() {
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2024-06-13.
    # """
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
    # """
    # Export GnuPG settings.
    # @note Updated 2022-04-08.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    [ -z "${GPG_TTY:-}" ] || return 0
    _koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}

_koopa_export_history() {
    # """
    # Export history.
    # @note Updated 2023-03-13.
    #
    # See 'bash(1)' for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.$(_koopa_shell_name)_history"
    fi
    export HISTFILE
    # Create the history file, if necessary.
    # Note that the HOME check here hardens against symlinked data disk failure.
    if [ ! -f "$HISTFILE" ] \
        && [ -e "${HOME:-}" ] \
        && _koopa_is_installed 'touch'
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

_koopa_export_home() {
    # """
    # Ensure that 'HOME' variable is exported.
    # @note Updated 2023-05-12
    # """
    [ -z "${HOME:-}" ] && HOME="$(pwd)"
    export HOME
    return 0
}

_koopa_export_koopa_cpu_count() {
    # """
    # Export 'KOOPA_CPU_COUNT' variable.
    # @note Updated 2022-07-28.
    # """
    KOOPA_CPU_COUNT="$(_koopa_cpu_count)"
    export KOOPA_CPU_COUNT
    return 0
}

_koopa_export_koopa_shell() {
    # """
    # Export 'KOOPA_SHELL' and 'SHELL' variables.
    # @note Updated 2023-05-12.
    # """
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(_koopa_locate_shell)"
    [ -z "${SHELL:-}" ] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}

_koopa_export_manpager() {
    # """
    # Export 'MANPAGER' variable.
    # @note Updated 2025-04-24.
    #
    # Alternatively can use 'less --incsearch'.
    #
    # @seealso
    # - https://www.reddit.com/r/neovim/comments/1k1k9bz/
    #     use_neovim_as_the_default_man_page_viewer/
    # """
    [ -n "${MANPAGER:-}" ] && return 0
    __kvar_nvim="$(_koopa_bin_prefix)/nvim"
    if [ -x "$__kvar_nvim" ]
    then
        export MANPAGER="${__kvar_nvim} +Man!"
    fi
    unset -v __kvar_nvim
    return 0
}

_koopa_export_pager() {
    # """
    # Export 'PAGER' variable.
    # @note Updated 2023-03-11.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    [ -n "${PAGER:-}" ] && return 0
    __kvar_less="$(_koopa_bin_prefix)/less"
    if [ -x "$__kvar_less" ]
    then
        export PAGER="${__kvar_less} -R"
    fi
    unset -v __kvar_less
    return 0
}

_koopa_is_alacritty() {
    # """
    # Is Alacritty the current terminal client?
    # @note Updated 2022-05-06.
    # """
    [ -n "${ALACRITTY_SOCKET:-}" ]
}

_koopa_is_alias() {
    # """
    # Is the specified argument an alias?
    # @note Updated 2023-03-27.
    #
    # @example
    # TRUE:
    # _koopa_is_alias 'tmux-vanilla'
    #
    # FALSE:
    # _koopa_is_alias 'bash'
    # _koopa_is_alias '_koopa_koopa_prefix'
    # """
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

_koopa_is_aws_ec2() {
    # """
    # Is the current shell running on an AWS EC2 instance?
    # @note Updated 2023-09-14.
    #
    # @seealso
    # - https://serverfault.com/questions/462903/
    # """
    [ -x '/usr/bin/ec2metadata' ] && return 0
    [ "$(hostname -d)" = 'ec2.internal' ] && return 0
    return 1
}

_koopa_is_function() {
    # """
    # Is the specified argument a function?
    # @note Updated 2023-03-27.
    #
    # @example
    # TRUE:
    # > _koopa_is_function '_koopa_koopa_prefix'
    #
    # FALSE:
    # _koopa_is_function 'bash'
    # _koopa_is_function 'tmux-vanilla'
    # """
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
    # """
    # Is the requested program name installed?
    # @note Updated 2023-03-27.
    #
    # @examples
    # TRUE:
    # _koopa_is_installed 'bash'
    #
    # FALSE:
    # _koopa_is_installed '_koopa_koopa_prefix'
    # """
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
    # """
    # Is the current shell interactive?
    # @note Updated 2023-12-14.
    # """
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
    # > if [ -n "${SSH_CONNECTION:-}" ] && [ -n "${TMUX:-}" ]
    # > then
    # >     return 0
    # > fi
    return 1
}

_koopa_is_kitty() {
    # """
    # Is Kitty the active terminal?
    # @note Updated 2022-05-06.
    # """
    [ -n "${KITTY_PID:-}" ]
}

_koopa_is_linux() {
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = 'Linux' ]
}

_koopa_is_macos() {
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    [ "$(uname -s)" = 'Darwin' ]
}

_koopa_is_set_nounset() {
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
    _koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

_koopa_is_subshell() {
    # """
    # Is koopa running inside a subshell?
    # @note Updated 2021-05-06.
    # """
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

_koopa_is_tty() {
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-07-03.
    # """
    _koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_macos_activate_cli_colors() {
    # """
    # Activate macOS-specific terminal color settings.
    # @note Updated 2020-07-05.
    #
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/
    #     apple-mac-osx-terminal-color-ls-output-option/
    # """
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    # > [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

_koopa_macos_activate_egnyte() {
    # """
    # Activate macOS Egnyte CLI.
    # @note Updated 2023-04-07.
    # """
    _koopa_add_to_path_end "${HOME}/Library/Group Containers/\
FELUD555VC.group.com.egnyte.DesktopApp/CLI"
    return 0
}

_koopa_macos_activate_homebrew() {
    # """
    # Activate Homebrew on macOS.
    # @note Updated 2025-11-12.
    # """
    __kvar_prefix="$(_koopa_homebrew_prefix)"
    if [ ! -x "${__kvar_prefix}/bin/brew" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_brewfile="$(_koopa_xdg_config_home)/homebrew/Brewfile"
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    if [ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ] && [ -f "$__kvar_brewfile" ]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="$__kvar_brewfile"
    fi
    if [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ]
    then
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    fi
    if [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ]
    then
        export HOMEBREW_INSTALL_CLEANUP=1
    fi
    if [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ]
    then
        export HOMEBREW_NO_ENV_HINTS=1
    fi
    unset -v __kvar_brewfile __kvar_prefix
    return 0
}

_koopa_macos_emacs() {
    # """
    # macOS Emacs.app that supports full screen window mode.
    # @note Updated 2023-05-06.
    # """
    __kvar_homebrew_prefix="$(_koopa_homebrew_prefix)"
    [ -d "$__kvar_homebrew_prefix" ] || return 1
    __kvar_emacs="${__kvar_homebrew_prefix}/bin/emacs"
    [ -x "$__kvar_emacs" ] || return 1
    _koopa_print "$__kvar_emacs"
    unset -v __kvar_emacs __kvar_homebrew_prefix
    return 0
}

_koopa_macos_is_dark_mode() {
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2023-03-11.
    # """
    [ \
        "$( \
            /usr/bin/defaults read -g 'AppleInterfaceStyle' \
            2>/dev/null \
        )" = 'Dark' \
    ]
}

_koopa_asdf_prefix() {
    # """
    # asdf prefix.
    # @note Updated 2022-08-31.
    # """
    _koopa_print "$(_koopa_opt_prefix)/asdf"
    return 0
}

_koopa_bin_prefix() {
    # """
    # Koopa binary prefix.
    # @note Updated 2022-04-04.
    # """
    _koopa_print "$(_koopa_koopa_prefix)/bin"
    return 0
}

_koopa_bootstrap_prefix() {
    # """
    # Koopa bootstrap prefix.
    # @note Updated 2024-06-16.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/koopa-bootstrap"
    return 0
}

_koopa_conda_prefix() {
    # """
    # Conda prefix.
    # @note Updated 2021-05-25.
    # @seealso conda info --base
    # """
    _koopa_print "$(_koopa_opt_prefix)/conda"
    return 0
}

_koopa_config_prefix() {
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    _koopa_print "$(_koopa_xdg_config_home)/koopa"
    return 0
}

_koopa_doom_emacs_prefix() {
    # """
    # Doom Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/doom"
    return 0
}

_koopa_homebrew_prefix() {
    # """
    # Homebrew prefix.
    # @note Updated 2023-03-11.
    #
    # @seealso https://brew.sh/
    # """
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

_koopa_julia_packages_prefix() {
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2022-07-28.
    # """
    _koopa_print "${HOME:?}/.julia"
}

_koopa_koopa_prefix() {
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_opt_prefix() {
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    _koopa_print "$(_koopa_koopa_prefix)/opt"
    return 0
}

_koopa_pipx_prefix() {
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/pipx"
    return 0
}

_koopa_prelude_emacs_prefix() {
    # """
    # Prelude Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/prelude"
    return 0
}

_koopa_pyenv_prefix() {
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}

_koopa_rbenv_prefix() {
    # """
    # Ruby rbenv prefix.
    # @note Updated 2021-05-25.
    # ""
    _koopa_print "$(_koopa_opt_prefix)/rbenv"
    return 0
}

_koopa_scripts_private_prefix() {
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_spacemacs_prefix() {
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/spacemacs"
    return 0
}

_koopa_spacevim_prefix() {
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    _koopa_print "$(_koopa_xdg_data_home)/spacevim"
    return 0
}

_koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # XDG config dirs.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # XDG config home.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # XDG data dirs.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # XDG data home.
    # @note Updated 2023-03-09.
    # """
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
    # """
    # XDG local installation home.
    # @note Updated 2021-05-20.
    #
    # Not intended to be configurable with a global variable.
    #
    # @seealso
    # - https://www.freedesktop.org/software/systemd/man/file-hierarchy.html
    # """
    _koopa_print "${HOME:?}/.local"
    return 0
}

_koopa_xdg_state_home() {
    # """
    # XDG state home.
    # @note Updated 2023-03-30.
    # """
    __kvar_string="${XDG_STATE_HOME:-}"
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$(_koopa_xdg_local_home)/state"
    fi
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

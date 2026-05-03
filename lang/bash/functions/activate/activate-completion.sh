#!/usr/bin/env bash

_koopa_activate_completion() {
    # """
    # Activate koopa shell completion.
    # @note Updated 2026-05-03.
    #
    # For Bash, we symlink our completion file into the XDG user completions
    # directory. bash-completion v2 lazy-loads from there on first TAB press,
    # so nothing needs to be sourced at startup.
    #
    # XDG lookup order (bash-completion v2):
    # - BASH_COMPLETION_USER_DIR/completions/ (if set, colon-separated)
    # - ${XDG_DATA_HOME:-~/.local/share}/bash-completion/completions/
    # """
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
    local koopa_completion
    koopa_completion="${koopa_prefix}/etc/completion/koopa.sh"
    [[ -f "$koopa_completion" ]] || return 0
    if [[ "$shell" == 'bash' ]]
    then
        local xdg_data_home completions_dir link
        xdg_data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
        completions_dir="${xdg_data_home}/bash-completion/completions"
        link="${completions_dir}/koopa"
        if [[ ! -L "$link" ]] || \
            [[ "$(readlink "$link")" != "$koopa_completion" ]]
        then
            mkdir -p "$completions_dir"
            ln -fns "$koopa_completion" "$link"
        fi
    else
        # Zsh: bashcompinit is already active; source directly.
        # shellcheck source=/dev/null
        source "$koopa_completion"
    fi
    return 0
}

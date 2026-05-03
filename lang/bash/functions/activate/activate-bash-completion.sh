#!/usr/bin/env bash

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2026-05-03.
    #
    # Sets BASH_COMPLETION_USER_DIR so bash-completion v2 lazy-loads all
    # koopa-managed app completions from the central directory
    # ($KOOPA_PREFIX/share/bash-completion) on first TAB press per command.
    # App completion files are symlinked there at install time.
    # """
    local koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    # Point bash-completion v2 at the koopa-managed central directory.
    # The framework appends '/completions' when scanning, so we pass the
    # parent directory here.
    export BASH_COMPLETION_USER_DIR="${koopa_prefix}/share/bash-completion"
    # Load bash-completion v2 framework.
    local framework
    framework="${koopa_prefix}/opt/bash-completion/etc/profile.d/bash_completion.sh"
    [[ -f "$framework" ]] && source "$framework"
    return 0
}

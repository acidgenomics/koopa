#!/bin/sh

# FIXME This isn't working on our Ubuntu 22 dev machine.

koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2022-09-08.
    #
    # Alternative approach:
    # > export KOOPA_ACTIVATE=0
    # > "$bash" -il
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
    local bash env
    bash="$(koopa_bin_prefix)/bash"
    if [ ! -x "$bash" ] && ! koopa_is_macos
    then
        bash='/usr/bin/bash'
    fi
    [ -x "$bash" ] || return 1
    env='/usr/bin/env'
    [ -x "$env" ] || return 1
    "$env" -i \
        HOME="${HOME:?}" \
        KOOPA_ACTIVATE=0 \
        LC_ALL="${LC_ALL:-}" \
        LC_BYOBU="${LC_BYOBU:-}" \
        LC_COLLATE="${LC_COLLATE:-}" \
        LC_CTYPE="${LC_CTYPE:-}" \
        LC_MESSAGES="${LC_MESSAGES:-}" \
        LC_MONETARY="${LC_MONETARY:-}" \
        LC_NUMERIC="${LC_NUMERIC:-}" \
        LC_TERMTYPE="${LC_TERMTYPE:-}" \
        LC_TIME="${LC_TIME:-}" \
        LOGNAME="${LOGNAME:-}" \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TERM_PROGRAM="${TERM_PROGRAM:-}" \
        TMPDIR="${TMPDIR:-}" \
        XDG_DATA_DIRS="${XDG_DATA_DIRS:-}" \
        "$bash" \
            --login \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}

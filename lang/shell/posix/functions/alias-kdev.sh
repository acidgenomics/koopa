#!/bin/sh

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
        LC_ALL="${LC_ALL:-C}" \
        LC_BYOBU="${LC_BYOBU:-}" \
        LC_COLLATE="${LC_COLLATE:-C}" \
        LC_CTYPE="${LC_CTYPE:-C}" \
        LC_MESSAGES="${LC_MESSAGES:-C}" \
        LC_MONETARY="${LC_MONETARY:-C}" \
        LC_NUMERIC="${LC_NUMERIC:-C}" \
        LC_TERMTYPE="${LC_TERMTYPE:-}" \
        LC_TIME="${LC_TIME:-C}" \
        LOGNAME="${LOGNAME:-}" \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TERM_PROGRAM="${TERM_PROGRAM:-}" \
        TMPDIR="${TMPDIR:-}" \
        XDG_DATA_DIRS="${XDG_DATA_DIRS:-}" \
        "$bash" \
            -il \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}

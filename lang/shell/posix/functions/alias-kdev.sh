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
    local bash bin_prefix env koopa_prefix
    bin_prefix="$(koopa_bin_prefix)"
    koopa_prefix="$(koopa_koopa_prefix)"
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
        TMPDIR="${TMPDIR:-}" \
        "$bash" \
            --noprofile \
            --rcfile "${koopa_prefix}/lang/shell/bash/include/header.sh" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}

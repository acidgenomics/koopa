#!/bin/sh

koopa_activate_secrets() {
    # """
    # Source secrets file.
    # @note Updated 2020-07-07.
    # """
    local file
    file="${1:-}"
    [ -z "$file" ] && file="${HOME:?}/.secrets"
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

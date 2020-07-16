#!/usr/bin/env bash

koopa::debian_header() {
    # """
    # Debian Linux header.
    # @note Updated 2020-07-16.
    # """
    local file koopa_prefix
    koopa_prefix="$( \
        cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
        &>/dev/null \
        && pwd -P \
    )"
    # shellcheck source=/dev/null
    source "${koopa_prefix}/os/linux/include/header.sh"
    for file in "${koopa_prefix}/shell/bash/functions/os/debian/"*'.sh'
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    koopa::assert_is_debian
    return 0
}

koopa::debian_header "$@"

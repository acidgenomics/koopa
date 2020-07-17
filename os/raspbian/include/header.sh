#!/usr/bin/env bash

koopa::raspbian_header() {
    # """
    # Raspbian Linux header.
    # @note Updated 2020-07-16.
    # """
    local file koopa_prefix
    koopa_prefix="$( \
        cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
        &>/dev/null \
        && pwd -P \
    )"
    # shellcheck source=/dev/null
    source "${koopa_prefix}/os/debian/include/header.sh"
    for file in "${koopa_prefix}/shell/bash/functions/os/raspbian/"*'.sh'
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    koopa::assert_is_raspbian
    return 0
}

koopa::raspbian_header "$@"

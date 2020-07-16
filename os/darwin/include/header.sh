#!/usr/bin/env bash

koopa::macos_header() {
    # """
    # macOS header.
    # @note Updated 2020-07-16.
    # """
    local file koopa_prefix
    koopa_prefix="$( \
        cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
        &>/dev/null \
        && pwd -P \
    )"
    # shellcheck source=/dev/null
    source "${koopa_prefix}/shell/bash/include/header.sh"
    for file in "${koopa_prefix}/shell/bash/functions/os/macos/"*'.sh'
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    koopa::assert_is_macos
    return 0
}

koopa::macos_header "$@"

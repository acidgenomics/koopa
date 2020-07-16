#!/usr/bin/env bash

koopa::fedora_header() {
    # """
    # Fedora Linux header.
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
    for file in "${koopa_prefix}/shell/bash/functions/os/fedora/"*'.sh'
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    koopa::assert_is_fedora
    return 0
}

koopa::fedora_header "$@"

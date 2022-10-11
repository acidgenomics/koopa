#!/usr/bin/env bash

koopa_ignore_pipefail() {
    # """
    # Ignore pipefail with exit code 141.
    # @note Updated 2022-10-11.
    #
    # This can happen with complex pipes involving GNU coreutils head.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22464786/
    # """
    local status
    status="${1:?}"
    [[ "$status" -eq 141 ]] && return 0
    return "$status"
}

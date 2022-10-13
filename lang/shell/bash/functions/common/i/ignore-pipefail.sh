#!/usr/bin/env bash

koopa_ignore_pipefail() {
    # """
    # Ignore pipefail with exit code 141.
    # @note Updated 2022-10-11.
    #
    # This can happen with complex pipes involving GNU coreutils head.
    #
    # @seealso
    # - "${PIPESTATUS[@]}"
    # - https://stackoverflow.com/questions/22464786/
    # - https://stackoverflow.com/questions/19120263/
    # - https://github.com/stedolan/jq/issues/1017/
    # - https://stackoverflow.com/questions/41516177/
    # - https://mywiki.wooledge.org/BashFAQ/105
    # - https://mywiki.wooledge.org/BashFAQ/112
    # """
    local status
    status="${1:?}"
    [[ "$status" -eq 141 ]] && return 0
    return "$status"
}

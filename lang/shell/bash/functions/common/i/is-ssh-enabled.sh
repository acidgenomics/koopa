#!/usr/bin/env bash

koopa_is_ssh_enabled() {
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    local -A app=(
        ['ssh']="$(koopa_locate_ssh)"
    )
    [[ -x "${app['ssh']}" ]] || exit 1
    local -A dict=(
        ['url']="${1:?}"
        ['pattern']="${2:?}"
    )
    dict['str']="$( \
        "${app['ssh']}" -T \
            -o StrictHostKeyChecking='no' \
            "${dict['url']}" 2>&1 \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_str_detect_fixed \
        --string="${dict['str']}" \
        --pattern="${dict['pattern']}"
}

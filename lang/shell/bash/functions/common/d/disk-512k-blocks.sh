#!/usr/bin/env bash

koopa_disk_512k_blocks() {
    # """
    # Get POSIX standardized 512k byte blocks for a drive.
    # @note Updated 2022-09-01.
    #
    # @examples
    # > koopa_disk_512k_blocks '/'
    # # 976490576 (for 512 GB SSD)
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['df']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['sed']}" ]] || exit 1
    declare -A dict=(
        ['disk']="${1:?}"
    )
    # shellcheck disable=SC2016
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" -P "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

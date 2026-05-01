#!/usr/bin/env bash

_koopa_disk_512k_blocks() {
    # """
    # Get POSIX standardized 512k byte blocks for a drive.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > _koopa_disk_512k_blocks '/'
    # # 976490576 (for 512 GB SSD)
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    # shellcheck disable=SC2016
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" -P "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

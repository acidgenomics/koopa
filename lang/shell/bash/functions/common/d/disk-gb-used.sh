#!/usr/bin/env bash

koopa_disk_gb_used() {
    # """
    # Used disk space in GB.
    # @note Updated 2022-09-01.
    #
    # @examples
    # > koopa_disk_gb_used '/'
    # # 241
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['df']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['sed']}" ]] || exit 1
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    # shellcheck disable=SC2016
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $3}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

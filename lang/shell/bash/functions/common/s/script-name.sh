#!/usr/bin/env bash

koopa_script_name() {
    # """
    # Get the calling script name.
    # @note Updated 2023-04-05.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="$( \
        caller \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    dict['bn']="$(koopa_basename "${dict['file']}")"
    [[ -n "${dict['bn']}" ]] || return 0
    koopa_print "${dict['bn']}"
    return 0
}

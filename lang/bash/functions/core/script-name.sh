#!/usr/bin/env bash

_koopa_script_name() {
    # """
    # Get the calling script name.
    # @note Updated 2023-04-05.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$( \
        caller \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    dict['bn']="$(_koopa_basename "${dict['file']}")"
    [[ -n "${dict['bn']}" ]] || return 0
    _koopa_print "${dict['bn']}"
    return 0
}

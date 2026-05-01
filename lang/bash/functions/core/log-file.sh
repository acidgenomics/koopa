#!/usr/bin/env bash

_koopa_log_file() {
    # """
    # Create log file.
    # @note Updated 2022-08-23.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['datetime']="$(_koopa_datetime)"
    dict['hostname']="$(_koopa_hostname)"
    dict['log_file']="${HOME:?}/logs/${dict['hostname']}/\
${dict['datetime']}.log"
    _koopa_touch "${dict['log_file']}"
    _koopa_print "${dict['log_file']}"
    return 0
}

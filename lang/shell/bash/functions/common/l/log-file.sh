#!/usr/bin/env bash

koopa_log_file() {
    # """
    # Create log file.
    # @note Updated 2022-08-23.
    # """
    local dict
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['datetime']="$(koopa_datetime)"
    dict['hostname']="$(koopa_hostname)"
    dict['log_file']="${HOME:?}/logs/${dict['hostname']}/\
${dict['datetime']}.log"
    koopa_touch "${dict['log_file']}"
    koopa_print "${dict['log_file']}"
    return 0
}

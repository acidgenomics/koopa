#!/usr/bin/env bash

koopa_help() {
    # """
    # Show usage via '--help' flag.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    app['head']="$(koopa_locate_head --allow-system)"
    app['man']="$(koopa_locate_man --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

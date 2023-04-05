#!/usr/bin/env bash

koopa_help() {
    # """
    # Show usage via '--help' flag.
    # @note Updated 2022-08-30.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    local -A dict
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    local -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
        ['man']="$(koopa_locate_man --allow-system)"
    )
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['man']}" ]] || exit 1
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

#!/usr/bin/env bash

koopa_help() {
    # """
    # Show usage via '--help' flag.
    # @note Updated 2022-08-30.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-missing)"
        ['man']="$(koopa_locate_man --allow-missing)"
    )
    [[ ! -x "${app['head']}" ]] && app['head']='/usr/bin/head'
    [[ ! -x "${app['man']}" ]] && app['man']='/usr/bin/man'
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['man']}" ]] || return 1
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

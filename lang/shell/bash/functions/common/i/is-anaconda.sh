#!/usr/bin/env bash

koopa_is_anaconda() {
    # """
    # Is Anaconda (rather than Miniconda) installed?
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['conda']="${1:-}"
    [[ -z "${app['conda']}" ]] && app['conda']="$(koopa_locate_conda)"
    [[ -x "${app['conda']}" ]] || return 1
    dict['prefix']="$(koopa_parent_dir --num=2 "${app['conda']}")"
    [[ -x "${dict['prefix']}/bin/anaconda" ]] || return 1
    return 0
}

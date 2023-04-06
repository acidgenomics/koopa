#!/usr/bin/env bash

koopa_find_dotfiles() {
    # """
    # Find dotfiles by type.
    # @note Updated 2022-02-17.
    #
    # This is used internally by 'koopa_list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['awk']="$(koopa_locate_awk)"
    app['basename']="$(koopa_locate_basename)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['type']="${1:?}"
    dict['header']="${2:?}"
    # shellcheck disable=SC2016
    dict['str']="$( \
        koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict['type']}" \
        | "${app['xargs']}" -0 -n 1 "${app['basename']}" \
        | "${app['awk']}" '{print "    -",$0}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_h2 "${dict['header']}:"
    koopa_print "${dict['str']}"
    return 0
}

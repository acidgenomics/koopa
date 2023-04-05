#!/usr/bin/env bash

koopa_nfiletypes() {
    # """
    # Return the number of file types in a specific directory.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_nfiletypes "${PWD:?}"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    local -A app=(
        ['sed']="$(koopa_locate_sed)"
        ['sort']="$(koopa_locate_sort)"
        ['uniq']="$(koopa_locate_uniq)"
    )
    [[ -x "${app['sed']}" ]] || exit 1
    [[ -x "${app['sort']}" ]] || exit 1
    [[ -x "${app['uniq']}" ]] || exit 1
    local -A dict=(
        ['prefix']="${1:?}"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    dict['out']="$( \
        koopa_find \
            --exclude='.*' \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.*' \
            --prefix="${dict['prefix']}" \
            --type='f' \
        | "${app['sed']}" 's/.*\.//' \
        | "${app['sort']}" \
        | "${app['uniq']}" --count \
        | "${app['sort']}" --numeric-sort \
        | "${app['sed']}" 's/^ *//g' \
        | "${app['sed']}" 's/ /\t/g' \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

#!/usr/bin/env bash

koopa_brew_doctor() {
    # """
    # Run a subset of brew doctor checks.
    # @note Updated 2023-05-20.
    #
    # @seealso
    # - https://stackoverflow.com/questions/2312762/
    # """
    local -A app
    local -a all_checks disabled_checks enabled_checks
    app['brew']="$(koopa_locate_brew)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    app['uniq']="$(koopa_locate_uniq --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    disabled_checks=(
        'check_for_stray_dylibs'
        'check_for_stray_headers'
        'check_for_stray_las'
        'check_for_stray_pcs'
        'check_for_stray_static_libs'
        'check_user_path_1'
        'check_user_path_2'
        'check_user_path_3'
    )
    readarray -t all_checks <<< "$("${app['brew']}" doctor --list-checks)"
    readarray -t enabled_checks <<< "$( \
        koopa_print "${all_checks[@]}" "${disabled_checks[@]}" \
            | "${app['tr']}" ' ' '\n' \
            | "${app['sort']}" \
            | "${app['uniq']}" -u \
    )"
    koopa_assert_is_array_non_empty "${enabled_checks[@]}"
    "${app['brew']}" config || true
    "${app['brew']}" doctor "${enabled_checks[@]}" || true
    return 0
}

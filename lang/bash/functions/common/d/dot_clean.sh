#!/usr/bin/env bash

koopa_dot_clean() {
    # """
    # Clean up dot files recursively inside a directory.
    # @note Updated 2023-05-22.
    # """
    local -A app dict
    local -a files
    koopa_assert_has_args_eq "$#" 1
    app['fd']="$(koopa_locate_fd)"
    app['rm']="$(koopa_locate_rm --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    if koopa_is_macos
    then
        app['dot_clean']="$(koopa_macos_locate_dot_clean)"
        koopa_assert_is_executable "${app['dot_clean']}"
        "${app['dot_clean']}" -v "${dict['prefix']}"
    fi
    "${app['fd']}" \
        --base-directory="${dict['prefix']}" \
        --hidden \
        --type='f' \
        '.DS_Store' \
        --exec "${app['rm']}" -v '{}'
    readarray -t files <<< "$( \
        "${app['fd']}" \
            --base-directory="${dict['prefix']}" \
            --glob \
            --hidden \
            --type='f' \
            '.*' \
    )"
    if koopa_is_array_non_empty "${files[@]}"
    then
        koopa_alert_note "Dot files remaining in '${dict['prefix']}'."
        koopa_print "${files[@]}"
        return 1
    fi
    return 0
}

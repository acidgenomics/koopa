#!/usr/bin/env bash

koopa_reset_permissions() {
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2023-04-05.
    #
    # By default this changes group, which may be unwanted on some systems
    # for accounts that aren't admin and can't easily change the group back.
    #
    # @examples
    # > koopa_reset_permissions "${PWD:?}"
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['chmod']="$(koopa_locate_chmod)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="$(koopa_group_name)"
    dict['prefix']="${1:?}"
    dict['user']="$(koopa_user_name)"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    koopa_chown --recursive \
        "${dict['user']}:${dict['group']}" \
        "${dict['prefix']}"
    # Directories.
    koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='d' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    # Files.
    koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rw,g=rw,o=r' {}
    # Executable (shell) scripts.
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

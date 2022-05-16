#!/usr/bin/env bash

koopa_reset_permissions() {
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_reset_permissions "$PWD"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [chmod]="$(koopa_locate_chmod)"
        [xargs]="$(koopa_locate_xargs)"
    )
    declare -A dict=(
        [group]="$(koopa_group)"
        [prefix]="${1:?}"
        [user]="$(koopa_user)"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_chown --recursive "${dict[user]}:${dict[group]}" "${dict[prefix]}"
    # Directories.
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='d' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    # Files.
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rw,g=rw,o=r' {}
    # Executable (shell) scripts.
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

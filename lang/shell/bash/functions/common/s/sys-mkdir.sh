#!/usr/bin/env bash

koopa_sys_mkdir() {
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2022-04-07.
    # """
    koopa_assert_has_args "$#"
    koopa_mkdir "$@"
    koopa_sys_set_permissions "$@"
    return 0
}

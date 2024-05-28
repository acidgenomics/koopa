#!/usr/bin/env bash

koopa_rename_camel_case() {
    # """
    # Rename files with camel case formatting.
    # @note Updated 2024-05-28.
    # """
    koopa_assert_has_args "$#"
    koopa_r_script --system 'rename-camel-case.R' "$@"
    return 0
}

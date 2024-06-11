#!/usr/bin/env bash

koopa_rename_snake_case() {
    # """
    # Rename files with snake case formatting.
    # @note Updated 2024-05-28.
    # """
    koopa_assert_has_args "$#"
    koopa_r_script --system 'rename-snake-case.R' "$@"
    return 0
}

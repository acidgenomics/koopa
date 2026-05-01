#!/usr/bin/env bash

_koopa_rename_snake_case() {
    # """
    # Rename files with snake case formatting.
    # @note Updated 2024-05-28.
    # """
    _koopa_assert_has_args "$#"
    _koopa_r_script --system 'rename-snake-case.R' "$@"
    return 0
}

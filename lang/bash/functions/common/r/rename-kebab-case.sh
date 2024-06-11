#!/usr/bin/env bash

koopa_rename_kebab_case() {
    # """
    # Rename files with kebab case formatting.
    # @note Updated 2024-05-28.
    # """
    koopa_assert_has_args "$#"
    koopa_r_script --system 'rename-kebab-case.R' "$@"
    return 0
}

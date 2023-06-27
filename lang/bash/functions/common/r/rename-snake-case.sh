#!/usr/bin/env bash

koopa_rename_snake_case() {
    # """
    # Rename files with snake case formatting.
    # @note Updated 2023-06-05.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliSnakeCase' "$@"
}
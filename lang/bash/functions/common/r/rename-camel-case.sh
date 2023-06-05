#!/usr/bin/env bash

koopa_rename_camel_case() {
    # """
    # Rename files with camel case formatting.
    # @note Updated 2023-06-05.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliCamelCase' "$@"
}

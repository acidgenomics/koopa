#!/usr/bin/env bash

# FIXME Rework this as a Rust program.

koopa_rename_kebab_case() {
    # """
    # Rename files with kebab case formatting.
    # @note Updated 2023-06-05.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}

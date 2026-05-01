#!/usr/bin/env bash

_koopa_rename_camel_case() {
    # """
    # Rename files with camel case formatting.
    # @note Updated 2024-05-28.
    # """
    _koopa_assert_has_args "$#"
    _koopa_r_script --system 'rename-camel-case.R' "$@"
    return 0
}

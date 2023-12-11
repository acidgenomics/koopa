#!/usr/bin/env bash

koopa_rename_camel_case() {
    # """
    # Rename files with camel case formatting.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_args "$#"
    # FIXME Need to add support for this.
    koopa_python_script 'rename-camel-case.py' "$@"
    return 0
}

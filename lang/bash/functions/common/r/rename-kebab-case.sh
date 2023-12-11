#!/usr/bin/env bash

koopa_rename_kebab_case() {
    # """
    # Rename files with kebab case formatting.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_args "$#"
    # FIXME Need to add support for this.
    koopa_python_script 'rename-kebab-case.py' "$@"
    return 0
}

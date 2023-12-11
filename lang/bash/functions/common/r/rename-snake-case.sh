#!/usr/bin/env bash

koopa_rename_snake_case() {
    # """
    # Rename files with snake case formatting.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_args "$#"
    # FIXME Need to add support for this.
    koopa_python_script 'rename-snake-case.py' "$@"
    return 0
}

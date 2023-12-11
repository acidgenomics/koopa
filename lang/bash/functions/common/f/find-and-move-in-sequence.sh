#!/usr/bin/env bash

koopa_find_and_move_in_sequence() {
    # """
    # Find and move files in sequence.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_args "$#"
    # FIXME Add support for this.
    koopa_python_script 'find-and-move-in-sequence.py' "$@"
    return 0
}

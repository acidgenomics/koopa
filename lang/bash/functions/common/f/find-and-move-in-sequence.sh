#!/usr/bin/env bash

koopa_find_and_move_in_sequence() {
    # """
    # Find and move files in sequence.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliFindAndMoveInSequence' "$@"
    return 0
}

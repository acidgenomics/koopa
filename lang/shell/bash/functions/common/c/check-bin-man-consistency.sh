#!/usr/bin/env bash

koopa_check_bin_man_consistency() {
    # """
    # Check bin and man consistency.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliCheckBinManConsistency' "$@"
    return 0
}

#!/usr/bin/env bash

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-11-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa::rscript_vanilla 'check-system'
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
    return 0
}

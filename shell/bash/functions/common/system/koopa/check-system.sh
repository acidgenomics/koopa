#!/usr/bin/env bash

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-11-17.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    script="$(koopa::rscript_prefix)/check-system.R"
    koopa::assert_is_file "$script"
    Rscript --vanilla "$script"
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
    return 0
}

#!/usr/bin/env bash

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-08-12.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    script="$(koopa::rscript_prefix)/list.R"
    koopa::assert_is_file "$script"
    Rscript --vanilla "$script"
    return 0
}

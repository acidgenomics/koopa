#!/usr/bin/env bash

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-08-12.
    # """
    koopa::assert_has_no_args "$#"
    koopa::rscript_vanilla 'list'
    return 0
}

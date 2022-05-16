#!/usr/bin/env bash

koopa_list_programs() {
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa --vanilla 'cliListPrograms'
    return 0
}

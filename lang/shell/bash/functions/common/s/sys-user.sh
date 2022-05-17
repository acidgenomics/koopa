#!/usr/bin/env bash

koopa_sys_user() {
    # """
    # Set the koopa installation system user.
    # @note Updated 2022-04-05.
    #
    # Previously this set user as 'root' for shared installs, until 2022-04-05.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_user)"
    return 0
}

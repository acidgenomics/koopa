#!/usr/bin/env bash

koopa_linux_delete_broken_app_symlinks() { # {{{1
    # """
    # Delete broken application symlinks.
    # @note Updated 2020-11-23.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_linux
    koopa_delete_broken_symlinks "$(koopa_make_prefix)"
    return 0
}

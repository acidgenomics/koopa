#!/usr/bin/env bash

koopa::linux_delete_broken_app_symlinks() { # {{{1
    # """
    # Delete broken application symlinks.
    # @note Updated 2020-11-23.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::delete_broken_symlinks "$(koopa::make_prefix)"
    return 0
}

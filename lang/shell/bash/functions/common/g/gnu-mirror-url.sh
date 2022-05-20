#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-04-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'gnu-mirror-url'
    return 0
}

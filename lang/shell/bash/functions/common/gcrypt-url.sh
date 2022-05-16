#!/usr/bin/env bash

koopa_gcrypt_url() {
    # """
    # Get GnuPG FTP URL.
    # @note Updated 2021-04-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'gcrypt-url'
    return 0
}

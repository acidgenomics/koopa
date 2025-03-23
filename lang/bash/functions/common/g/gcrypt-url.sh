#!/usr/bin/env bash

koopa_gcrypt_url() {
    # """
    # Get GnuPG FTP URL.
    # @note Updated 2022-08-23.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print 'https://gnupg.org/ftp/gcrypt'
    return 0
}

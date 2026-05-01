#!/usr/bin/env bash

_koopa_gcrypt_url() {
    # """
    # Get GnuPG FTP URL.
    # @note Updated 2022-08-23.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_print 'https://gnupg.org/ftp/gcrypt'
    return 0
}

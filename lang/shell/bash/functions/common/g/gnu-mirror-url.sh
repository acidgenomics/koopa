#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2022-08-23.
    #
    # @seealso
    # - https://www.gnu.org/prep/ftp.en.html
    # """
    koopa_assert_has_no_args "$#"
    koopa_print 'https://ftpmirror.gnu.org'
    return 0
}

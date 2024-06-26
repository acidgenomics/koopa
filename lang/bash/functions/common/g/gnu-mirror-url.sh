#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2024-06-26.
    #
    # Servers:
    # - https://ftpmirror.gnu.org (primary mirror)
    # - ftp://aeneas.mit.edu/pub/gnu
    # - https://gnu.mirror.constant.com
    # - http://mirror.rit.edu/gnu
    #
    # @seealso
    # - https://www.gnu.org/prep/ftp.en.html
    # - http://gnu.ist.utl.pt/order/ftp.html
    # """
    local server
    koopa_assert_has_no_args "$#"
    server='https://ftpmirror.gnu.org'
    koopa_print "$server"
    return 0
}

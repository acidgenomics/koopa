#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2024-03-25.
    #
    # Servers:
    # - https://ftpmirror.gnu.org (primary mirror)
    # - ftp://aeneas.mit.edu/pub/gnu
    # - https://gnu.mirror.constant.com
    #
    # @seealso
    # - https://www.gnu.org/prep/ftp.en.html
    # - http://gnu.ist.utl.pt/order/ftp.html
    # """
    local server
    koopa_assert_has_no_args "$#"
    # > server='https://ftpmirror.gnu.org'
    server='http://mirror.rit.edu/gnu'
    koopa_print "$server"
    return 0
}

#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://www.gnu.org/prep/ftp.en.html
    # - http://gnu.ist.utl.pt/order/ftp.html
    # """
    local server
    koopa_assert_has_no_args "$#"
    # > server='https://ftpmirror.gnu.org'
    server='ftp://aeneas.mit.edu/pub/gnu'
    koopa_print "$server"
    return 0
}

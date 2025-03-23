#!/usr/bin/env bash

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2025-01-15.
    #
    # Servers:
    # - https://ftpmirror.gnu.org (primary mirror)
    # - https://ftp.gnu.org/gnu
    # - https://gnu.mirror.constant.com
    # - ftp://aeneas.mit.edu/pub/gnu
    # - http://mirror.rit.edu/gnu
    #
    # @seealso
    # - https://www.gnu.org/prep/ftp.en.html
    # - http://gnu.ist.utl.pt/order/ftp.html
    # """
    local server
    koopa_assert_has_no_args "$#"
    server='https://gnu.mirror.constant.com'
    koopa_print "$server"
    return 0
}

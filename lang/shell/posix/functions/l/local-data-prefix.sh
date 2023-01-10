#!/bin/sh

koopa_local_data_prefix() {
    # """
    # Local user application data prefix.
    # @note Updated 2021-05-25.
    #
    # This is the default app path when koopa is installed per user.
    # """
    koopa_print "$(koopa_xdg_data_home)"
    return 0
}

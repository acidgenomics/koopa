#!/bin/sh

koopa_pipx_prefix() {
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_xdg_data_home)/pipx"
    return 0
}

#!/bin/sh

koopa_config_prefix() {
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    koopa_print "$(koopa_xdg_config_home)/koopa"
    return 0
}

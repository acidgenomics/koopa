#!/bin/sh

koopa_docker_private_prefix() {
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    koopa_print "$(koopa_config_prefix)/docker-private"
    return 0
}

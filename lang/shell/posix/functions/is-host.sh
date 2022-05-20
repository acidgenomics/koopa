#!/bin/sh

koopa_is_host() {
    # """
    # Does the current host match?
    # @note Updated 2020-08-06.
    # """
    [ "$(koopa_host_id)" = "${1:?}" ]
}

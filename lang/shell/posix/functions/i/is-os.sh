#!/bin/sh

koopa_is_os() {
    # """
    # Is a specific OS ID?
    # @note Updated 2020-08-06.
    #
    # This will match Debian but not Ubuntu for a Debian check.
    # """
    [ "$(koopa_os_id)" = "${1:?}" ]
}

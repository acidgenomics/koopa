#!/bin/sh

_koopa_is_os() {
    # """
    # Is a specific OS ID?
    # @note Updated 2023-02-28.
    #
    # This will match Debian but not Ubuntu for 'debian' input.
    # """
    [ "$(koopa_os_id)" = "${1:?}" ]
}

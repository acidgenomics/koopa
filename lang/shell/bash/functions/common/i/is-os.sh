#!/usr/bin/env bash

koopa_is_os() {
    # """
    # Is a specific OS ID?
    # @note Updated 2023-01-10.
    #
    # This will match Debian but not Ubuntu for 'debian' input.
    # """
    [[ "$(koopa_os_id)" = "${1:?}" ]]
}

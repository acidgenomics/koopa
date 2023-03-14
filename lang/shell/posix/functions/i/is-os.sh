#!/bin/sh

_koopa_is_os() {
    # """
    # Is a specific OS ID?
    # @note Updated 2023-03-09.
    #
    # This will match Debian but not Ubuntu for 'debian' input.
    # """
    [ "$(_koopa_os_id)" = "${1:?}" ]
}

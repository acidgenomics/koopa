#!/bin/sh

koopa_is_docker() {
    # """
    # Is the current session running inside Docker?
    # @note Updated 2022-01-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/23513045/
    # - https://stackoverflow.com/questions/20010199/
    # """
    [ -f '/.dockerenv' ]
}

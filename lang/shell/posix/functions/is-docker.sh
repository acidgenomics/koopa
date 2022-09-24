#!/bin/sh

koopa_is_docker() {
    # """
    # Is the current session running inside Docker?
    # @note Updated 2022-09-24.
    #
    # @seealso
    # - https://stackoverflow.com/questions/23513045/
    # - https://stackoverflow.com/questions/20010199/
    # - https://www.baeldung.com/linux/is-process-running-inside-container
    # """
    [ "${KOOPA_IS_DOCKER:-0}" -eq 1 ] && return 0
    [ -f '/.dockerenv' ] && return 0
    # > [ -f '/proc/1/cgroup' ] || return 1
    # > [ -f '/proc/1/sched' ] || return 1
    return 1
}

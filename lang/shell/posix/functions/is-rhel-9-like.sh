#!/bin/sh

koopa_is_rhel_9_like() {
    # """
    # Is the operating system RHEL 9-like?
    # @note Updated 2022-05-16.
    # """
    koopa_is_rhel_like && koopa_is_os_version 9
}

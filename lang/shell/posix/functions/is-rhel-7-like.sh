#!/bin/sh

koopa_is_rhel_7_like() {
    # """
    # Is the operating system RHEL 7-like?
    # @note Updated 2021-03-25.
    # """
    koopa_is_rhel_like && koopa_is_os_version 7
}

#!/bin/sh

koopa_is_rhel_8_like() {
    # """
    # Is the operating system RHEL 8-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_rhel_like && koopa_is_os_version 8
}

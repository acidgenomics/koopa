#!/usr/bin/env bash

# FIXME Move this back to POSIX library.

koopa_is_fedora_like() {
    # """
    # Is the operating system Fedora-like?
    # @note Updated 2023-01-10.
    # """
    koopa_is_os_like 'fedora'
}

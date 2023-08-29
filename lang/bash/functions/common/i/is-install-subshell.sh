#!/usr/bin/env bash

koopa_is_install_subshell() {
    # """
    # Is the current script running inside our isolated install subshell?
    # @note Updated 2023-08-29.
    # """
    [[ "${KOOPA_INSTALL_APP_SUBSHELL:-0}" -eq 1 ]]
}

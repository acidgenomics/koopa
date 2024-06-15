#!/usr/bin/env bash

koopa_can_build_binary() {
    # """
    # Is the current machine configured to build binaries?
    # @note Updated 2024-06-14.
    # """
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]]
}

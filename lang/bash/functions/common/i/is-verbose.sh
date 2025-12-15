#!/usr/bin/env bash

koopa_is_verbose() {
    # """
    # Is the current session running in verbose mode?
    # @note Updated 2025-12-15.
    # """
    [[ "${KOOPA_VERBOSE:-0}" -eq 1 ]]
}

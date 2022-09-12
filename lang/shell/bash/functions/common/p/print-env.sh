#!/usr/bin/env bash

koopa_print_env() {
    # """
    # Print environment variables.
    # @note Updated 2022-09-12.
    #
    # Alternatively, can use 'declare -x', which is a bashism.
    # """
    export -p
    return 0
}

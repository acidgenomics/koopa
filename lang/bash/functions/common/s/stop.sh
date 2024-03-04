#!/usr/bin/env bash

koopa_stop() {
    # """
    # Stop with an error message.
    # @note Updated 2024-03-04.
    #
    # @seealso
    # - https://raw.githubusercontent.com/TritonDataCenter/sdc-headnode/
    #     master/buildtools/lib/error_handler.sh
    # """
    koopa_msg 'red-bold' 'red' 'Error:' "$@" >&2
    set +o errexit
    set +o errtrace
    set +o xtrace
    trap '' ERR
    koopa_stack_trace
    exit 1
}

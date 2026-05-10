#!/usr/bin/env bash

_koopa_stop() {
    # """
    # Stop with an error message.
    # @note Updated 2024-03-04.
    #
    # @seealso
    # - https://raw.githubusercontent.com/TritonDataCenter/sdc-headnode/
    #     master/buildtools/lib/error_handler.sh
    # """
    local -A bool
    bool['verbose']="${KOOPA_VERBOSE:-0}"
    _koopa_msg 'red-bold' 'red' 'Error:' "$@" >&2
    # Include stack trace in verbose mode.
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        set +o errexit
        set +o errtrace
        set +o xtrace
        trap '' ERR
        _koopa_stack_trace
    fi
    exit 1
}

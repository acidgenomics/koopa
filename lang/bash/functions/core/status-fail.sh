#!/usr/bin/env bash

_koopa_status_fail() {
    # """
    # 'FAIL' status.
    # @note Updated 2021-06-03.
    # """
    _koopa_status 'FAIL' 'red' "$@" >&2
}

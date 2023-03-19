#!/usr/bin/env bash

koopa_status_fail() {
    # """
    # 'FAIL' status.
    # @note Updated 2021-06-03.
    # """
    koopa_status 'FAIL' 'red' "$@" >&2
}

#!/usr/bin/env bash

_koopa_is_os() {
    [[ "$(_koopa_os_id)" == "${1:?}" ]]
}

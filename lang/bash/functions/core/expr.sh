#!/usr/bin/env bash

_koopa_expr() {
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

#!/usr/bin/env bash

koopa_locate_pager() {
    [[ -n "${PAGER:-}" ]] || return 1
    koopa_print "$PAGER"
    return 0
}

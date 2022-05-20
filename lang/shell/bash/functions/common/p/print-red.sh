#!/usr/bin/env bash

koopa_print_red() {
    __koopa_print_ansi 'red' "$@"
    return 0
}

#!/usr/bin/env bash

koopa_print_red_bold() {
    __koopa_print_ansi 'red-bold' "$@"
    return 0
}

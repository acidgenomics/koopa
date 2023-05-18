#!/usr/bin/env bash

koopa_print_red_bold() {
    koopa_print_ansi 'red-bold' "$@"
    return 0
}

#!/usr/bin/env bash

_koopa_is_tty() {
    _koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

#!/usr/bin/env bash

# FIXME May need to use system variant on macOS.

koopa_locate_ssh() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh' \
        "$@"
}

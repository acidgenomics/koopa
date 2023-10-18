#!/usr/bin/env bash

koopa_locate_clang() {
    koopa_locate_app \
        --app-name='llvm' \
        --bin-name='clang' \
        "$@"
}

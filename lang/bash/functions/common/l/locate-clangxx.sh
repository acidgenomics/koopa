#!/usr/bin/env bash

koopa_locate_clangxx() {
    koopa_locate_app \
        --app-name='llvm' \
        --bin-name='clang++' \
        "$@"
}

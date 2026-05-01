#!/usr/bin/env bash

_koopa_locate_clang() {
    _koopa_locate_app \
        --app-name='llvm' \
        --bin-name='clang' \
        "$@"
}

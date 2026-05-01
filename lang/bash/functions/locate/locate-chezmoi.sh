#!/usr/bin/env bash

_koopa_locate_chezmoi() {
    _koopa_locate_app \
        --app-name='chezmoi' \
        --bin-name='chezmoi' \
        "$@"
}

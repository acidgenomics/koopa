#!/usr/bin/env bash

_koopa_locate_koopa() {
    _koopa_locate_app \
        "$(_koopa_koopa_prefix)/bin/koopa" \
        "$@"
}

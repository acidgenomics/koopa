#!/usr/bin/env bash

_koopa_locate_texi2dvi() {
    _koopa_locate_app \
        --app-name='texinfo' \
        --bin-name='texi2dvi' \
        "$@"
}

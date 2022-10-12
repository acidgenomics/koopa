#!/usr/bin/env bash

koopa_locate_texi2dvi() {
    koopa_locate_app \
        --app-name='texi2cvi' \
        --bin-name='texinfo' \
        "$@"
}

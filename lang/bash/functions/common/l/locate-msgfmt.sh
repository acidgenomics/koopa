#!/usr/bin/env bash

koopa_locate_msgfmt() {
    koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgfmt' \
        "$@"
}

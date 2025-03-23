#!/usr/bin/env bash

koopa_locate_msgmerge() {
    koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgmerge' \
        "$@"
}

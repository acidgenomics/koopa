#!/usr/bin/env bash

# FIXME Rework this to use koopa zip when available.

koopa_locate_zip() {
    koopa_locate_app \
        '/usr/bin/zip' \
        "$@"
}

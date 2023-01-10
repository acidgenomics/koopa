#!/usr/bin/env bash

koopa_linux_locate_gpasswd() {
    koopa_locate_app \
        '/usr/bin/gpasswd' \
        "$@"
}

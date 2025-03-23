#!/usr/bin/env bash

koopa_debian_locate_timedatectl() {
    koopa_locate_app \
        '/usr/bin/timedatectl' \
        "$@"
}

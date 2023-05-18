#!/usr/bin/env bash

koopa_debian_locate_service() {
    koopa_locate_app \
        '/usr/sbin/service' \
        "$@"
}

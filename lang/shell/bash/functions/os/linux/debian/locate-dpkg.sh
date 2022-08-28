#!/usr/bin/env bash

koopa_debian_locate_dpkg() {
    koopa_locate_app \
        '/usr/bin/dpkg' \
        "$@"
}

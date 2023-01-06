#!/usr/bin/env bash
# shellcheck disable=all

koopa_opensuse_locate_zypper() {
    koopa_locate_app \
        '/usr/bin/zypper' \
        "$@"
}

#!/usr/bin/env bash
# shellcheck disable=all

_koopa_opensuse_locate_zypper() {
    _koopa_locate_app \
        '/usr/bin/zypper' \
        "$@"
}

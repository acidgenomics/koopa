#!/usr/bin/env bash

_koopa_locate_mount_s3() {
    _koopa_locate_app \
        '/usr/bin/mount-s3' \
        "$@"
}

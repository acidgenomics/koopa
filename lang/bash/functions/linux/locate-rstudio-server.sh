#!/usr/bin/env bash

_koopa_linux_locate_rstudio_server() {
    _koopa_locate_app \
        '/usr/sbin/rstudio-server' \
        "$@"
}

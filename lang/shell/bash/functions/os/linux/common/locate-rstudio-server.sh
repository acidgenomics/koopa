#!/usr/bin/env bash

koopa_linux_locate_rstudio_server() {
    koopa_locate_app \
        '/usr/sbin/rstudio-server' \
        "$@"
}

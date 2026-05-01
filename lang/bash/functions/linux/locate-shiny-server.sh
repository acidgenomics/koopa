#!/usr/bin/env bash

_koopa_linux_locate_shiny_server() {
    _koopa_locate_app \
        '/usr/bin/shiny-server' \
        "$@"
}

#!/usr/bin/env bash

_koopa_macos_uninstall_system_cisco_webex() {
    _koopa_uninstall_app \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

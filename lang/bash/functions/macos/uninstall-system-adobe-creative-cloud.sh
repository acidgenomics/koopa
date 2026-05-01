#!/usr/bin/env bash

_koopa_macos_uninstall_system_adobe_creative_cloud() {
    _koopa_uninstall_app \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

#!/usr/bin/env bash

koopa_macos_uninstall_system_adobe_creative_cloud() {
    koopa_uninstall_app \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

#!/usr/bin/env bash

koopa::macos_uninstall_adobe_creative_cloud() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Adobe Creative Cloud' \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_cisco_webex() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Cisco WebEx' \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

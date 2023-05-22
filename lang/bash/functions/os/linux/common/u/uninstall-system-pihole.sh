#!/usr/bin/env bash

# FIXME This isn't running our uninstall script...

koopa_linux_uninstall_system_pihole() {
    koopa_uninstall_app \
        --name='pihole' \
        --system \
        "$@"
}

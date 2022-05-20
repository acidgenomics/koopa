#!/usr/bin/env bash

koopa_uninstall_taglib() {
    koopa_uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}
